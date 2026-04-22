#!/usr/bin/env bash
#
# Regenerate test files that pin the template and the README example to
# the current in-work library (src/lib.typ) instead of the published
# @preview/fine-lncs version. The generated files are committed; pass
# --check to fail the script if regeneration produced any drift against
# the committed copy (used by CI).

set -euo pipefail

CHECK=0
if [[ ${1:-} == "--check" ]]; then CHECK=1; fi

repo=$(git rev-parse --show-toplevel)
cd "$repo"

mkdir -p tests/template tests/readme

# --- tests/template/test.typ --------------------------------------------
#
# Start from template/main.typ verbatim. Rewrite the @preview import to
# the local lib, and prefix references to template-dir assets so they
# resolve from tests/template/.

assets=()
for f in template/*; do
  case "$f" in
    *.typ) ;;
    *) assets+=("$(basename "$f")") ;;
  esac
done

{
  perl -pe '
    s|^#import "\@preview/fine-lncs:[0-9.]+"|#import "../../src/lib.typ"|;
  ' template/main.typ
} > tests/template/test.typ

for asset in "${assets[@]}"; do
  perl -i -pe "s|\"\\Q${asset}\\E\"|\"../../template/${asset}\"|g" \
    tests/template/test.typ
done

# --- tests/readme/test.typ ----------------------------------------------
#
# Extract the first fenced ```typst block from README.md and rewrite its
# import the same way. refs.bib is also rewritten so bibliography() in
# the example resolves to the template's sample file.

perl -ne '
  if (!$in && /^```typst\s*$/) { $in = 1; next; }
  if ($in) {
    last if /^```\s*$/;
    print;
  }
' README.md \
  | perl -pe '
      s|^#import "\@preview/fine-lncs:[0-9.]+"|#import "../../src/lib.typ"|;
      s|"refs\.bib"|"../../template/refs.bib"|g;
    ' > tests/readme/test.typ

echo "regenerated:"
echo "  tests/template/test.typ"
echo "  tests/readme/test.typ"

if (( CHECK )); then
  out=$(git status --porcelain -- tests/template/test.typ tests/readme/test.typ)
  if [[ -n $out ]]; then
    echo "drift: generated tests are out of sync. Run 'just gen-tests' and commit." >&2
    echo "$out" >&2
    git diff -- tests/template/test.typ tests/readme/test.typ >&2 || true
    exit 1
  fi
  echo "generated tests are up to date"
fi
