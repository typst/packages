#!/usr/bin/env sh
# Build the beginner guide and every standalone example.
set -eu

TYPST="${TYPST:-typst}"
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

"$TYPST" compile --root "$ROOT" --font-path "$ROOT/assets/fonts" \
  "$ROOT/docs/guide.typ" "$ROOT/docs/guide.pdf"

"$TYPST" compile --root "$ROOT" --font-path "$ROOT/assets/fonts" \
  "$ROOT/docs/guide-ar.typ" "$ROOT/docs/guide-ar.pdf"

"$TYPST" compile --root "$ROOT" --font-path "$ROOT/assets/fonts" \
  "$ROOT/docs/gallery.typ" "$ROOT/docs/gallery.pdf"

for source in "$ROOT"/examples/*.typ; do
  target="${source%.typ}.pdf"
  "$TYPST" compile --root "$ROOT" --font-path "$ROOT/assets/fonts" \
    "$source" "$target"
done
