#!/usr/bin/env bash
#
# Bump the package version across every file that references it:
# VERSION, typst.toml, template/main.typ, README.md examples.
# Does not commit — leaves the diff in the working tree for review.
#
# Usage: scripts/bump-version.sh <new-version>

set -euo pipefail

[[ $# -eq 1 ]] || { echo "usage: $0 <new-version>" >&2; exit 1; }
new=$1
[[ $new =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || { echo "error: '$new' is not valid X.Y.Z semver" >&2; exit 1; }

repo=$(git rev-parse --show-toplevel)
cd "$repo"

old=$(tr -d '[:space:]' < VERSION)
if [[ $old == "$new" ]]; then
  echo "already at $new"
  exit 0
fi
echo "bump: $old → $new"

echo "$new" > VERSION

perl -i -pe "s/^version = \"\\d+\\.\\d+\\.\\d+\"/version = \"$new\"/" typst.toml

grep -RlE 'fine-lncs:[0-9]+\.[0-9]+\.[0-9]+' \
     --exclude-dir=.git \
     --include='*.md' --include='*.typ' --include='*.toml' . \
  | while IFS= read -r f; do
      perl -i -pe "s|fine-lncs:\\d+\\.\\d+\\.\\d+|fine-lncs:$new|g" "$f"
    done

echo "done — review with: git diff"
