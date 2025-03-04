#import "/lib.typ": *

#let myGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
  ),
  iphone: (
    short: "iPhone",
    long: "iPhone",
  ),
  css: (
    short: "CSS",
    long: "Cascading Style Sheets",
    description: "A language used for describing the presentation of a document",
  ),
  atom: (
    short: "atom",
    long: "atom",
  ),
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document on how to run all the test procedures"
  ),
)

#show: init-glossary.with(myGlossary, show-term: (body) => [#emph(body)])

#set page(numbering: "1")

= Refer to our terms so they show up in the glossary
@html, @iphone:long, @css, @css:cap:pl, @atom:pl, @tps:long

= Default sorting
#glossary(theme: theme-compact)

= Case-insensitive sorting (`ignore-case: true`)
#glossary(ignore-case: true, theme: theme-compact)
