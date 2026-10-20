// Thanks for using this thesis template!
// Please submit any issues or feature requests to https://github.com/timerertim/thesis-template/issues

// uncomment before release for testing
#import "@preview/easy-hgb-thesis:0.1.0": full-thesis

// We configure the document data here, this will be in the title page and others
#set document(
  title: "Thesis Title",
  // Or single string: "Author Name"
  author: ("Author Name", "Name Two", "Name Three"),
  // Keep Short and Simple, no abstract
  description: "Thesis Description",
  // Optional, can be deleted.
  keywords: ("Keyword 1 ", "Keyword 2"),
)
// Set to "de" for German
#set text(lang: "en")

#import "abbrev.typ": abbr
// Wrap the document in the full-thesis template
#show: full-thesis.with(
  "Medicine- and Bioinformatics",
  "2026/2027",
  "Dr. Max Mentorman",
  acknowledgement: include "chapters/acknowledgement.typ", // Can be deleted if not required
  kurzfassung: include "chapters/kurzfassung.typ",
  abstract: include "chapters/abstract.typ",
  preamble: include "chapters/preamble.typ", // Can be deleted if not required
  appendix: include "chapters/appendix.typ", // Can be deleted if not required
  abbreviations: abbr, // Can be deleted if you don't need abbreviations
  bibl: bibliography("bib.yaml"), // Can be replaced with a BibLaTex file,

  // Demonstration of how to apply custom styles to sections, can be deleted if not required.
  content-style: it => {
    show table.cell.where(y: 0): strong
    it
  },
  abbreviations-style: it => {
    set table(fill: (x, y) => if y == 0 { gray })
    it
  },
)

// Include your chapters here, content can also be written here directly but
// may become confusing and hard to maintain with very long contents
#include "chapters/introduction.typ"
#include "chapters/methodology.typ"
#include "chapters/conclusion.typ"
