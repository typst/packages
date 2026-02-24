#!/usr/bin/bash
cd ../examples

for i in *.pdf; do
    echo ${i/.pdf/}
    pdftoppm $i ../img/${i/.pdf/} -png
done

cd ../img