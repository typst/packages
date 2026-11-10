#import "@preview/tidy:0.4.3"
#import "@preview/unofficial-monash-touying:0.1.2" as monash

#set document(title: "Unofficial Monash Touying Reference")
#set page(paper: "a4", margin: 2cm)
#set text(font: ("Arial", "New Computer Modern"), size: 10pt)
#set par(justify: false, leading: .65em)

= Unofficial Monash Touying Reference

This reference is generated from the package's Typst doc comments with
`tidy`. The runtime package does not depend on `tidy`; it is only used for this
documentation document.

#let reference-scope = (monash: monash)

#let frame-docs = tidy.parse-module(
  read("../src/frames.typ"),
  name: "Frame Environments",
  scope: reference-scope,
)
#let theme-docs = tidy.parse-module(
  read("../src/theme.typ"),
  name: "Theme",
  scope: reference-scope,
)
#let design-docs = tidy.parse-module(
  read("../src/design.typ"),
  name: "Design Helpers",
  scope: reference-scope,
)

== Frame Environments

#tidy.show-module(frame-docs, style: tidy.styles.default)

== Theme

#tidy.show-module(theme-docs, style: tidy.styles.default)

== Design Helpers

#tidy.show-module(design-docs, style: tidy.styles.default)
