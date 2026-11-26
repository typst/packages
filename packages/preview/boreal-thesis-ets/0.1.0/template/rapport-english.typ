// ============================================================
// ÉTS WRITING TEMPLATE — TYPST VERSION
// English document. See GUIDE.md for the full documentation.
//
// Build:   typst compile rapport-english.typ
// Watch:   typst watch rapport-english.typ
// ============================================================

#import "@preview/boreal-thesis-ets:0.1.0": *

#show: ets-document.with(
  // thesis | manuscriptbasedthesis | masterdegreethesis
  // | manuscriptbasedmasterdegreethesis | projectreport
  type: "projectreport",
  lang: "en",

  // ---- Licence: "reserved" (default) or "creativecommons" ----
  licence: "reserved",

  // ---- "CONFIDENTIAL" watermark on the title page ----
  confidential: false,

  // ---- Title page ----
  title: [Document title],
  author: (firstname: "First name", lastname: "Last name"),
  // Optional override for a different copyright label:
  // copyright-holder: "First name Last name",
  defense-date: datetime(year: 2026, month: 5, day: 15),
  deposit-date: datetime(year: 2025, month: 11, day: 30),

  // ---- Jury ----
  // `affiliation` is optional (default: École de technologie supérieure).
  supervisor: (name: "First Name Last Name", dept: "Department name"),
  cosupervisor: (
    name: "First Name Last Name",
    dept: "Department name",
    affiliation: "at University XXX",
  ),
  chair: (name: "First Name Last Name", dept: "Department name"),
  jury: (
    (name: "First Name Last Name", dept: "Department name"),
    // (name: "First Name Last Name", dept: "Department name"), // second jury member
  ),
  external-examiners: (
    (name: "First Name Last Name", affiliation: "Company name"),
    // (name: "First Name Last Name", affiliation: "Company name"), // second external examiner
  ),
  independent-examiner: (
    name: "First Name Last Name",
    affiliation: "Company name",
  ),

  // ---- Diploma name: concentration (optional) ----
  concentration: "Electrical Engineering",

  // ---- Co-tutorship (optional) ----
  cotutorship: "XXXX UNIVERSITY",
)

#let sample = lorem(90)

// ============================================================
// PRELIMINARY SECTIONS
// ============================================================

#foreword
#sample

#acknowledgements
#sample

// In an English document, #abstract takes the keywords only; #resume takes the
// French title and the French keywords.
#abstract(keywords: "keyword1, keyword2")[
  #sample
]

#resume(title: [Titre français de la thèse], keywords: "mot-clé1, mot-clé2")[
  #sample
]

#table-of-contents()

#list-of-tables()

#list-of-figures()

#list-of-algorithms()

#list-of-abbreviations((
  ("ETS", "École de technologie supérieure"),
  ("CSA", "Canadian Space Agency"),
))

#list-of-symbols((
  ($a$, "First letter of the alphabet"),
  ($A$, "First letter of the alphabet, uppercase"),
))

// ============================================================
// BODY
// ============================================================

#show: introduction

#sample

#ets-figure(
  image("Figures/vueEts.jpg", width: 100%),
  caption: [Sample figure],
  label: <fig:etsView>,
  source: "Image source",
  year: 2024,
)

= First demonstration chapter

== Layout tests

=== Equations

$ beta = 8 $ <eq:beta>

=== Code listings

#ets-listing(
  ```python
  def hello_ets():
      return "ok"
  ```,
  caption: [Python example (same list as algorithms)],
  label: <lst:sample>,
)

= Second demonstration chapter

== Table layout

#ets-table(
  caption: [Sample table],
  label: <tab:sample>,
  source: "Table source",
  year: 2024,
  table(
    columns: 4,
    align: center,
    ..([heading],) * 4,
    ..([cell],) * 12,
  ),
)

== Cross-references

Bibliography citation @BookExample. Figure reference: @fig:etsView.
Table reference: @tab:sample. Equation reference: @eq:beta.
Link: #link("https://www.etsmtl.ca")[ÉTS website].

#conclusion

#sample

#recommendations

#sample

// ============================================================
// ANNEXES AND APPENDICES
// ============================================================

#show: annexes

= Sample annex

== First section of the annex

#ets-figure(
  image("Figures/vueEts.jpg", width: 100%),
  caption: [Sample figure in an annex],
  label: <fig:etsViewAnnex>,
)

Figures in annexes are renumbered automatically (for example, @fig:etsViewAnnex).

#show: appendices

= Sample appendix

== First section of the appendix

#sample

// ============================================================
// BIBLIOGRAPHY
// ============================================================

#ets-bibliography(read("biblio_en.bib", encoding: none), full: true)

#ets-references(read("refs.bib", encoding: none), full: true)
