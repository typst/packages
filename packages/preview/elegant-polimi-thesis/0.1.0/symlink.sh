#!/usr/bin/env bash

pkg_name="elegant-polimi-thesis"
version=0.1.0

source=$PWD
destinations=("$HOME/.cache/typst/packages/preview/$pkg_name/" "$HOME/.local/share/typst/packages/local/$pkg_name/")

for destination in ${destinations[@]}
do
    mkdir -p $destination
    ln -s $source $destination/$version
done
