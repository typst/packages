#set page(height: auto, margin: 1cm)

#import "@preview/mephistypsteles:0.1.0": *

This file:
#block(fill: luma(95%), outset: 6pt, radius: 3pt, raw(read("example.typ"), block: true, lang: "typst"))

Parse flat:
#block[#set text(5pt);#parse-flat(read("example.typ"))]

Parse markup:
#block[#set text(5pt);#parse-markup(read("example.typ")))]

Operator info:
- Unary: #operator-info("not")
- Binary: #operator-info("and")
- Both: #operator-info("+")
