// Global template settings.

#import "./palette.typ": *


// Typography
// ----------------------------------------------------------------------------

#let main_body_text_settings = (
  font: "Noto Sans",
  // font: "Lato",
  // font: "New Computer Modern",
  size: 9pt,
  weight: body_weight,
  tracking: 0.3pt,

  /* Alts.
  font: "Times New Roman",
  size: 8pt,
  weight: 100,
  tracking: 0.6pt,
  */

  // font: "New Computer Modern",
  // tracking: 0.2pt,
  // size: 10pt,
)

#let raw_font_text_settings = (
  font: "JetBrains Mono NL", // "JetBrainsMonoNL NL",
  size: 8pt,
  ligatures: false,
  weight: 200,
  features: (frac: 0, numr: 0, sups: 0, ordn: 0),
)


// All numbered, referenceable environment kinds.
#let environment-counter-names = (
  "definition", "axiom", "theorem", "proposition", "lemma",
  "corollary", "example", "exercise", "problem",
)

// Environment counters reset at the configured heading depth. Axioms are
// intentionally excluded because their numbering is global and continuous.
#let section-counter-names = (
  "definition", "theorem", "proposition", "lemma", "corollary",
  "example", "exercise", "problem",
)
