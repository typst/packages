#!/usr/bin/env bash
# Render the example pages that the docs and README show as pictures (seal
# lines, A3 sheets, draft paper and other page-level features) into
# docs/images, and the template's first page into template/thumbnail.png
# (Typst Universe wants its longer edge at least 1080 px).
#
#   scripts/doc-images.sh [--font-path DIR]
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
font_args=()
if [ "${1:-}" = "--font-path" ]; then font_args=(--font-path "$2"); fi
out="$root/docs/images"
mkdir -p "$out"

# name  source  page  extra arguments
shot() {
    local name=$1 src=$2 page=$3; shift 3
    typst compile --root "$root" "${font_args[@]}" --pages "$page" --ppi 110 "$@" \
        "$root/$src" "$out/$name.png"
    echo "docs/images/$name.png"
}

shot sealline-a4      examples/basic/03-real-exam-scenario.typ 1
shot draftpaper       examples/basic/03-real-exam-scenario.typ 3
shot teacher-moved    examples/basic/03-real-exam-scenario.typ 2 --input exam-mode=teacher
shot sealline-a3      examples/example-multiple.typ 3
shot outline          examples/example-multiple.typ 1
shot page-options     tests/page-options.typ 1
shot first-student    examples/basic/01-first-exam.typ 1
shot first-teacher    examples/basic/01-first-exam.typ 1 --input exam-mode=teacher
shot example-single   examples/example-single.typ 1
shot chinese-basic    examples/basic/03-chinese-basic.typ 1
shot english-basic    examples/basic/04-english-basic.typ 1
shot math-basic       examples/basic/02-math-basic.typ 1
shot minimal          examples/basic/00-minimal.typ 1

# The template imports the published package; render it against the sources.
check_template="$root/template/.check.typ"
trap 'rm -f -- "$check_template"' EXIT
sed 's|@preview/exam-zh-next:[0-9.]*|/src/lib.typ|' "$root/template/main.typ" > "$check_template"
typst compile --root "$root" "${font_args[@]}" --pages 1 --ppi 250 "$check_template" "$root/template/thumbnail.png"
echo "template/thumbnail.png"
