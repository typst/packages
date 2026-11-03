#import "../core.typ": *

/// Render function for theorem environments (similar to amsthm)
#let render-fn(
  prefix: none,
  title: "",
  full-title: auto,
  style: "plain",
  inset: (top: .3em, bottom: .3em),
  body,
) = context {
  block(
    width: 100%,
    // above: 1.2em,
    // below: 1.2em,
    inset: inset,
    indent-repairer({
      if style == "definition" {
        // Definition-style render function (LaTeX \theoremstyle{definition}):
        // bold title, upright body. Used for definition, axiom, postulate, assumption, property.
        if full-title != "" {
          strong[#full-title.] + sym.space
        }
        body
      } else if style == "remark" {
        // Remark-style render function (LaTeX \theoremstyle{remark}):
        // italic title (not bold), upright body. Used for remark, note, example.
        if full-title != "" {
          emph[#full-title.] + sym.space
        }
        body
      } else {
        // Plain-style render function (LaTeX \theoremstyle{plain}):
        // bold title, italic body. Used for theorem, lemma, corollary, proposition, conjecture.
        // Fallback to plain style if an unknown style is provided
        if full-title != "" {
          strong[#full-title.] + sym.space
        }
        emph(body)
      }
    }),
  )
  indent-fakepar
}

// Core theorems: plain style (italic body) - LaTeX \theoremstyle{plain}
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "theorem",
  theorion-i18n-map.at("theorem"),
  inherited-levels: 2,
  render: render-fn,
)

#let (lemma-counter, lemma-box, lemma, show-lemma) = make-frame(
  "lemma",
  theorion-i18n-map.at("lemma"),
  counter: theorem-counter,
  render: render-fn,
)

#let (corollary-counter, corollary-box, corollary, show-corollary) = make-frame(
  "corollary",
  theorion-i18n-map.at("corollary"),
  inherited-from: theorem-counter,
  render: render-fn,
)

#let (
  proposition-counter,
  proposition-box,
  proposition,
  show-proposition,
) = make-frame(
  "proposition",
  theorion-i18n-map.at("proposition"),
  counter: theorem-counter,
  render: render-fn,
)

#let (
  conjecture-counter,
  conjecture-box,
  conjecture,
  show-conjecture,
) = make-frame(
  "conjecture",
  theorion-i18n-map.at("conjecture"),
  counter: theorem-counter,
  render: render-fn,
)

// Definitions and foundations: definition style (upright body) - LaTeX \theoremstyle{definition}
#let (
  definition-counter,
  definition-box,
  definition,
  show-definition,
) = make-frame(
  "definition",
  theorion-i18n-map.at("definition"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
)

#let (axiom-counter, axiom-box, axiom, show-axiom) = make-frame(
  "axiom",
  theorion-i18n-map.at("axiom"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
)

#let (postulate-counter, postulate-box, postulate, show-postulate) = make-frame(
  "postulate",
  theorion-i18n-map.at("postulate"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
)

#let (
  assumption-counter,
  assumption-box,
  assumption,
  show-assumption,
) = make-frame(
  "assumption",
  theorion-i18n-map.at("assumption"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
)

#let (property-counter, property-box, property, show-property) = make-frame(
  "property",
  theorion-i18n-map.at("property"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
)

// Remarks and notes: remark style (italic title, upright body) - LaTeX \theoremstyle{remark}
#let (remark-counter, remark-box, remark, show-remark) = make-frame(
  "remark",
  theorion-i18n-map.at("remark"),
  counter: theorem-counter,
  render: render-fn.with(style: "remark"),
)

#let (note-counter, note-box, note, show-note) = make-frame(
  "note",
  theorion-i18n-map.at("note"),
  counter: theorem-counter,
  render: render-fn.with(style: "remark"),
)

#let (example-counter, example-box, example, show-example) = make-frame(
  "example",
  theorion-i18n-map.at("example"),
  counter: theorem-counter,
  render: render-fn.with(style: "remark"),
)

// Exercises and problems: definition style (upright body) - LaTeX \theoremstyle{definition}
#let (exercise-counter, exercise-box, exercise, show-exercise) = make-frame(
  "exercise",
  theorion-i18n-map.at("exercise"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
)

#let (problem-counter, problem-box, problem, show-problem) = make-frame(
  "problem",
  theorion-i18n-map.at("problem"),
  counter: theorem-counter,
  render: render-fn.with(style: "definition"),
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
  show: show-assumption
  show: show-property
  show: show-conjecture
  show: show-remark
  show: show-note
  show: show-example
  show: show-exercise
  show: show-problem
  body
}


/// Set the number of inherited levels for theorem environments
///
/// - value (int): Number of levels to inherit
#let set-inherited-levels(value) = (theorem-counter.set-inherited-levels)(value)


/// Set the zero-fill option for theorem environments
///
/// - value (bool): Whether to zero-fill the numbering
#let set-zero-fill(value) = (theorem-counter.set-zero-fill)(value)

/// Set the leading-zero option for theorem environments
///
/// - value (bool): Whether to include leading zeros in the numbering
#let set-leading-zero(value) = (theorem-counter.set-leading-zero)(value)
