/*
* Documentation of the functions used in the template, powered by tidy.
*/

#import "@preview/tidy:0.3.0"
#let version = toml("/typst.toml").package.version

= brilliant-CV
= Documentation on Template Functions

#h(10pt)

#rect[
  _Build Date: #datetime.today().display()_

  _Version: #version _
]

#h(10pt)

#let docs = tidy.parse-module(read("/cv.typ"))
#tidy.show-module(
  docs,
  show-outline: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
)
