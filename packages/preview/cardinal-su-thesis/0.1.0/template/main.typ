#import "@preview/cardinal-su-thesis:0.1.0": *

// ─── Configuration ───────────────────────────────────────────────────────────
// Every option and its default is listed in the README:
// https://github.com/mayasheth/cardinal-su-thesis#options
// The values below are the ones you are most likely to need to change.

#show: thesis.with(
  title: "An Example Dissertation Demonstrating the Template",
  // Optional: control where the title breaks across lines on the title page.
  title-display: [An Example Dissertation \ Demonstrating the Template],
  author: "Your Full Name",
  // Must be the month and year you actually submit to the Registrar.
  date: datetime(year: 2026, month: 6, day: 15),
  // "phd" → "A DISSERTATION" / "DOCTOR OF PHILOSOPHY"
  // "engineer" → "A THESIS" / "ENGINEER"
  degree: "phd",
  // Renders "SUBMITTED TO THE DEPARTMENT OF ...".
  // Use `program:` instead for "SUBMITTED TO THE PROGRAM IN ...".
  department: "Your Department",
)

// ─── Preliminary pages ───────────────────────────────────────────────────────
// Lowercase Roman numerals. The title page counts as i but is not numbered;
// Axess inserts the copyright page (ii) and signature page (iii) on submission,
// so physical numbering resumes at iv.

#show: front-matter

#include "chapters/00_front_matter.typ"

#outline(title: [Contents], depth: 3, indent: 0pt)

// Both lists are optional. Delete either if you do not need it.
#outline(title: [List of Figures], target: figure.where(kind: image))

#outline(title: [List of Tables], target: figure.where(kind: table))

// ─── Main text ───────────────────────────────────────────────────────────────
// Arabic numerals, restarting at 1.

#show: main-body

#include "chapters/01_introduction.typ"
#include "chapters/02_writing_a_chapter.typ"
#include "chapters/03_conclusions.typ"

// ─── Appendices ──────────────────────────────────────────────────────────────
// Optional. Switches headings to letter numbering.

#show: appendix

#include "appendices/A_supplementary.typ"

// ─── References ──────────────────────────────────────────────────────────────
// An explicit unnumbered heading keeps the bibliography out of the appendix
// letter sequence while still listing it in the table of contents.

#heading(level: 1, numbering: none)[References]
#bibliography("refs.bib", title: none, style: "nature")
