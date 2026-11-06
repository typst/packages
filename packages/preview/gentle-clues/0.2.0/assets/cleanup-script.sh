#!/bin/bash

for f in ./*.svg; 
do
  echo "Processing $f file..."
  svgcleaner $f $f
done
