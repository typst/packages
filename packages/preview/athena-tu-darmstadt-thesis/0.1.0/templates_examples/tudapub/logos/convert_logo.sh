#!/bin/sh 

# first download the logo from:
#   https://download.hrz.tu-darmstadt.de/protected/ULB/tuda_logo.pdf

cd "$(dirname "$0")"

pdf2svg tuda_logo.pdf tuda_logo.svg