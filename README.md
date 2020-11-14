[![](https://travis-ci.org/dboys/go-app-parrot-create.svg?branch=master)](https://travis-ci.org/dboys/go-app-parrot-create)

# go-app-parrot-create
This web app helps create new [Parrot Virtual Machine](http://parrot.org) projects. Currently it
supports High Level Languages (HLLs) and Libraries.

# Running tests

    go test -v -bench . -cover -race

# Building

    go build

# Running

To run as a background process with default configuration:

    ./go-app-parrot-create &

Or with the custom options:

    ./go-app-parrot-create --server=localhost:3000 --debug &

# View

You can now view the app running in your favorite web browser at

    http://127.0.0.1:8080

# Contributing

Pull requests encouraged and welcome!