#import "@preview/simple-unibo-thesis:0.1.0": *

#show: thesis.with(
  title: [THESIS TITLE],
  author: "John Doe",
  student_number: "0000000000",
  supervisor: "Jane Doe",
  graduation_month: "Marchuary",
  academic_year: "1970/1971",
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
