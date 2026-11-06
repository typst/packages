// KU Leuven Faculty of Engineering Science -- master's thesis (Typst)
//
// Mirrors doc/template/thesis.tex from the LaTeX repository, so the output can
// be compared page by page against the reference PDF the CI builds.
//
#import "@preview/kulemt:2.2.0": template

#show: template.with(
  title: "The best master's thesis ever",
  // subtitle: "With a subtitle",

  // Starting year of the academic year, or a (start, end) pair.
  academic-year: 2025,

  authors: ("First Author", "Second Author"),
  promotors: ("Prof. dr. ir. Knows Better",),
  assessors: ("Ir. Kn. Owsmuch", "K. Nowsrest"),
  supervisors: ("Ir. An Assistent", "A. Friend"),


  degree: (
    name: "Master of Science in Electrical Engineering",
    options: ("option Electronics and Chip Design",),
  ),

  // Language of the thesis text.
  language: "en",
  // Is your master's programme taught in English? This decides the language of
  // the cover, title and copyright pages, and which faculty logo is used.
  english-master: true,

  // Your department's address on the copyright page. Leave it out to fall back
  // to the faculty address, which is what kulemt does when a programme defines
  // none of its own.
  // address: (
  //   en: "Department of Electrical Engineering, Kasteelpark Arenberg 10 bus 2440, B-3001 Leuven",
  //   nl: "Departement Elektrotechniek, Kasteelpark Arenberg 10 bus 2440, B-3001 Leuven",
  // ),

  // kulemt defines a page layout for 10pt and 11pt only.
  font-size: 11pt,

  // One-sided, no separate cover page.
  electronic-version: true,

  // --- printing options, mirroring the kulemt class options -----------------
  // bind: 5mm,              // paper lost to the binding, added to the inside
  // twoside: true,          // mirror margins on facing pages
  // twoside-lr-equal: true, // twoside, but with equal visible margins
  // cover-page-only: true,  // just the cover, for the print shop
  // front-pages-only: true, // just the title and copyright pages
  // article: true,          // short-report layout, no front matter

  // --- front and back matter ------------------------------------------------
  preface: include "sections/preface.typ",
  abstract: include "sections/abstract.typ",
  // dutch-summary: include "sections/dutch-summary.typ",

  // \listoffiguresandtables -- one section, two subheadings.
  list-of-figures: true,
  list-of-tables: true,
  list-of-listings: false,

  abbreviations: (
    ("LoG", "Laplacian-of-Gaussian"),
    ("MSE", "Mean Square error"),
    ("PSNR", "Peak Signal-to-Noise ratio"),
  ),
  symbols: (
    ("42", [“The Answer to the Ultimate Question of Life, the Universe, and Everything” according to @h2g2]),
    ($c$, "Speed of light"),
    ($E$, "Energy"),
    ($m$, "Mass"),
    ($pi$, "The number pi"),
  ),

  bibliography: bibliography("references.bib"),
  appendices: include "sections/appendix-1.typ",

  
  transparency-statement: true,
  // Fill it in from here instead of editing the form:
  // transparency-ticks: ("master-thesis", "used"),
  // transparency-answers: (
  //   student-name: "First Author",
  //   thesis-title: "The best master's thesis ever",
  //   supervisor: "Prof. dr. ir. Knows Better",
  // ),
  // transparency-uses: ("0": "yes", "3": "yes", "6": "no"),

  // The official faculty logo for the programme language is used
  // automatically. Override with your own image if you need to:
  // logo: image("my-logo.svg", width: 76.2mm),
)

#include "sections/intro.typ"
#include "sections/chapter-1.typ"
#include "sections/conclusion.typ"
