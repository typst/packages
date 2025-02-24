#import "../core.typ": *

/// A simple render function with a colored left border
#let render-fn(
  fill: red,
  prefix: none,
  title: "",
  full-title: auto,
  body,
) = block(
  stroke: (left: .3em + fill),
  inset: (left: 1em, y: .75em),
  [
    #strong(text(fill: fill, full-title))
    
    #body
  ]
)

// Core theorems
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "rainbow-theorem",
  theorion-i18n-map.at("theorem"),
  inherited-levels: 2,
  render: render-fn.with(fill: red.darken(20%)),
)

#let (lemma-counter, lemma-box, lemma, show-lemma) = make-frame(
  "rainbow-lemma",
  theorion-i18n-map.at("lemma"),
  counter: theorem-counter,
  render: render-fn.with(fill: teal.darken(10%)),
)

#let (corollary-counter, corollary-box, corollary, show-corollary) = make-frame(
  "rainbow-corollary",
  theorion-i18n-map.at("corollary"),
  counter: theorem-counter,
  render: render-fn.with(fill: fuchsia.darken(10%)),
)

// Definitions and foundations
#let (definition-counter, definition-box, definition, show-definition) = make-frame(
  "rainbow-definition",
  theorion-i18n-map.at("definition"),
  counter: theorem-counter,
  render: render-fn.with(fill: orange),
)

#let (axiom-counter, axiom-box, axiom, show-axiom) = make-frame(
  "rainbow-axiom",
  theorion-i18n-map.at("axiom"),
  counter: theorem-counter,
  render: render-fn.with(fill: green.darken(20%)),
)

#let (postulate-counter, postulate-box, postulate, show-postulate) = make-frame(
  "rainbow-postulate",
  theorion-i18n-map.at("postulate"),
  counter: theorem-counter,
  render: render-fn.with(fill: maroon),
)

// Important results
#let (proposition-counter, proposition-box, proposition, show-proposition) = make-frame(
  "rainbow-proposition",
  theorion-i18n-map.at("proposition"),
  counter: theorem-counter,
  render: render-fn.with(fill: blue.darken(10%)),
)

/// Collection of show rules for all theorem environments
/// Applies all theorion-related show rules to the document
///
/// - body (content): Content to apply the rules to
/// -> content
#let show-theorion(body) = {
  show: show-theorem
  show: show-lemma
  show: show-corollary
  show: show-axiom
  show: show-postulate
  show: show-definition
  show: show-proposition
  body
}

/// Set the number of inherited levels for theorem environments
///
/// - value (integer): Number of levels to inherit
#let set-inherited-levels(value) = (theorem-counter.set-inherited-levels)(value)

/// Set the zero-fill option for theorem environments
///
/// - value (boolean): Whether to zero-fill the numbering
#let set-zero-fill(value) = (theorem-counter.set-zero-fill)(value)

/// Set the leading-zero option for theorem environments
///
/// - value (boolean): Whether to include leading zeros in the numbering
#let set-leading-zero(value) = (theorem-counter.set-leading-zero)(value)
