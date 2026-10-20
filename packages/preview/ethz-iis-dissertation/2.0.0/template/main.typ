// PhD Thesis example — compile with:
//   typst compile main.typ

#import "@preview/ethz-iis-dissertation:2.0.0": (
  acr, acrfull, acrpl, dissertation, typst-guide,
)
#import "acronyms.typ": acronyms

#show: dissertation.with(
  // Identity — replace with your own details
  title: "Title of Your Dissertation",
  author: "Firstname Lastname",
  email: "username@iis.ee.ethz.ch",
  date-of-birth: "dd.mm.yyyy",

  // Examination
  // diss-number: 12345,  // Uncomment once assigned at registration
  supervisor: "Prof. Dr. Supervisor Name",
  co-examiners: ("Prof. Dr. Co-Examiner Name",),
  year: 2026,

  // Render mode: "digital" (research-collection PDF) or "booklet" (print copy
  // with binding margins and recto chapter starts).
  mode: "digital",

  // Front matter
  acknowledgements: include "chapters/acknowledgements.typ",
  abstracts: (
    include "chapters/abstract_en.typ",
    include "chapters/abstract_de.typ",
  ),
  acronyms: acronyms,

  // Back matter
  bibliography: bibliography("references.bib", style: "ieee"),
  appendices: (
    include "appendices/chip_gallery.typ",
    typst-guide,
  ),
  cv: include "cv.typ",
  // `auto` shows a reminder page about reuse permissions. Once addressed, set
  // this to the bundled `ieee-reprint-notice` (import it above), your own
  // content, or `none` if the thesis contains no reprinted material.
  copyright-notice: auto,
)

// Main body — one include per chapter
#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/conclusion.typ"
