#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

mkdir -p docs/previews

printf 'Compiling curated examples for previews...\n'
typst compile --root . examples/mlir-swiglu-matmul.typ docs/previews/mlir-swiglu-matmul.pdf
typst compile --root . examples/mlir-to-systemverilog-poster.typ docs/previews/mlir-to-systemverilog-poster.pdf

# Main README preview images (first page of each curated PDF).
pdftoppm -r 220 -f 1 -singlefile -png docs/previews/mlir-swiglu-matmul.pdf docs/previews/mlir-swiglu-matmul
pdftoppm -r 220 -f 1 -singlefile -png docs/previews/mlir-to-systemverilog-poster.pdf docs/previews/mlir-to-systemverilog-poster

# Trimmed thumbs used in the compact preview gallery.
magick docs/previews/mlir-swiglu-matmul.png -trim +repage -resize 1000x docs/previews/mlir-swiglu-matmul-thumb.png
magick docs/previews/mlir-to-systemverilog-poster.png -trim +repage -resize 1000x docs/previews/mlir-to-systemverilog-poster-thumb.png

# Per-feature previews: one page per feature (stacked vertically in README).
pdftoppm -r 220 -f 1 -singlefile -png docs/previews/mlir-swiglu-matmul.pdf docs/previews/feature-llama-python-math
pdftoppm -r 220 -f 2 -singlefile -png docs/previews/mlir-swiglu-matmul.pdf docs/previews/feature-mlir-swiglu-sigmoid
pdftoppm -r 220 -f 3 -singlefile -png docs/previews/mlir-swiglu-matmul.pdf docs/previews/feature-mlir-swiglu-matmul
pdftoppm -r 220 -f 4 -singlefile -png docs/previews/mlir-swiglu-matmul.pdf docs/previews/feature-mlir-matmul-lowering
pdftoppm -r 220 -f 5 -singlefile -png docs/previews/mlir-swiglu-matmul.pdf docs/previews/feature-mlir-fixed-point-chunk

pdftoppm -r 220 -f 1 -singlefile -png docs/previews/mlir-to-systemverilog-poster.pdf docs/previews/feature-comb-ir-mul-48b
pdftoppm -r 220 -f 2 -singlefile -png docs/previews/mlir-to-systemverilog-poster.pdf docs/previews/feature-comb-ir-add-path
pdftoppm -r 220 -f 3 -singlefile -png docs/previews/mlir-to-systemverilog-poster.pdf docs/previews/feature-systemverilog-always-ff

# Remove page whitespace so README images stack tightly.
for feature_png in docs/previews/feature-*.png; do
  magick "$feature_png" -trim +repage "$feature_png"
done

printf 'Preview assets regenerated under docs/previews/.\n'
