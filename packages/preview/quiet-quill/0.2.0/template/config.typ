// SPDX-License-Identifier: MIT-0
// All identities, institutions and experimental values in this sample are fictional.
#let mode = sys.inputs.at("anonymous", default: "false")
#assert(mode in ("true", "false"), message: "anonymous input must be true or false")

#let config = (
  title: "A Small Study of Information Retrieval on a Synthetic Document Collection",
  author: "Alex Example",
  email: "author@example.invalid",
  institution: "Example Institute",
  programme: "Illustrative MSc Dissertation",
  supervisor: "Dr Morgan Example",
  submission-date: "23 November 2026",
  keywords: ("synthetic example", "information retrieval", "academic writing"),
  anonymous: mode == "true",
  paper: "a4",
  margins: (x: 25mm, y: 25mm),
  font: "Libertinus Serif",
  font-size: 11pt,
  leading: 0.7em,
  paragraph-spacing: 0.8em,
  contents: true,
  contents-depth: 3,
  list-of-figures: true,
  list-of-tables: true,
  // Resolve in the user's project before passing the file to the package.
  bibliography-file: path("references.bib"),
  citation-style: "ieee",
)

#let abstract = [
  This illustrative dissertation describes a tiny retrieval exercise over a
  fictional document collection. Two invented ranking runs are compared using
  precision at a fixed cutoff. Every score, document and conclusion is synthetic;
  the exercise demonstrates academic typesetting rather than research findings.
  The sample includes a diagram, a table, a numbered equation, citations and an
  appendix, with linked references between them.
]

#let acknowledgements = [
  Thanks to the fictional Example Acknowledgement Team for imaginary feedback.
  This paragraph demonstrates an optional section and is omitted in anonymous mode.
]

// Use your own programme's current declaration if required. No institutional text
// is supplied here. A declaration is also omitted in anonymous mode.
#let declaration = none

// Optional Roman-numbered lists. Use native tables or definition lists as needed.
#let abbreviations = none
#let symbols = none
#let glossary = none
