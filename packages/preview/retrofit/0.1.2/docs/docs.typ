#import "@preview/tidy:0.4.3"

#set page(height: auto)
#set text(font: "IBM Plex Sans")
#show raw: set text(1.1em)

#let docs = tidy.parse-module(read("../src/lib.typ"), name: "Retrofit")
#tidy.show-module(docs, show-outline: false)
