#!/bin/bash

# Get the current commit hash
COMMIT=$(git rev-parse HEAD)

# compile propositions with typst, using fonts in ../fonts folder and including the first 8 characters of current git commit SHA
typst watch ../propositions.typ --root ../../ --font-path ../../fonts --input commit="${COMMIT:0:8}"