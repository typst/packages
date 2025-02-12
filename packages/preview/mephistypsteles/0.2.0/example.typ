#set page(height: auto, margin: 1cm)

#import "@preview/mephistypsteles:0.2.0": *

This file:
#block(fill: luma(95%), outset: 6pt, radius: 3pt, raw(read("example.typ"), block: true, lang: "typst"))

Parse flat:
#block[#set text(5pt);#parse(read("example.typ"), flat: true)]

Parse markup:
#block[#set text(5pt);#parse(read("example.typ")))]

Operator info:
- Unary: #operator-info("not")
- Binary: #operator-info("and")
- Both: #operator-info("+")
