#!/usr/bin/env bash

arr=("custom-theme" "pixies")
for n in "${arr[@]}"; do
    typst c ../examples/${n}.typ --pages 1 --ppi 250 --format png
done

mv ../examples/*.png .

oxipng -o max --fast -Z --strip all *.png
