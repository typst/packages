#!/usr/bin/env bash
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 <pdf-file>"
    exit 1
fi

PDF="$1"

echo "Checking PDF file before submission: $PDF"

if ! command -v pdfinfo >/dev/null 2>&1; then
    echo "Error: pdfinfo not found. Install poppler-utils package."
    exit 2
fi

if ! command -v pdffonts >/dev/null 2>&1; then
    echo "Error: pdffonts not found. Install poppler-utils package."
    exit 2
fi

subject_line=$(pdfinfo "$PDF" | grep '^Subject:')

if [[ $subject_line =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    version="${BASH_REMATCH[1]}"
    # Compare version with 0.5.3
    IFS='.' read -r major minor patch <<< "$version"
    if (( major > 0 )) || (( major == 0 && minor > 5 )) || (( major == 0 && minor == 5 && patch > 3 )); then
        # Check for SourceSans font
        if pdffonts "$PDF" | grep -q 'SourceSans'; then
            echo -e "\e[32m✔\e[0m Document using a valid template version: $version"
            echo -e "\e[32m✔\e[0m SourceSans font found in PDF."
            exit 0
        else
            echo -e "\e[31m✗\e[0m Document is not using SourceSans font in PDF. Please install the required fonts (see fonts/install_fonts.sh)."
            exit 5
        fi
    else
        echo -e "\e[31m✗\e[0m Invalid template version used: $version (must be > 0.5.3)"
        exit 3
    fi
else
    echo -e "\e[31m✗\e[0m Template information not found or does not match required format."
    exit 4
fi