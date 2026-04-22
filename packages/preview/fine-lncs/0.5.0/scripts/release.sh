#!/usr/bin/env bash
#
# Pre-flight checks + Typst Universe publication for fine-lncs.
#
# VERSION is the source of truth. This script verifies that every other
# version reference in the repo matches VERSION, that VERSION is a bump
# over the most recent git tag, and that CI passes — then hands off to
# `typship publish universe`.
#
# Pass --dry-run to run the checks without publishing.

set -euo pipefail

DRY_RUN=0
if [[ ${1:-} == "--dry-run" ]]; then
  DRY_RUN=1
fi

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

fail() {
  echo "release: $*" >&2
  exit 1
}

info() {
  echo "release: $*"
}

# --- Load VERSION --------------------------------------------------------

[[ -f VERSION ]] || fail "VERSION file not found at repo root"
version=$(tr -d '[:space:]' < VERSION)
[[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || fail "VERSION ($version) is not a valid X.Y.Z semver"

info "target version: $version"

# --- Compare to latest git tag ------------------------------------------
#
# Fetch tags from origin so releases that exist on GitHub but haven't been
# pulled locally are still seen. The GitHub tag/release flow is independent
# of Universe publication, so origin is the authoritative source.

info "fetching tags from origin"
git fetch --quiet --tags origin \
  || fail "failed to fetch tags from origin (network? remote name?)"

prev_tag=$(git tag -l 'v*' --sort=-v:refname | head -n1)
if [[ -z $prev_tag ]]; then
  info "no previous release tag — treating as first release"
else
  prev=${prev_tag#v}
  if [[ $prev == "$version" ]]; then
    fail "VERSION matches the latest tag ($prev_tag) — bump VERSION before releasing"
  fi
  highest=$(printf '%s\n%s\n' "$prev" "$version" | sort -V | tail -n1)
  [[ $highest == "$version" ]] \
    || fail "VERSION ($version) is not greater than the latest tag ($prev_tag)"
  info "previous release: $prev_tag"
fi

# --- typst.toml ----------------------------------------------------------

toml_version=$(awk -F'"' '/^version[[:space:]]*=/ { print $2; exit }' typst.toml)
[[ $toml_version == "$version" ]] \
  || fail "typst.toml version ($toml_version) does not match VERSION ($version)"

# --- Scan repo for stale version references -----------------------------
#
# Any occurrence of `fine-lncs:X.Y.Z` must match the target version. This
# covers README examples and the template's own import line.

stale=$(grep -RnE 'fine-lncs:[0-9]+\.[0-9]+\.[0-9]+' \
          --include='*.md' --include='*.typ' --include='*.toml' . \
        | grep -v "fine-lncs:$version" || true)
if [[ -n $stale ]]; then
  echo "release: stale version references found (must match $version):" >&2
  echo "$stale" >&2
  exit 1
fi

# --- Working tree must be clean -----------------------------------------

if [[ -n $(git status --porcelain) ]]; then
  echo "release: working tree is not clean:" >&2
  git status --short >&2
  exit 1
fi

# --- Must be on main ----------------------------------------------------

branch=$(git rev-parse --abbrev-ref HEAD)
[[ $branch == "main" ]] \
  || fail "not on main (currently on $branch)"

# --- Run full CI locally ------------------------------------------------

info "running format + test checks (just ci)"
just ci

# --- Publish ------------------------------------------------------------

if (( DRY_RUN )); then
  info "dry run — skipping publication"
  info "all pre-flight checks passed for $version"
  exit 0
fi

info "all pre-flight checks passed — publishing $version via typship"
typship publish universe
