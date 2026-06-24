#!/usr/bin/env bash

# for package testing purposes
# Just "deploys" a local copy of the package instead of to typst universe

# using more readidily available fonts for open package
# export TYPST_FONT_PATHS=$(realpath Fonts)


PACKAGE_NAME="codepoint"
# local imports will break if this does not match the typst.toml
VERSION="0.0.1"

# for windows you'll need WSL

if [[ "$OSTYPE" == "darwin"* ]]; then
    DATA_DIR="$HOME/Library/Application Support/typst/packages/local"
else
    DATA_DIR="$HOME/.local/share/typst/packages/local"
fi

DEST="$DATA_DIR/$PACKAGE_NAME/$VERSION"

if [ -d "$DEST" ]; then
    echo "Cleaning existing package at $DEST"
    rm -rf "$DEST"
fi

mkdir -p "$DEST"

cp -R themes src lib.typ typst.toml "$DEST"


echo "Package installed to local: @local/$PACKAGE_NAME:$VERSION"
echo "Import accordingly"