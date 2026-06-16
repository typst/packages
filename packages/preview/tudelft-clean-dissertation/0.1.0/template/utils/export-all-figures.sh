#!/bin/sh

ls
# Recurse down from the parent directory (the repo root) and find and dir with "figure-source.svg"
# and then export to a plain svg with name "fig.svg"

find .. -type f -name "figure-source.svg" | while read -r file; do
    # Get the directory name from the file path
    dir=$(dirname "$file")
    echo "$dir"
    # Change into the directory containing the file
    cd "$dir"
    
    # Run Inkscape with the specified actions
    inkscape figure-source.svg --actions="export-filename:fig.pdf;export-do;file-close"

    cd -
done