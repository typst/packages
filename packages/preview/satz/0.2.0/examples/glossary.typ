// A complete glossary/abbreviation workflow through one satz import.
// Compile: typst compile --root . examples/glossary.typ /tmp/satz-glossary.pdf
#import "../lib.typ": report, satz-figure, glossarium

// Install Glossarium before the report wrapper and register one shared list.
#show: glossarium.make-glossary
#show: report.with(config: (
  colors: (bg-paper: white),
  toc: (depth: 1),
))

#let terms = (
  (key: "api", short: "API", long: "application programming interface"),
  (key: "pdf", short: "PDF", long: "Portable Document Format"),
  // Unused entries are hidden unless print-glossary(show-all: true) is used.
  (key: "sql", short: "SQL", long: "Structured Query Language"),
)
#glossarium.register-glossary(terms)

= A small technical report

An @api connects the document generator to another program.
The @api is referenced again here using its short form.
The final document is exported as a @pdf.

Ordinary figure and table references work alongside glossary references:
see @fig:example and @tab:example.

#satz-figure(
  rect(width: 65%, height: 18mm, fill: luma(240), stroke: 0.5pt),
  caption: [A full caption describing the example document workflow.],
  short-caption: [Document workflow],
) <fig:example>

#figure(
  table(
    columns: (1fr, 1fr),
    table.header([*Stage*], [*Result*]),
    [Authoring], [Typst source],
    [Export], [Document file],
  ),
  caption: [Example workflow stages.],
) <tab:example>

#pagebreak()
= List of abbreviations

#glossarium.print-glossary(terms, disable-back-references: true)
