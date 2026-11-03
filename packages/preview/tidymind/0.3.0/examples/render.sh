#!/bin/sh
# Regenerates img/*.png from examples/visual_*.typ, and runs examples/_assert_*.typ.
#
# The README points at these images by absolute URL, so they must be regenerated
# and committed whenever the drawing changes — otherwise the package page shows
# a version of the output that no longer exists.
#
# Usage, from the repository root:
#   FONT_PATH=/path/to/fonts sh examples/render.sh    # assert + render
#
# FONT_PATH is required (unless the fonts are installed system-wide): it must
# hold Inter and Noto Color Emoji, which the examples ask for. DejaVu Sans Mono,
# the default mono-font, ships inside Typst. A missing font makes Typst warn,
# and any warning fails the run (see `clean` below). FONT_PATH defaults to
# ./fonts, which is not in the repository.
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

# A warning fails the run too: Typst warns, and still compiles, when it drops
# content (e.g. a block inside a paragraph), which no #assert would notice.
clean() {
  if grep -q "warning" "$work/err"; then echo "WARNING in $1"; return 1; fi
}

for f in "$root"/examples/_assert_*.typ; do
  name=$(basename "$f" .typ)
  # A file that compiles is a file whose #assert calls all held.
  # shellcheck disable=SC2086
  typst compile --package-path "$work" --root "$root" $fonts "$f" "$work/out.pdf" 2>"$work/err" \
    && clean "$name" && echo "assert  $name" \
    || { cat "$work/err"; echo "FAILED  $name"; exit 1; }
done

for f in "$root"/examples/visual_*.typ; do
  name=$(basename "$f" .typ | sed 's/^visual_//')
  # shellcheck disable=SC2086
  typst compile --package-path "$work" --root "$root" $fonts \
    --format png --ppi 192 "$f" "$root/img/$name.png" 2>"$work/err" \
    && clean "$name" && echo "render  img/$name.png" \
    || { cat "$work/err"; echo "FAILED  $name"; exit 1; }
done
