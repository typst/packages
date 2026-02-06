
#import "../src/lib.typ" as percencode

#import "@preview/tidy:0.4.3"

#let version = toml("../typst.toml").package.version

#align(center)[

  #stack(
    spacing: 14pt,
    text(2.7em, `percencode`),
    [_utility library for URL en- and decoding_],
  )

  #v(15pt)

  #percencode.percent-encode("Percent Encoding") #sym.dash Percent Encoding

  #v(15pt)

  A #link("https://typst.app/")[Typst] package for URL encoding and decoding.

  #link("https://github.com:Servostar/typst-percencode.git")[`github.com:Servostar/typst-percencode.git`]

  *Version #version*
]

= Documentation

This library offers function for encoding and decoding percent escape sequences.
These are typically used to encode unsafe or non-ASCII characters in URLs.
Supported by this library is only Typst's native character encoding and defacto web standard: UTF-8.

#v(12pt)

#import "../src/encode.typ" as encode
#let docs = tidy.parse-module(
  read("../src/encode.typ"),
  name: "Percent Encoding",
  scope: (percencode: encode)
)
#tidy.show-module(docs, style: tidy.styles.default)

#import "../src/decode.typ" as decode
#let docs = tidy.parse-module(
  read("../src/decode.typ"),
  name: "Percent Decoding",
  scope: (percencode: decode)
)
#tidy.show-module(docs, style: tidy.styles.default)
