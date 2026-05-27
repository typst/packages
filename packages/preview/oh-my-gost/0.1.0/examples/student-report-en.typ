#import "../lib.typ": gost-report, introduction, conclusion, appendices

#show: gost-report.with(
  lang: "en",
  title: "Developing a GOST 7.32-2017 Report Template",
  author: "Ivan Ivanov",
  group: "M34011",
  institution: "University of Information Technologies",
  faculty: "Faculty of Software Engineering",
  department: "Department of Computer Systems",
  city: "Saint Petersburg",
  year: "2026",
  supervisor: "Peter Petrov",
  work-type: "Student report",
  keywords: ("GOST 7.32-2017", "Typst", "template", "report"),
  bibliography-file: "examples/references.bib",
)

#introduction(lang: "en")[
  The introduction describes the motivation, goal, and tasks of the
  research. This example uses English structural labels while preserving
  the GOST layout defaults. It also cites a bibliography entry
  @knuth1984texbook.
]

= Requirements Analysis

The report body is written as normal Typst content. Bibliography data comes
from a BibTeX file @typst-docs.

== Template Requirements

The template should keep the public API compact: users define metadata once and
then write the report body directly.

= Implementation

The main body may contain formulas, tables, figures, and lists.

#figure(
  table(
    columns: 2,
    [Parameter], [Value],
    [Page format], [A4],
    [Left margin], [30 mm],
  ),
  caption: [Core page settings],
)

#conclusion(lang: "en")[
  The result is a reusable template suitable for student reports.
]

#appendices(lang: "en")[
  Additional materials can be placed in appendices.
]
