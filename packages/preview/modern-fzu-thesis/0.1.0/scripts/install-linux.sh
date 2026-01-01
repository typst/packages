#!/bin/bash

# Define variables
PACKAGE_NAME="modern-fzu-thesis"
PACKAGE_VERSION="0.1.0"
NAMESPACE="local"
SOURCE_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
TARGET_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/$NAMESPACE/$PACKAGE_NAME/$PACKAGE_VERSION"

# Display information
echo "===== Fuzhou University Thesis Template Installation Script ====="
echo "Source directory: $SOURCE_DIR"
echo "Target directory: $TARGET_DIR"

# Create target directory
mkdir -p "$TARGET_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Unable to create target directory"
    exit 1
fi

# Copy files to target directory
echo "Copying files..."
cp -r "$SOURCE_DIR"/* "$TARGET_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files"
    exit 1
fi

echo "Installation complete!"
echo "You can import the template in your Typst file using:"
echo "#import \"@$NAMESPACE/$PACKAGE_NAME:$PACKAGE_VERSION\": *"
echo "Or create a new document using the template: typst init @$NAMESPACE/$PACKAGE_NAME"