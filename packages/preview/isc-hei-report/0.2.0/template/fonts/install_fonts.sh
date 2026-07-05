#!/usr/bin/env bash

echo "Installing fonts locally..."

wget https://files.isc-vs.ch/typst/modern-isc-fonts.tar.gz
tar -zxvf modern-isc-fonts.tar.gz

fonts_dir="${HOME}/.local/share/fonts"
if [ ! -d "${fonts_dir}" ]; then
    echo "mkdir -p $fonts_dir"
    mkdir -p "${fonts_dir}"
else
    echo "Found fonts dir $fonts_dir"
fi

cp *.ttf ~/.local/share/fonts/    
cp *.otf ~/.local/share/fonts/    

echo "Rebuilding cache... with fc-cache -f"
fc-cache -f

rm modern-isc-fonts.tar.gz
rm -rf *.ttf
rm -rf *.otf
