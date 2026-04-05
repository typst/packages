#import "@preview/classic-jmlr:0.4.0": jmlr
#import "/blindtext.typ": blindtext, blindmathpaper

#let affls = (
  one: (
    department: "Department of Statistics",
    institution: "University of Washington",
    location: "Seattle, WA 98195-4322",
    country: "USA"),
  two: (
    department: "Division of Computer Science",
    institution: "University of California",
    location: "Berkeley, CA 94720-1776",
    country: "USA"),
)

#let authors = (
  (name: "Author One",
   affl: "one",
   email: "one@stat.washington.edu"),
  (name: "Author Two",
   affl: "two",
   email: "two@cs.berkeley.edu"),
)

#show: jmlr.with(
  title: [Sample JMLR Paper],
  authors: (authors, affls),
  abstract: blindtext,
  keywords: ("keyword one", "keyword two", "keyword three"),
  bibliography: bibliography("main.bib"),
  appendix: include "appendix.typ",
  pubdata: (
    id: "21-0000",
    editor: "My editor",
    volume: 23,
    submitted-at: datetime(year: 2021, month: 1, day: 1),
    revised-at: datetime(year: 2022, month: 5, day: 1),
    published-at: datetime(year: 2022, month: 9, day: 1),
  ),
)

= Introduction

#set math.equation(numbering: none)  // There are no numbers in sample paper.
#blindmathpaper

Here is a citation @chow68.

= Acknowledgments and Disclosure of Funding

All acknowledgements go at the end of the paper before appendices and
references. Moreover, you are required to declare funding (financial activities
supporting the submitted work) and competing interests (related financial
activities outside the submitted work). More information about this disclosure
can be found on the JMLR website.
