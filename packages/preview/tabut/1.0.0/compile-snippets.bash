#!/bin/bash

# Define the absolute paths for the source, destination, and temporary directories
SOURCE_DIR="$PWD/doc/example-snippets"
DEST_DIR="$PWD/doc/compiled-snippets"
TMP_DIR="/dev/shm/my_temp_dir"

# Create and setup the temporary directory
mkdir -p "$TMP_DIR"
cp -r "$SOURCE_DIR/"* "$TMP_DIR"

# Check if the destination directory exists, if not, create it
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
else
    # If the directory exists, clear its contents
    rm -rf "${DEST_DIR:?}"/*
fi

# Loop through each .typ file in the temporary directory
for file in "$TMP_DIR"/*.typ; do
    if [ -f "$file" ]; then
        # Extract the filename without the extension
        filename=$(basename "${file%.*}")

        # Output the name of the file being processed
        echo "Processing file: $filename.typ"

        # Create a new temporary file for compilation in the same directory
        temp_file="$TMP_DIR/$filename.temp"

        # Prepend the required string to the new temp file
        echo "#set page(background: box(width: 100%, height: 100%, fill: luma(97%)), width: auto, height: auto, margin: 2pt)" > "$temp_file"

        # Append the contents of the original file to the new temp file
        cat "$file" >> "$temp_file"

        # Compile the new temp file to SVG format
        typst compile "$temp_file" "$DEST_DIR/$filename.svg"

        # Remove the new temporary file
        rm "$temp_file"
    fi
done

# Clean up: remove the temporary directory and its contents
rm -rf "$TMP_DIR"

echo "All files have been processed."
