#!/bin/sh
# Regenerates img/*.png from examples/visual_*.typ, and runs examples/_assert_*.typ.
#
# The README points at these images by absolute URL, so they must be regenerated
# and committed whenever the drawing changes — otherwise the package page shows
# a version of the output that no longer exists.
#
# Usage, from the repository root:
#   sh examples/render.sh              # render + assert
#   FONT_PATH=/path/to/fonts sh examples/render.sh
#
# Inter and Noto Color Emoji are what the examples ask for. Without them Typst
# falls back to another family and the images stop matching the real output.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
version=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$root/typst.toml")
: "${FONT_PATH:=$root/fonts}"

# Typst resolves `@preview/tidymind:<version>` through a package path, so point
# one at this very working copy instead of at the published package.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/preview/tidymind"
ln -s "$root" "$work/preview/tidymind/$version"

fonts=""
[ -d "$FONT_PATH" ] && fonts="--font-path $FONT_PATH"

mkdir -p "$root/img"

for f in "$root"/examples/_assert_*.typ; do
  name=$(basename "$f" .typ)
  # A file that compiles is a file whose #assert calls all held.
  # shellcheck disable=SC2086
  typst compile --package-path "$work" --root "$root" $fonts "$f" "$work/out.pdf" \
    && echo "assert  $name" \
    || { echo "FAILED  $name"; exit 1; }
done

for f in "$root"/examples/visual_*.typ; do
  name=$(basename "$f" .typ | sed 's/^visual_//')
  # shellcheck disable=SC2086
  typst compile --package-path "$work" --root "$root" $fonts \
    --format png --ppi 192 "$f" "$root/img/$name.png" \
    && echo "render  img/$name.png" \
    || { echo "FAILED  $name"; exit 1; }
done
