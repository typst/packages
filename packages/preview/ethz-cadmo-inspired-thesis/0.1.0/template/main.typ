#import "@preview/ethz-cadmo-inspired-thesis:0.1.0": *

#show: setup.with(
  "My Thesis Title", // title
  "Jane Doe", // author
  ("Advisor One", "Advisor Two"), // advisors
  thesis-type: "Bachelor Thesis",
  department: "Department of Computer Science",
  bib: bibliography("bib.bib", title: none),
)

// Front matter (unnumbered, roman page numbers)
#frontchapter[Abstract]

This thesis is about ...

#outline(depth: 3)

// Main body (arabic page numbers, counters reset)
#show: mainmatter

= Introduction

Some introductory text.

= Background

Some background.

#show: appendix

#frontchapter[Appendix]

== Appendix A
