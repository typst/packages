#import "/lib.typ": *

#let myGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
  ),
  iphone: (
    short: "iPhone",
    description: "Revolutionized phones."
  ),
  css: (
    short: "CSS",
    long: "Cascading Style Sheets",
    description: "A language used for describing the presentation of a document",
  ),
  atom: (
    short: "atom",
  ),
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document on how to run all the test procedures"
  ),
)

#show: init-glossary.with(myGlossary, show-term: (body) => [#emph(body)])

#set page(
  margin: 1cm,
  height: auto,
  numbering: "1",
)

#text(size: 24pt, weight: "bold")[`glossy`: theme gallery]

#text(size: 1pt, fill: rgb(0,0,0,0))[
  First, we refer to each term at least once so they'll actually show up in the
  glossaries. Our terms include: @atom, @iphone, @html:cap, @css, and @tps.
]
#v(-2em)

#import "/src/themes.typ"
#for theme in dictionary(themes) {
  block(
    breakable: false,
    width: 100%,
    spacing: 2em,
    inset: 1em,
    stroke: 1pt+gray,
    height: if theme.first() == "theme-twocol" { 1.5in } else { auto },
    glossary(title: raw(theme.first()), theme: theme.last(), ignore-case: true)
  )
}
