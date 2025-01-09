#import "/lib.typ": *

#let myGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
  ),
  iphone: (
    short: "iPhone",
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

#show: init-glossary.with(myGlossary)

#set page(numbering: "i")

@html, @iphone, @css

#pagebreak()

#set page(numbering: "1")

@html, @iphone, @css, @atom

#pagebreak()

#counter(page).update(1)
#set page(numbering: "A")

@html, @iphone, @css, @tps

#pagebreak()

#set page(numbering: "I")
@css, @iphone, @tps

#glossary(theme: theme-chicago-index, ignore-case: true)
