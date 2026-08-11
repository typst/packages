#!/usr/bin/env bash

frontispieces=(phd deib-phd cs-eng-master classical-master)

for f in "${frontispieces[@]}"; do
    typst c thumbnail_thesis.typ "$f".png --input=frontispiece="$f" --pages 1 --ppi 250 --format png 
done

typst c thumbnail_summary.typ --root ../  --pages 1 --ppi 250 --format png 
mv thumbnail_summary.png executive-summary.png
typst c thumbnail_article.typ --root ../  --pages 1 --ppi 250 --format png 
mv thumbnail_article.png article-format.png

oxipng -o max --fast -Z --strip all *.png
