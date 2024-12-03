#!/bin/sh 

# first download the logo from:
#   https://download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf

cd "$(dirname "$0")"

# install with: apt get install pdf2svg
pdf2svg tuda_logo.pdf tuda_logo.svg