#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

mkdir -p /tmp/codez-check

printf 'Compiling curated examples...\n'
typst compile --root . examples/mlir-swiglu-matmul.typ /tmp/codez-check/mlir-swiglu-matmul.pdf
typst compile --root . examples/mlir-to-systemverilog-poster.typ /tmp/codez-check/mlir-to-systemverilog-poster.pdf

printf 'Curated example compiles succeeded.\n'
