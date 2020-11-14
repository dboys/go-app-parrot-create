# go-app-parrot-create
This web app helps create new [Parrot Virtual Machine](http://parrot.org) projects. Currently it
supports High Level Languages (HLLs) and Libraries.

# Running tests

    go test -v -race *.go

# Building

    go build *.go

# Running

To run as a background process with default configuration:

    ./main &

Or with the custom options:

    ./main --server=localhost:3000 --debug &

# View

You can now view the app running in your favorite web browser at

    http://127.0.0.1:8080

# Contributing

Pull requests encouraged and welcome!