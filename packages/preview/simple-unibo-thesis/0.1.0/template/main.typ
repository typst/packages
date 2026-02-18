#import "@preview/simple-unibo-thesis:0.1.0": *

#show: thesis.with(
  title: [THESIS TITLE],
  author: "John Doe",
  student-number: "0000000000",
  supervisor: "Prof. Jane Doe",
  graduation-month: "Marchuary",
  academic-year: "1970/1971",
  abstract: [#lorem(250)],
  degree: "Zero-th cycle",
  degree-name: "PLAYMAKING",
  topic: "PLAYTHINGS AND WHATNOT",
  department: "DEPARTMENT OF TYPST",
  locale: "en",
  logo: image("unibo-logo.png"),
)

= Introduction

#lorem(500)

// Bibliography, eg
// #bibliography("references.bib")
