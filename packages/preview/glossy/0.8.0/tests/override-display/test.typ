#import "/lib.typ": *

#let myGlossary = (
  html: (
    short: "HTML",
    long: "Hypertext Markup Language",
    description: "A standard language for creating web pages",
    group: "Web"),
  css: (
    short: "CSS",
    long: "Cascading Style Sheets",
    description: "A language used for describing the presentation of a document",
    group: "Web"),
  tps: (
    short: "TPS",
    long: "test procedure specification",
    description: "A document on how to run all the test procedures"),
   unused: "Unused term, which shouldn't print in the glossary."
)

#show: init-glossary.with(myGlossary)

#set page(height: auto, width: 6.5in, margin: 1em, numbering: "1")

= Overriding term display

Here is @html[HTML being overidden].

Here is @css[] (blank).

Here is @tps[TPS with #emph("content")]

#glossary()
