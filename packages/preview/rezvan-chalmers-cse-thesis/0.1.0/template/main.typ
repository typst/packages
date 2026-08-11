#import "@preview/rezvan-chalmers-cse-thesis:0.1.0": template, appendices

#let department = "Department of Computer Science and Engineering"

#show: template.with(
  title: "Your Thesis Title",
  subtitle: "An optional subtitle",
  authors: ("Your Name",),
  department: department,
  subject: "Computer Science and Engineering",
  supervisor: ("Supervisor Name", department),
  examiner: ("Examiner Name", department),
  abstract: [Write your abstract here.],
  acknowledgements: [Write your acknowledgements here.],
  keywords: ("keyword-1", "keyword-2"),
  cover-caption: none,
  printed-by: none,
)

= Introduction

Start writing your thesis content here.

#show: appendices
= Appendix

Appendix content.
