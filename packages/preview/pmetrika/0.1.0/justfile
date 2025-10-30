thumbnail:
    cp template/{main.typ,refs.bib} .
    sed -i '' '/^#import/s/"[^"]*"/"lib.typ"/' main.typ
    curl https://imgs.xkcd.com/comics/data_point.png > data-point.png
    typst compile -f png --pages 1 --ppi 250 main.typ thumbnail.png
    oxipng -o 4 --strip safe --alpha thumbnail.png
    rm main.typ refs.bib data-point.png
