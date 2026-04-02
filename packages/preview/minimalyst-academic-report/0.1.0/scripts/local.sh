#!/bin/bash


# package details
NAMESPACE="local"

. "$(dirname "${BASH_SOURCE[0]}")/setup.sh"

# Typst data directory based on OS (fuck windows)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  DATA_DIR="$HOME/Library/Application Support/typst/packages"
else
  # Linux
  DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages"
fi

TARGET_DIR="$DATA_DIR/$NAMESPACE/$PKG_PREFIX/$VERSION"
PARENT_DIR="$DATA_DIR/$NAMESPACE/$PKG_PREFIX"

mkdir -p "$PARENT_DIR"

rm -rf "$TARGET_DIR"

ln -s "$PWD" "$TARGET_DIR"

echo "Done installing dynamic local package"