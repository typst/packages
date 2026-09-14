#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

mkdir -p /tmp/codez-check
package_root="/tmp/codez-local-packages"
package_link="$package_root/preview/codez/0.1.0"

rm -rf "$package_root"
mkdir -p "$(dirname "$package_link")"
ln -s "$repo_root" "$package_link"

printf 'Compiling curated examples...\n'
typst compile --root . --package-path "$package_root" examples/mlir-swiglu-matmul.typ /tmp/codez-check/mlir-swiglu-matmul.pdf
typst compile --root . --package-path "$package_root" examples/mlir-to-systemverilog-poster.typ /tmp/codez-check/mlir-to-systemverilog-poster.pdf

printf 'Curated example compiles succeeded.\n'
