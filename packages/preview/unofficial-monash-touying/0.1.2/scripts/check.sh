#!/usr/bin/env bash
set -euo pipefail

mkdir -p build
package_path="$(mktemp -d)"
trap 'rm -rf "$package_path"' EXIT
package_version="$(sed -n 's/^version = "\(.*\)"/\1/p' typst.toml)"
mkdir -p "$package_path/preview/unofficial-monash-touying"
ln -s "$PWD" "$package_path/preview/unofficial-monash-touying/$package_version"

TYPST_PACKAGE_PATH="$package_path" typst compile --root . template/main.typ build/template-main.pdf
TYPST_PACKAGE_PATH="$package_path" typst compile --root . example/main.typ build/example-main.pdf
TYPST_PACKAGE_PATH="$package_path" typst compile --root . docs/reference.typ build/reference.pdf
TYPST_PACKAGE_PATH="$package_path" typst compile --root . --pages 1 template/main.typ thumbnail.png

echo "Compiled template/main.typ, example/main.typ, docs/reference.typ, and thumbnail.png"
