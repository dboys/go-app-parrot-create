package main

import "fmt"

func main() {
	params := &ParrotParams{
		Name:        "lang 1",
		Revision:    parrotRevision,
		BuildSystem: buildNqp,
		TestSystem:  testRosellaNqp,
		PMC:         true,
		OPS:         true,
		DOC:         true,
	}
	templ := NewTemplate(parrotHLL, params)
	path, _ := templ.Generate()
	fmt.Println(path)

	params2 := &ParrotParams{
		Name:        "lang 1",
		Revision:    parrotRevision,
		BuildSystem: buildNqp,
		TestSystem:  testRosellaNqp,
		PMC:         true,
		OPS:         true,
		DOC:         true,
	}
	templ2 := NewTemplate(parrotHLL, params2)

	path, _ = templ2.Generate()
	fmt.Println(path)
}
