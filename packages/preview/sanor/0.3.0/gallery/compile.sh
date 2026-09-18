#!/bin/bash

# Loop through every file ending in .typ
for file in *.typ; do
    # Get the filename without the extension (e.g., "main" instead of "main.c")
    filename="${file%.*}"
    version="0.3.0"
    
    echo "Compiling $file..."

    sed -i "s|#import \"@preview/sanor:$version\": \*|#import \"../src/lib.typ\": \*|g" "$file"


    typst c "$file" --format=png --root .. "$filename{0p}.png"
    typst c "$file" --root ..

    sed -i "s|#import \"../src/lib.typ\": \*|#import \"@preview/sanor:$version\": \*|g" "$file"

    ffmpeg -framerate 1.5 -i $filename%d.png $filename.gif
    rm *.png
done

for file in *.pdf; do 
    mv "$file" ../assets/
done

echo "Done!"
