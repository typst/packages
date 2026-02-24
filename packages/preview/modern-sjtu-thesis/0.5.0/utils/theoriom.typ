#import "@preview/theorion:0.4.0": *
#import "style.typ": zihao

/// A simple render function
#let render-fn(
  prefix: none,
  title: "",
  full-title: auto,
  body,
) = {
  set text(zihao.xiaosi)
  if full-title != "" {
    strong[#full-title] + sym.space
  }
  body
}

/// Create corresponding theorem box.
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "theorem",
  theorion-i18n-map.at("theorem"),
  inherited-levels: 1,
  render: render-fn,
)

#let (lemma-counter, lemma-box, lemma, show-lemma) = make-frame(
  "lemma",
  theorion-i18n-map.at("lemma"),
  inherited-levels: 1,
  render: render-fn,
)

#let (corollary-counter, corollary-box, corollary, show-corollary) = make-frame(
  "corollary",
  theorion-i18n-map.at("corollary"),
  inherited-levels: 1,
  render: render-fn,
)

#let (axiom-counter, axiom-box, axiom, show-axiom) = make-frame(
  "axiom",
  theorion-i18n-map.at("axiom"),
  inherited-levels: 1,
  render: render-fn,
)

#let (postulate-counter, postulate-box, postulate, show-postulate) = make-frame(
  "postulate",
  theorion-i18n-map.at("postulate"),
  inherited-levels: 1,
  render: render-fn,
)

#let (definition-counter, definition-box, definition, show-definition) = make-frame(
  "definition",
  theorion-i18n-map.at("definition"),
  inherited-levels: 1,
  render: render-fn,
)

#let (proposition-counter, proposition-box, proposition, show-proposition) = make-frame(
  "proposition",
  theorion-i18n-map.at("proposition"),
  inherited-levels: 1,
  render: render-fn,
)

#let (proof-counter, proof-box, proof, show-proof) = make-frame(
  "proof",
  theorion-i18n-map.at("proof"),
  render: (prefix: none, title: "", full-title: auto, body) => text(zihao.xiaosi)[#strong[证明]#sym.space#body#box(
      width: 0em,
    )#h(1fr)#sym.wj#sym.space.nobreak$square$],
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
  show: show-proof
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
