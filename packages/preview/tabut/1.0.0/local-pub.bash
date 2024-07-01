#!/bin/bash

# Define the base directory
BASE_DIR="$HOME/.local/share/typst/packages/preview"

# Extract the name and version from typst.toml
PACKAGE_NAME=$(awk -F'"' '/name/ {print $2; exit}' typst.toml)
PACKAGE_VERSION=$(awk -F'"' '/version/ {print $2; exit}' typst.toml)

# Construct the destination directory path
DEST_DIR="$BASE_DIR/$PACKAGE_NAME/$PACKAGE_VERSION"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Clear the contents of the destination directory
rm -rf "${DEST_DIR:?}"/*

# Copy all contents of the current directory to the destination directory, excluding .git
rsync -a --exclude='.git' ./ "$DEST_DIR/"

# Output the operation completion
echo "Contents copied to $DEST_DIR"

