#import "@preview/tidy:0.3.0"
#set text(font: "Arial")
#set heading(numbering: "1.1")

#let docs = tidy.parse-module(read("lib.typ"))
#tidy.show-module(docs, style: tidy.styles.default)

