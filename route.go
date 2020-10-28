package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
)

const (
	POST = "POST"
	GET  = "GET"
)

type Handler func(w http.ResponseWriter, r *http.Request)

type Route struct {
	Handler Handler
	Pattern *regexp.Regexp
}

type WebServerApp struct {
	Routes       []Route
	DefaultRoute Handler
}

func pattern(method, path string) string {
	return fmt.Sprintf(`^%s %s$`, method, path)
}

func NewWebServerApp() *WebServerApp {
	app := &WebServerApp{
		DefaultRoute: func(w http.ResponseWriter, r *http.Request) {
			http.NotFound(w, r)
		},
	}

	return app
}

func (a *WebServerApp) handle(path string, handler Handler) {
	re := regexp.MustCompile(path)
	route := Route{Pattern: re, Handler: handler}

	a.Routes = append(a.Routes, route)
}

func (a *WebServerApp) Get(path string, handler Handler) {
	a.handle(pattern(GET, path), handler)
}

func (a *WebServerApp) Post(path string, handler Handler) {
	a.handle(pattern(POST, path), handler)
}

func (a *WebServerApp) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	check := fmt.Sprintf("%s %s", r.Method, r.URL.Path)

	for _, route := range a.Routes {
		if route.Pattern.MatchString(check) == true {
			route.Handler(w, r)
			return
		}
	}

	a.DefaultRoute(w, r)
}

func (a *WebServerApp) index(w http.ResponseWriter, r *http.Request) {
	t, err := template.ParseFiles("templates/index.html", "templates/main.html")
	if err != nil {
		a.DefaultRoute(w, r)
		return
	}

	t.ExecuteTemplate(w, "index", "")
}

func (a *WebServerApp) generateProject(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		a.DefaultRoute(w, r)
		return
	}

	var (
		tt     *ParrotTemplate
		params *ParrotParams
	)

	form := r.PostForm
	_, hll := form["hll"]

	if hll {
		params = &ParrotParams{
			Name:        r.PostFormValue("hll_name"),
			Revision:    r.PostFormValue("hll_parrot_revision"),
			BuildSystem: BuildSystem(r.PostFormValue("hll_builder")),
			TestSystem:  TestSystem(r.PostFormValue("hll_test")),
			PMC:         false,
			OPS:         false,
			DOC:         false,
		}

		withPMC := r.PostFormValue("with_pmc")
		if withPMC == "1" {
			params.PMC = true
		}

		withOPS := r.PostFormValue("with_ops")
		if withOPS == "1" {
			params.OPS = true
		}

		withDOC := r.PostFormValue("with_doc")
		if withDOC == "1" {
			params.DOC = true
		}

		tt = NewTemplate(parrotHLL, params)
	} else {
		params = &ParrotParams{
			Name:        r.PostFormValue("lib_name"),
			Revision:    r.PostFormValue("lib_parrot_revision"),
			BuildSystem: BuildSystem(r.PostFormValue("lib_builder")),
			TestSystem:  TestSystem(r.PostFormValue("lib_test")),
		}
		tt = NewTemplate(parrotLibrary, params)
	}

	zipPath, err := tt.Generate()
	if err != nil {
		a.DefaultRoute(w, r)
		return
	}

	w.Header().Set("Content-type", "application/zip")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s.zip", params.Name))
	http.ServeFile(w, r, zipPath)
}

func (a *WebServerApp) public(w http.ResponseWriter, r *http.Request) {
	path, err := os.Getwd()
	if err != nil {
		a.DefaultRoute(w, r)
		return
	}

	file := filepath.Join(path, r.URL.Path)

	if _, err := os.Stat(file); os.IsNotExist(err) {
		a.DefaultRoute(w, r)
		return
	}

	http.ServeFile(w, r, file)
}

func StartWebServer(addr string, port int) {
	app := NewWebServerApp()

	app.Get("/", app.index)
	app.Post("/", app.generateProject)
	app.Get("/public/.*", app.public)

	err := http.ListenAndServe(fmt.Sprintf("%s:%d", addr, port), app)

	if err != nil {
		log.Fatalf("Could not start server: %s\n", err.Error())
	}
}
