#!/bin/bash

# Get the current commit hash
COMMIT=$(git rev-parse HEAD)

# Compile thesis with typst, using fonts in ../fonts folder and including the first 8 characters of current git commit SHA
# Note that this version will not include the cover in the pdf, and is intended to be used as content file for the printshop
typst compile ../thesis.typ ../thesis-for-printshop.pdf --root ../ --font-path ../fonts --input commit="${COMMIT:0:8}" --input forprint=
