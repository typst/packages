#import "@preview/unify:0.8.1": qty
#import "@preview/drafting:0.2.2"
#import "@preview/tudelft-thesis-novanext:0.1.0": subtitle, thesis, thesis-classic, front-matter, main-matter, appendix, back-matter, ipsum

#set document(
  title: [A TU Delft Thesis Template for~Typst],
  author: "L. I. D. Sit-Amet",
  date: datetime(
    year: 2020,
    month: 10,
    day: 4,
  ),
)
#subtitle.update([Optional subtitle])

#show: thesis
// #show: thesis-classic
#show: front-matter

#include "title.typ"
#include "summary.typ"
#include "samenvatting.typ"

#outline()

// alternatively:#import "@preview/symbolist:0.1.0": *
#import "@preview/nomos:0.1.0": *
#print-nomenclature(
  value: false,
  domain: false,
  outlined: true,
)

#show: main-matter
#include("introduction.typ")
#include("awesomedoc.typ")

#show: appendix.with(side: "even")
#include("appendix.typ")

#show: back-matter
= Back matter
== Section
#ipsum(50, 100)

#ipsum(30, 150)

= One more chapter
#ipsum(30, 180)

== Section
#ipsum(20, 210)

- #ipsum(2, 230)
- #ipsum(3, 232)
- #ipsum(1, 234)

#import "@preview/sanity:0.2.0": sanity
#show: sanity.with(
  checks: (
    // missing-label: false,
    unreferenced-footnote: false,
  )
)
#import "@preview/drafting:0.2.2": *
#note-outline()
