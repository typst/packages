#set page(height: auto)

#import "src/lib.typ": *

= Documentation

The default value of most parameters are `none` for it will use the default value in `zebraw-init`.

#import "@preview/tidy:0.4.2"
#let docs = tidy.parse-module(read("src/mod.typ"), scope: (zebraw: zebraw))
#tidy.show-module(docs, style: tidy.styles.default, sort-functions: false)
