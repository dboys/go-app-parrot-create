package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
)

func TestIndex(t *testing.T) {
	app := NewWebServerApp(false)
	srv := httptest.NewServer(http.HandlerFunc(app.index))
	defer srv.Close()

	res, err := http.Get(srv.URL)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		t.Errorf("Status is not OK")
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		t.Fatal(err)
	}

	if len(string(body)) == 0 {
		t.Errorf("Empty response for 'index' route")
	}
}

func TestGenerateProject(t *testing.T) {
	app := NewWebServerApp(false)
	srv := httptest.NewServer(http.HandlerFunc(app.generateProject))
	defer srv.Close()

	testVals := []url.Values{
		{
			"hll":                 {"1"},
			"hll_name":            {"lang 1"},
			"hll_parrot_revision": {parrotRevision},
			"hll_builder":         {buildNqp},
			"hll_test":            {testRosellaNqp},
			"with_pmc":            {"1"},
			"with_ops":            {"1"},
			"with_doc":            {"1"},
		},
		{
			"hll":                 {"1"},
			"hll_name":            {"lang 2"},
			"hll_parrot_revision": {parrotRevision},
			"hll_builder":         {buildWinxed},
			"hll_test":            {testPerl5},
			"with_pmc":            {"0"},
			"with_ops":            {"1"},
			"with_doc":            {"0"},
		},
		{
			"hll":                 {"1"},
			"hll_name":            {"lang 3"},
			"hll_parrot_revision": {parrotRevision},
			"hll_builder":         {buildPerl5},
			"hll_test":            {testRosellaWinxed},
			"with_pmc":            {"1"},
			"with_ops":            {"0"},
			"with_doc":            {"1"},
		},
		{
			"lib_name":            {"lib 1"},
			"lib_parrot_revision": {parrotRevision},
			"lib_builder":         {buildPir},
			"lib_test":            {testRosellaWinxed},
		},
		{
			"lib_name":            {"lib 2"},
			"lib_parrot_revision": {parrotRevision},
			"lib_builder":         {buildNqp},
			"lib_test":            {testPerl5},
		},
		{
			"lib_name":            {"lib 3"},
			"lib_parrot_revision": {parrotRevision},
			"lib_builder":         {buildWinxed},
			"lib_test":            {testRosellaNqp},
		},
	}

	for _, testVal := range testVals {
		resp, err := http.PostForm(srv.URL, testVal)
		if err != nil {
			t.Fatal(err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			t.Errorf("Status is not OK")
		}

		if !strings.Contains(resp.Header.Get("Content-type"), "application/zip") {
			t.Errorf("Wrong content type response for 'generateProject' route")
		}

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			t.Fatal(err)
		}

		if len(body) == 0 {
			t.Errorf("Empty body for 'generateProject' route")
		}
	}
}

func TestPublicResources(t *testing.T) {
	app := NewWebServerApp(false)
	srv := httptest.NewServer(http.HandlerFunc(app.public))
	defer srv.Close()

	resources := []string{"css/error.css", "css/error.css", "css/bootstrap.min.css", "css/bootstrap-responsive.min.css", "img/parrot_logo.png", "img/parrot_head.png", "img/glyphicons-halflings-white.png", "img/glyphicons-halflings-white.png", "js/jquery.js", "js/bootstrap.min.js"}

	for _, resource := range resources {
		res, err := http.Get(fmt.Sprintf("%s/public/%s", srv.URL, resource))
		if err != nil {
			t.Fatal(err)
		}
		defer res.Body.Close()

		if res.StatusCode != http.StatusOK {
			t.Errorf("Status is not OK")
		}

		body, err := ioutil.ReadAll(res.Body)
		if err != nil {
			t.Fatal(err)
		}

		if len(string(body)) == 0 {
			t.Errorf("Empty response for 'public' route")
		}
	}
}
