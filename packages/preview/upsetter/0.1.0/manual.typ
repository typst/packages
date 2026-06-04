#import "@preview/tidy:0.4.3"

#import "/src/lib.typ" as upsetter
#import "/src/deps.typ": *

#let version = toml("/typst.toml").package.version

#set document(title: "upsetter manual")

#align(center)[
  #block(text(weight: "bold", 1.75em, "upsetter"))
  #v(0.15em)
  #text(weight: "bold", 1.6em, "v" + version)
  #v(0.25em)
  
  #line(length: 100%, stroke: black.lighten(60%))
]

#v(1em)

#show heading.where(level: 3): set text(1.4em)

#let docs = tidy.parse-module(
  read("src/lib.typ"),
  scope: (
    upsetter: upsetter,
    cetz: cetz
  )
)

#tidy.show-module(
  docs,
  style: tidy.styles.default,
  show-outline: false,
  omit-private-definitions: true
)
