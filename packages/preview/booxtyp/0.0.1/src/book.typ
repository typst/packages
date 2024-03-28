#import "page-header.typ": page-header-rules
#import "outline.typ": outline-rules
#import "paragraph.typ": paragraph-rules
#import "sectioning.typ": chapter-rules, section-rules
#import "equation.typ": equation-rules
#import "reference.typ": reference
#import "theorems/mod.typ": theorem-rules
#import "figure.typ": figure-rules

#let book(body, toc-title: "Table of Contents") = {
  show: page-header-rules
  show: outline-rules
  // show: paragraph-rules
  show: figure-rules
  show: chapter-rules
  show: section-rules
  show: equation-rules
  show: reference
  show: theorem-rules

  body
}

