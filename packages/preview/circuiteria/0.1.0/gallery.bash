#!/bin/bash

PDFS=false

while getopts "p" flag
do
    case "${flag}" in
        p) PDFS=true;;
    esac
done

echo "Generating gallery images"

set -- ./gallery/*.typ
cnt="$#"
i=1
for f
do
    f2="${f/typ/png}"
    echo "($i/$cnt) $f -> $f2"
    typst c --root ./ "$f" "$f2"
    i=$((i+1))
done

if [ "$PDFS" = true ]
then
    echo
    echo "Generating gallery PDFs"

    set -- ./gallery/*.typ
    cnt="$#"
    i=1
    for f
    do
        f2="${f/typ/pdf}"
        echo "($i/$cnt) $f -> $f2"
        typst c --root ./ "$f" "$f2"
        i=$((i+1))
    done
fi