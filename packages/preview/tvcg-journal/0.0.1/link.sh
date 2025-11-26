#!/usr/bin/env bash

set -e

version_line=$(grep -E "^version\s*=" "typst.toml")
version=$(echo "$version_line" | cut -d '"' -f 2)

target=~/Library/Application\ Support/typst/packages/preview/tvcg-journal/
mkdir -p "$target"

rm -f "$target$version"
ln -s $(pwd)/. "$target$version"

echo Created lib.typ symlink in \""$target$version"\". To unlink, delete the symlink.
