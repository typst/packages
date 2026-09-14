@REM This file compiles `typ`s in `/docs`.

@echo off

cd ./docs

echo Compiling /docs/manual.typ...
typst c ./manual.typ --root ../ ./outputs/manual.pdf
typst c ./manual.typ --root ../ ./outputs/manual-p1.png --pages 1 --ppi 300

echo Compiling /docs/example.typ...
typst c ./example.typ --root ../ ./outputs/example.png --ppi 300

echo Done.