# University of Melbourne Thesis Template

A Typst package README for the package registry and quick usage.

# Usage

#import "lib.typ": thesis

#let metadata = (
  title: "A Minimal Test Thesis",
  author: "Test Author",
  degree: "Master of Testing",
  university: "University of Melbourne",
)

#thesis(metadata.title, author: metadata.author, degree: metadata.degree) [
  text[This is a minimal usage example of the package.]
]
