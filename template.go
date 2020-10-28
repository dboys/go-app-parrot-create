package main

import (
	"archive/zip"
	"bufio"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"text/template"
)

const (
	buildWinxed       = "Winxed"
	buildNqp          = "NQP (Not Quite Perl 6)"
	buildPir          = "PIR (Parrot Intermediate Representation)"
	buildPerl5        = "Perl 5"
	testRosellaWinxed = "Rosella (Winxed)"
	testRosellaNqp    = "Rosella (NQP)"
	testPerl5         = "Perl 5"
	parrotRevision    = "5.3.0"
)

const (
	parrotHLL = iota
	parrotLibrary
)

const (
	parrotHLLTmpl     = "project-templates/hll.parrot"
	parrotLibraryTmpl = "project-templates/library.parrot"
)

var cacheTmpl map[ParrotParams]string = map[ParrotParams]string{}

type BuildSystem string

func (b BuildSystem) IsWinxed() bool {
	return b == buildWinxed
}

func (b BuildSystem) IsNqp() bool {
	return b == buildNqp
}

func (b BuildSystem) IsPir() bool {
	return b == buildPir
}

func (b BuildSystem) IsPerl5() bool {
	return b == buildPerl5
}

type TestSystem string

func (t TestSystem) IsRosellaWindxed() bool {
	return t == testRosellaWinxed
}

func (t TestSystem) IsRosellaNqp() bool {
	return t == testRosellaNqp
}

func (t TestSystem) IsPerl5() bool {
	return t == testPerl5
}

type ParrotParams struct {
	Name        string
	BuildSystem BuildSystem
	TestSystem  TestSystem
	Revision    string
	PMC         bool
	OPS         bool
	DOC         bool
}

type ParrotTemplate struct {
	Path   string
	Params *ParrotParams
	mutex  sync.Mutex
}

func (p *ParrotTemplate) generateTemplate() (string, error) {
	var buf bytes.Buffer

	t, err := template.ParseFiles(p.Path)
	if err != nil {
		return "", err
	}

	err = t.Execute(&buf, p.Params)
	if err != nil {
		return "", err
	}

	return buf.String(), nil
}

func (p *ParrotTemplate) generateProject(tt string) (string, error) {
	var fh *os.File
	defer fh.Close()

	baseDir, err := ioutil.TempDir("", "app-parrot-create-")
	if err != nil {
		return "", err
	}

	scanner := bufio.NewScanner(strings.NewReader(tt))
	for scanner.Scan() {
		line := scanner.Text()

		if strings.Contains(line, "__END__") {
			break
		}

		reg := regexp.MustCompile("__(.*)__")
		match := reg.FindStringSubmatch(line)

		if len(match) > 0 && len(match[1]) > 0 {
			subDir, file := filepath.Split(match[1])
			dirPath := filepath.Join(baseDir, subDir)

			err = os.MkdirAll(dirPath, os.ModePerm)
			if err != nil {
				return "", err
			}

			filePath := filepath.Join(dirPath, file)
			if fh != nil {
				fh.Close()
			}

			fh, err = os.OpenFile(filePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
			if err != nil {
				return "", err
			}
		} else {
			if fh == nil {
				continue
			}

			if _, err := fmt.Fprintln(fh, line); err != nil {
				return "", err
			}
		}
	}

	return baseDir, nil
}

func (p *ParrotTemplate) generateArchive(path string) (string, error) {
	dir, name := filepath.Split(path)
	zipName := fmt.Sprintf("%s.zip", name)
	zipPath := filepath.Join(dir, zipName)
	zipFile, err := os.Create(zipPath)
	if err != nil {
		return "", err
	}
	defer zipFile.Close()

	w := zip.NewWriter(zipFile)
	defer w.Close()

	walker := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		file, err := os.Open(path)
		if err != nil {
			return err
		}
		defer file.Close()

		parts := strings.Split(path, string(os.PathSeparator))
		zipPath := filepath.Join(parts[2:]...)
		f, err := w.Create(zipPath)
		if err != nil {
			return err
		}

		_, err = io.Copy(f, file)
		if err != nil {
			return err
		}

		return nil
	}

	err = filepath.Walk(path, walker)
	if err != nil {
		return "", err
	}

	err = os.RemoveAll(path)
	if err != nil {
		return "", err
	}

	return zipPath, nil
}

func (p *ParrotTemplate) Generate() (string, error) {
	p.mutex.Lock()
	defer p.mutex.Unlock()

	if val, ok := cacheTmpl[*p.Params]; ok {
		return val, nil
	}

	tt, err := p.generateTemplate()
	if err != nil {
		return "", err
	}

	path, err := p.generateProject(tt)
	if err != nil {
		return "", err
	}

	zip, err := p.generateArchive(path)
	if err != nil {
		return "", err
	}

	cacheTmpl[*p.Params] = zip

	return zip, nil
}

func NewTemplate(t int, params *ParrotParams) *ParrotTemplate {
	var tmpl string

	switch t {
	case parrotHLL:
		tmpl = parrotHLLTmpl
	case parrotLibrary:
		tmpl = parrotLibraryTmpl
	}

	return &ParrotTemplate{
		Path:   tmpl,
		Params: params,
		mutex:  sync.Mutex{},
	}
}
