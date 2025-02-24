#import "../core.typ": *

/// A simple render function
#let render-fn(
  prefix: none,
  title: "",
  full-title: auto,
  body,
) = [#strong[#full-title.]#sym.space#emph(body)]

/// Create corresponding theorem box.
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "simple-theorem",
  theorion-i18n-map.at("theorem"),
  inherited-levels: 2,
  render: render-fn,
)

#let (lemma-counter, lemma-box, lemma, show-lemma) = make-frame(
  "simple-lemma",
  theorion-i18n-map.at("lemma"),
  counter: theorem-counter,
  render: render-fn,
)

#let (corollary-counter, corollary-box, corollary, show-corollary) = make-frame(
  "simple-corollary",
  theorion-i18n-map.at("corollary"),
  inherited-from: theorem-counter,
  render: render-fn,
)

#let (axiom-counter, axiom-box, axiom, show-axiom) = make-frame(
  "simple-axiom",
  theorion-i18n-map.at("axiom"),
  counter: theorem-counter,
  render: render-fn,
)

#let (postulate-counter, postulate-box, postulate, show-postulate) = make-frame(
  "simple-postulate",
  theorion-i18n-map.at("postulate"),
  counter: theorem-counter,
  render: render-fn,
)

#let (definition-counter, definition-box, definition, show-definition) = make-frame(
  "simple-definition",
  theorion-i18n-map.at("definition"),
  counter: theorem-counter,
  render: render-fn,
)

#let (proposition-counter, proposition-box, proposition, show-proposition) = make-frame(
  "simple-proposition",
  theorion-i18n-map.at("proposition"),
  counter: theorem-counter,
  render: render-fn,
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
