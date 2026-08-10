#import "../lib.typ": thesis, mainmatter, appendix, backmatter

#show: thesis.with(
  title: "Title of the PhD Thesis",
  author: "Your Name",
  birthdate: "01.01.1990",
  birthplace: "Hometown",
  date: "August 2025",
  faculty: "Fakultät Physik",
  university: "Technische Universität Dortmund",
  city: "Dortmund",
  degree: "Dr. rer. nat.",
  first_corrector: "Prof. Dr. First Reviewer",
  second_corrector: "Prof. Dr. Second Reviewer",
  examination_committee_chair: "Prof. Dr. Committee Chair",
  phd_representative: "Dr. PhD Representative",
  submission_date: "1. August 2025",
  defense_date: "1. October 2025",
  tucolor: true,
  binding_correction: 12mm,
  two_sided: false,
  logo: read("logos/tu-logo.svg", encoding: none),
)

// ── Front matter (Roman numeral pages) ─────────────────────────
#include "content/00_abstract.typ"

#pagebreak()
#outline(title: [Contents])

// ── Main matter (Arabic numeral pages) ─────────────────────────
#mainmatter

#include "content/01_introduction.typ"
#include "content/02_chapter.typ"

// ── Appendix (lettered chapters) ───────────────────────────────
#appendix

#include "content/appendix.typ"

// ── Back matter ────────────────────────────────────────────────
#backmatter

#bibliography("references.bib", title: [References], style: "ieee")

#include "content/acknowledgements.typ"
