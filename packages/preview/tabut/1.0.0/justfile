build: skip-output-files local-pub compile-snippets
    typst compile README.typ README.pdf 
    pandoc -t gfm -o README.md README.typ

build-github-action: local-pub compile-snippets
    typst compile README.typ README.pdf 
    pandoc -t gfm -o README.md README.typ

local-pub:
    sh local-pub.bash

compile-snippets:
    sh compile-snippets.bash

skip-output-files:
    sh skip-output-files.bash
    



