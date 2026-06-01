#!/usr/bin/env bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Walk upward from the script dir to find the project root
ROOT="$SCRIPT_DIR"
while [[ "$ROOT" != "/" && ! -f "$ROOT/typst.toml" ]]; do
  ROOT="$(dirname "$ROOT")"
done
if [[ ! -f "$ROOT/typst.toml" ]]; then
  echo "Error: Could not find typst.toml by walking up from $SCRIPT_DIR" >&2
  exit 1
fi

PKG_DIR="$ROOT"

# MacOS and Linux sed behavior differ, and symlink behavior differs
OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
    TARGET_DIR="$HOME/Library/Application Support/typst/packages/local/simple-research-poster"
    VERSION=$(grep '^version = ' "$PKG_DIR/typst.toml" | sed -E 's/^version = "([^"]+)"/\1/')

    mkdir -p "$TARGET_DIR"
    rm -f "$TARGET_DIR/$VERSION"
    ln -s "$PKG_DIR" "$TARGET_DIR/$VERSION"
    exit 0

elif [[ "$OS" == "Linux" ]]; then
    TARGET_DIR="$HOME/.local/share/typst/packages/local/simple-research-poster"
    VERSION=$(grep -oP '(?<=^version = ").*?(?=")' "$PKG_DIR/typst.toml")

    mkdir -p $TARGET_DIR
    ln -sfn $PKG_DIR "$TARGET_DIR/$VERSION"
    exit 0

fi
exit 2
