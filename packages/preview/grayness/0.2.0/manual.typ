#import "@preview/tidy:0.3.0"

= Grayness
This package provides basic image editing functions. All of them work with Raster Data (e.g. "normal" Images like PNG or JPEG). The `grayscale-image` function also works with Vector Data (SVG).

The Following functions are available:

#let docs = tidy.parse-module(read("lib.typ"))
#tidy.show-module(docs, style: tidy.styles.default)