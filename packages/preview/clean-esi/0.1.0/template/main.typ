// main.typ - ESI Algiers PFE thesis entry point.
// Chapter order, metadata, and the document spine all live here.

#import "@preview/clean-esi:0.1.0": *

#show: thesis.with(
  title: "Your Thesis Title",
  authors: (
    "Surname Name",
    // "Surname2 Name2", // second author (binomial)
  ),
  supervisor: "Dr. Supervisor Name (ESI)",
  co-supervisor: ("Dr. Co-supervisor Name (Host Organization)",),
  option: "Computer Systems and Software (SL)",
  degree-type: "State Engineer Diploma in Computer Science", // or "Master"
  host-organization: "Host Organization",
  promotion: "2025/2026",
  defense-date: "DD/MM/YYYY",
  jury: (
    ("Dr. President Name", "ESI", "President"),
    ("Dr. Reviewer Name", "ESI", "Reviewer"),
    ("Dr. Examiner Name", "ESI", "Examiner"),
  ),
  // Download the ESI logo into this folder, then:
  // logo: image("esi_logo.png", width: 6cm),
  logo: none,
)

// ── Frontmatter: Roman page numbers (I, II, …) ───────────────────────────────
#include "frontmatter/dedication.typ"
#include "frontmatter/acknowledgments.typ"
#include "frontmatter/abstracts.typ"

#table-of-contents()
#list-of-figures()
#list-of-tables()

#include "frontmatter/abbreviations.typ"

// ── Main content: Arabic page numbers (1, 2, …) and running header ──────────
#main-content[
  #[
    #set heading(numbering: none)
    #include "chapters/00-introduction.typ"
  ]

  // Parts are optional: drop the dividers and `numbered-part` wrappers and
  // include the chapters directly if your thesis has no Part I / Part II split.
  #part-divider("Part I", "State of the Art", [
    A short paragraph summarising what this part covers.
  ])
  #numbered-part[
    #include "chapters/01-state-of-the-art.typ"
  ]

  #part-divider("Part II", "Contributions", [
    A short paragraph summarising the contributions presented in this part.
  ])
  #numbered-part[
    #include "chapters/02-contribution.typ"
  ]

  #[
    #set heading(numbering: none)
    #include "chapters/99-conclusion.typ"
  ]

  #bibliography("refs.bib", style: "apa")

  // ── Appendices: A.1 numbering, tables reset per appendix ──────────────────
  #appendix-content[
    #include "appendices/a-supplementary.typ"
  ]
]
