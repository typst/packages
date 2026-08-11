#!/usr/bin/env bash

pkg_name="elegant-polimi-thesis"
version=0.2.0

source=$PWD
destinations=("$HOME/.cache/typst/packages/preview/$pkg_name/" "$HOME/.local/share/typst/packages/local/$pkg_name/")

for destination in ${destinations[@]}
do
    rm -r -f $destination
    mkdir -p $destination
    ln -s $source $destination/$version
done
