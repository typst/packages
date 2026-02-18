#import "@preview/simple-unibo-thesis:0.1.0": *

#show: thesis.with(
  title: [THESIS TITLE],
  author: "John Doe",
  student-number: "0000000000",
  supervisor: "Jane Doe",
  graduation-month: "Marchuary",
  academic-year: "1970/1971",
  abstract: [#lorem(250)],
  degree: "Zero-th cycle",
  program: "PLAYTHINGS AND WHATNOT",
  department: "DEPARTMENT OF TYPST",
  locale: "en",
)

= Introduction

#lorem(500)

// Bibliography, eg
// #bibliography("references.bib")
