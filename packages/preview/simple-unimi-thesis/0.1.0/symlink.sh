#!/usr/bin/env bash

pkg_name="simple-unimi-thesis"
version=0.1.0

source=$PWD
destinations=("$HOME/.cache/typst/packages/preview/$pkg_name/" "$HOME/.local/share/typst/packages/local/$pkg_name/")

for destination in ${destinations[@]}
do
    rm -r $destination
    mkdir -p $destination
    ln -s $source $destination/$version
done
