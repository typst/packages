#!/usr/bin/env bash
# Regenerate everything the comparison page loads.
#
#   ./examples/nepo/comparisons/build.sh
#
# Needs `typst` and `node` on PATH. Run from anywhere.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../../.." && pwd)"

echo "==> candidate SVGs (Blockst)"
# Removed first: Typst pads the page number to the width of the page count, so
# a sheet that grows past nine blocks renames every file it writes and would
# otherwise leave the old ones behind.
rm -f "$here"/candidates/block-*.svg
typst compile "$here/blocks.typ" "$here/candidates/block-{n}.svg" --root "$root"

echo "==> full prototype sheet"
typst compile "$root/examples/nepo/calliope-prototype.typ" \
  "$root/examples/nepo/calliope-prototype.svg" --root "$root"

echo "==> geometry reference (independent Blockly transcription)"
node "$root/examples/nepo/references/blockly-reference.mjs" \
  > "$root/examples/nepo/references/reference.json"

# index.html is opened straight off the disk, where fetch() is blocked. A
# script tag is not, so the numbers ship as an assignment.
{
  printf 'window.NEPO_REFERENCE = '
  cat "$root/examples/nepo/references/reference.json"
  printf ';\n'
} > "$here/reference.js"

echo "==> done"
