package main

import (
	"flag"
	"log"
	"net/http"
	"os"
)

const (
	defaultAddr = "localhost:8080"
)

type App struct {
	Addr  string
	Debug bool
}

func NewApp(args []string) *App {
	var (
		server string
		debug  bool
	)

	cmd := flag.NewFlagSet("", flag.ExitOnError)
	cmd.StringVar(&server, "server", defaultAddr, "Server address")
	cmd.BoolVar(&debug, "debug", false, "Debug mode")
	cmd.Parse(args)

	return &App{
		Addr:  server,
		Debug: debug,
	}
}

func (a *App) Start() {
	server := NewWebServerApp(a.Debug)
	server.Get("/", server.index)
	server.Post("/", server.generateProject)
	server.Get("/public/.*", server.public)

	err := http.ListenAndServe(a.Addr, server)

	if err != nil {
		log.Fatalf("Could not start server: %s\n", err.Error())
	}

}

func main() {
	app := NewApp(os.Args[1:])
	app.Start()
}
