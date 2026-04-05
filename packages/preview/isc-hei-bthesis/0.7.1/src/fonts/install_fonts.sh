#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
VU="${GREEN}✔${NC}"

echo -e "Downloading and installing fonts locally..."

fonts_dir="${HOME}/.local/share/fonts"

wget https://files.isc-vs.ch/typst/modern-isc-fonts.tar.gz

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to download modern-isc-fonts.tar.gz from the web.${NC}"
    exit 1
fi

echo -e "Fonts downloaded successfullly $VU"

tar -zxvf modern-isc-fonts.tar.gz

if [ ! -d "${fonts_dir}" ]; then
    echo "mkdir -p $fonts_dir"
    mkdir -p "${fonts_dir}"
    echo -e "Created fonts directory $fonts_dir $VU"
else
    echo -e "Found fonts directory $fonts_dir $VU"
fi

cp modern-isc-fonts/*.ttf ${fonts_dir}
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to copy .ttf files.${NC}"
    exit 1
else
    echo -e "Copied .ttf files $VU"
fi

cp modern-isc-fonts/*.otf ${fonts_dir}
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to copy .otf files.${NC}"
    exit 1
else
    echo -e "Copied .otf files $VU"
fi

echo -e "Rebuilding cache with fc-cache -f $VU"
fc-cache -f

rm modern-isc-fonts.tar.gz
rm -rf *.ttf
rm -rf *.otf

# Check if required fonts are available in typst fonts
missing_fonts=()
for font in "Source Sans 3" "Inria Sans" "Fira Code"; do
    if ! typst fonts | grep -q "$font"; then
        missing_fonts+=("$font")
    fi
done

if [ ${#missing_fonts[@]} -eq 0 ]; then
    echo -e "${VU} All required fonts found within Typst fonts. Install seems to be OK!${NC}"
else
    echo -e "${RED}Error: The following fonts were not found in Typst fonts: ${missing_fonts[*]}. There's something wrong here.${NC}"
    exit 1
fi
