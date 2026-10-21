#!/usr/bin/env bash
# Compile every example (student and teacher version), the tests and both
# docs. Fails on any compiler error or warning. The docs show pages rendered
# by scripts/doc-images.sh; rerun it after changing the examples.
#
#   scripts/check.sh [--font-path DIR] [--out DIR]
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/out"
font_args=()
while [ $# -gt 0 ]; do
    case "$1" in
        --font-path) font_args=(--font-path "$2"); shift 2 ;;
        --out) out=$2; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done
mkdir -p "$out"

status=0
compile() {
    local src=$1 name=$2; shift 2
    local log
    if ! log=$(typst compile --root "$root" "${font_args[@]}" "$@" "$src" "$out/$name.pdf" 2>&1); then
        echo "FAIL  $name"; echo "$log"; status=1
    elif grep -q '^warning' <<<"$log"; then
        echo "WARN  $name"; echo "$log"; status=1
    else
        echo "ok    $name"
    fi
}

# The template imports the published package; check it against the sources.
check_template="$root/template/.check.typ"
trap 'rm -f -- "$check_template"' EXIT
sed 's|@preview/exam-zh-next:[0-9.]*|/src/lib.typ|' "$root/template/main.typ" > "$check_template"

for src in "$root"/examples/*.typ "$root"/examples/basic/*.typ "$check_template"; do
    name=$(basename "$src" .typ)
    [ "$name" = ".check" ] && name=template
    compile "$src" "$name"
    compile "$src" "$name-teacher" --input exam-mode=teacher
done
for src in "$root"/tests/*.typ; do compile "$src" "test-$(basename "$src" .typ)"; done
compile "$root/docs/guide.typ" guide
compile "$root/docs/reference.typ" reference

exit $status
