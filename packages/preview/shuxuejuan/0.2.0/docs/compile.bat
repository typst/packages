@REM This file compiles `typ`s in `/docs`.

cd ./docs

typst c ./manual.typ --root ../ ./outputs/manual.pdf
typst c ./manual.typ --root ../ ./outputs/manual-p1.png --pages 1 --ppi 300

typst c ./example.typ --root ../ ./outputs/example.png --ppi 300