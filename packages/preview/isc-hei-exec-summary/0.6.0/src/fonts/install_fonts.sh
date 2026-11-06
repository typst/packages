#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Installing fonts locally..."

fonts_dir="${HOME}/.local/share/fonts"

wget https://files.isc-vs.ch/typst/modern-isc-fonts.tar.gz

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to download modern-isc-fonts.tar.gz from the web.${NC}"
    exit 1
fi

tar -zxvf modern-isc-fonts.tar.gz

if [ ! -d "${fonts_dir}" ]; then
    echo "mkdir -p $fonts_dir"
    mkdir -p "${fonts_dir}"
else
    echo "Found fonts dir $fonts_dir"
fi

cp modern-isc-fonts/*.ttf ~/.local/share/fonts/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to copy .ttf files.${NC}"
    exit 1
fi

cp modern-isc-fonts/*.otf ~/.local/share/fonts/
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to copy .otf files.${NC}"
    exit 1
fi

echo "Rebuilding cache... with fc-cache -f"
fc-cache -f

rm modern-isc-fonts.tar.gz
rm -rf *.ttf
rm -rf *.otf

echo "Fonts installed successfully."