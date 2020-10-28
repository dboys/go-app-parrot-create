package main

import (
	"fmt"
	"os"
	"strings"
	"testing"
)

type testCase struct {
	ttType int
	params *ParrotParams
}

var hllTestParams []*ParrotParams = []*ParrotParams{
	&ParrotParams{
		Name:        "lang 1",
		Revision:    parrotRevision,
		BuildSystem: buildNqp,
		TestSystem:  testRosellaNqp,
		PMC:         true,
		OPS:         true,
		DOC:         true,
	},
	&ParrotParams{
		Name:        "lang 2",
		Revision:    parrotRevision,
		BuildSystem: buildWinxed,
		TestSystem:  testPerl5,
		PMC:         false,
		OPS:         true,
		DOC:         false,
	},
	&ParrotParams{
		Name:        "lang 3",
		Revision:    parrotRevision,
		BuildSystem: buildPerl5,
		TestSystem:  testRosellaWinxed,
		PMC:         false,
		OPS:         true,
		DOC:         false,
	},
}

var libraryTestParams []*ParrotParams = []*ParrotParams{
	&ParrotParams{
		Name:        "library 1",
		Revision:    parrotRevision,
		BuildSystem: buildPir,
		TestSystem:  testRosellaWinxed,
	},
	&ParrotParams{
		Name:        "library 2",
		Revision:    parrotRevision,
		BuildSystem: buildNqp,
		TestSystem:  testPerl5,
	},
	&ParrotParams{
		Name:        "library 2",
		Revision:    parrotRevision,
		BuildSystem: buildWinxed,
		TestSystem:  testRosellaNqp,
	},
}

func TestHLLTemplate(t *testing.T) {
	for _, params := range hllTestParams {
		tt := NewTemplate(parrotHLL, params)

		res, err := tt.generateTemplate()
		if err != nil {
			t.Error(err)
		}

		if len(res) <= 0 {
			t.Error("Empty result template")
		}

		testTable := []struct {
			name, tt string
			result   bool
		}{
			{name: fmt.Sprintf("Language '%s'", params.Name), tt: fmt.Sprintf("Language '%s'", params.Name), result: true},
			{name: fmt.Sprintf("'%s' build system", params.BuildSystem), tt: fmt.Sprintf("with %s build system", params.BuildSystem), result: true},
			{name: fmt.Sprintf("'%s' build system", buildPir), tt: fmt.Sprintf("with %s build system", buildPir), result: params.BuildSystem.IsPir()},
			{name: fmt.Sprintf("'%s' build system", buildPerl5), tt: fmt.Sprintf("with %s build system", buildPerl5), result: params.BuildSystem.IsPerl5()},
			{name: fmt.Sprintf("'%s' build system", buildNqp), tt: fmt.Sprintf("with %s build system", buildNqp), result: params.BuildSystem.IsNqp()},
			{name: fmt.Sprintf("'%s' test system", params.TestSystem), tt: fmt.Sprintf("and %s test system", params.TestSystem), result: true},
			{name: fmt.Sprintf("'%s' test system", testRosellaWinxed), tt: fmt.Sprintf("and %s test system", testRosellaWinxed), result: params.TestSystem.IsRosellaWindxed()},
			{name: fmt.Sprintf("'%s' test system", testRosellaNqp), tt: fmt.Sprintf("and %s test system", testRosellaNqp), result: params.TestSystem.IsRosellaNqp()},
			{name: fmt.Sprintf("'%s' language with ops", params.Name), tt: fmt.Sprintf("src/ops/%s.ops", params.Name), result: params.OPS},
			{name: fmt.Sprintf("'%s' language with pmc", params.Name), tt: fmt.Sprintf("src/pmc/%s.pmc", params.Name), result: params.PMC},
			{name: fmt.Sprintf("'%s' language with doc", params.Name), tt: fmt.Sprintf("__doc/%s.pod__", params.Name), result: params.DOC},
		}

		for _, test := range testTable {
			if strings.Contains(res, test.tt) != test.result {
				t.Errorf("'%s' test failed cause '%s' is missing in template", test.name, test.tt)
			}
		}
	}
}

func TestLibraryTemplate(t *testing.T) {
	for _, params := range libraryTestParams {
		tt := NewTemplate(parrotLibrary, params)

		res, err := tt.generateTemplate()
		if err != nil {
			t.Error(err)
		}

		if len(res) <= 0 {
			t.Error("Empty result")
		}

		testTable := []struct {
			name, tt string
			result   bool
		}{
			{name: "Language name", tt: fmt.Sprintf("Library '%s'", params.Name), result: true},
			{name: fmt.Sprintf("'%s' build system", buildWinxed), tt: fmt.Sprintf("with %s build system", buildWinxed), result: params.BuildSystem.IsWinxed()},
			{name: fmt.Sprintf("'%s' build system", params.BuildSystem), tt: fmt.Sprintf("with %s build system", params.BuildSystem), result: true},
			{name: fmt.Sprintf("'%s' build system", buildPerl5), tt: fmt.Sprintf("with %s build system", buildPerl5), result: params.BuildSystem.IsPerl5()},
			{name: fmt.Sprintf("'%s' build system", buildNqp), tt: fmt.Sprintf("with %s build system", buildNqp), result: params.BuildSystem.IsNqp()},
			{name: fmt.Sprintf("'%s' test system", testPerl5), tt: fmt.Sprintf("and %s test system", testPerl5), result: params.TestSystem.IsPerl5()},
			{name: fmt.Sprintf("'%s' test system", params.TestSystem), tt: fmt.Sprintf("and %s test system", params.TestSystem), result: true},
			{name: fmt.Sprintf("'%s' test system", testRosellaNqp), tt: fmt.Sprintf("and %s test system", testRosellaNqp), result: params.TestSystem.IsRosellaNqp()},
		}

		for _, test := range testTable {
			if strings.Contains(res, test.tt) != test.result {
				t.Errorf("'%s' test failed cause '%s' is missing in template", test.name, test.tt)
			}
		}
	}
}

func TestGenerate(t *testing.T) {
	var (
		testCases []*testCase
		archive   []string
	)

	for _, hllParams := range hllTestParams {
		testCases = append(testCases, &testCase{parrotHLL, hllParams})
	}

	for _, libParams := range libraryTestParams {
		testCases = append(testCases, &testCase{parrotLibrary, libParams})
	}

	for _, test := range testCases {
		testParam := test.params
		ttType := test.ttType
		cacheTmpl = map[ParrotParams]string{}

		tt := NewTemplate(ttType, testParam)

		if len(cacheTmpl) > 0 {
			t.Error("Cache should be empty before generation")
		}

		zip, err := tt.Generate()
		if err != nil {
			t.Error(err)
		}

		if _, err = os.Stat(zip); os.IsNotExist(err) {
			t.Errorf("'%s' archive is not exists", zip)
		}

		if _, ok := cacheTmpl[*testParam]; !ok {
			t.Errorf("'%s' is missing in cache", zip)
		}

		tt2 := NewTemplate(ttType, testParam)
		zip2, err := tt2.Generate()
		if err != nil {
			t.Error(err)
		}

		if zip != zip2 {
			t.Errorf("'%s' is not equal '%s'", zip, zip2)
		}

		if len(cacheTmpl) > 1 {
			t.Error("Cache doesn't work propely")
		}

		archive = append(archive, zip, zip2)
	}

	for _, zip := range archive {
		_ = os.RemoveAll(zip)
	}
}
