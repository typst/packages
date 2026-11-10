#import "../styles/colors.typ": *
#import "@preview/theorion:0.6.0": *

#let render-fn(
  fill: red,
  prefix: none,
  title: "",
  full-title: auto,
  ..args,
  body,
) = context {
  if "html" in dictionary(std) and target() == "html" {
    html.elem("div", attrs: (
      style: "border-inline-start: .25em solid "
        + fill.to-hex()
        + "; padding: .1em 1em; width: 100%; box-sizing: border-box; margin-bottom: .5em;",
    ))[
      #if full-title != "" {
        html.elem(
          "p",
          attrs: (
            style: "margin-top: .5em; font-weight: bold; color: " + fill.to-hex() + ";",
          ),
          full-title,
        )
      }
      #body
    ]
  } else {
    block(
      stroke: language-aware-start(.25em + fill),
      inset: language-aware-start(1em) + (y: .75em),
      fill: fill.lighten(97%),
      width: 100%,
      ..args,
      [
        #if full-title != "" {
          block(sticky: true, strong(text(fill: fill, font: "New Computer Modern Sans", full-title)))
        }
        #indent-repairer(body)
      ],
    )
  }
}

#let render-fn-simple(
  fill: red,
  prefix: none,
  title: "",
  full-title: auto,
  style: "plain",
  inset: (top: .3em, bottom: .3em),
  ..args,
  body,
) = context {
  block(
    width: 100%,
    inset: inset,
    indent-repairer({
      if style == "definition" {
        if full-title != "" { strong[#full-title.] + sym.space }
        body
      } else if style == "remark" {
        if full-title != "" { emph[#full-title.] + sym.space }
        body
      } else {
        if full-title != "" {
          text(weight: "bold", font: "New Computer Modern Sans", fill: fill)[#full-title.] + sym.space
        }
        body
      }
    }),
  )
  indent-fakepar
}

#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "theorem",
  theorion-i18n-map.at("theorem"),
  inherited-levels: 1,
  render: render-fn.with(fill: neo-maroon),
)

#let (lemma-counter, lemma-box, lemma, show-lemma) = make-frame(
  "lemma",
  theorion-i18n-map.at("lemma"),
  counter: theorem-counter,
  render: render-fn.with(fill: neo-petrol),
)

#let (corollary-counter, corollary-box, corollary, show-corollary) = make-frame(
  "corollary",
  theorion-i18n-map.at("corollary"),
  counter: theorem-counter,
  render: render-fn.with(fill: neo-petrol),
)

#let (definition-counter, definition-box, definition, show-definition) = make-frame(
  "definition",
  theorion-i18n-map.at("definition"),
  counter: theorem-counter,
  render: render-fn-simple.with(fill: neo-indigo),
)

#let (proposition-counter, proposition-box, proposition, show-proposition) = make-frame(
  "proposition",
  theorion-i18n-map.at("proposition"),
  counter: theorem-counter,
  render: render-fn-simple.with(fill: neo-petrol),
)

#let (property-counter, property-box, property, show-property) = make-frame(
  "property",
  theorion-i18n-map.at("property"),
  counter: theorem-counter,
  render: render-fn-simple.with(fill: neo-petrol),
)

#let (remark-counter, remark-box, remark, show-remark) = make-frame(
  "remark",
  theorion-i18n-map.at("remark"),
  counter: theorem-counter,
  render: render-fn.with(fill: fuchsia.darken(10%)),
)

#let (example-counter, example-box, example, show-example) = make-frame(
  "example",
  theorion-i18n-map.at("example"),
  counter: theorem-counter,
  render: render-fn.with(fill: neo-copper),
)

#let (exercise-counter, exercise-box, exercise, show-exercise) = make-frame(
  "exercise",
  theorion-i18n-map.at("exercise"),
  counter: theorem-counter,
  render: render-fn-simple.with(fill: neo-indigo),
)

#let (problem-counter, problem-box, problem, show-problem) = make-frame(
  "problem",
  theorion-i18n-map.at("problem"),
  counter: theorem-counter,
  render: render-fn.with(fill: neo-petrol),
)

#let show-neo-theorems(body) = {
  show: show-theorem
  show: show-lemma
  show: show-corollary
  // show: show-axiom
  // show: show-postulate
  show: show-definition
  show: show-proposition
  // show: show-assumption
  show: show-property
  // show: show-conjecture
  show: show-remark
  // show: show-note
  show: show-example
  show: show-exercise
  show: show-problem
  body
}

#let setup-theorems(body) = {
  show: show-neo-theorems
  body
}

#let set-inherited-levels(value) = (theorem-counter.set-inherited-levels)(value)
#let set-zero-fill(value) = (theorem-counter.set-zero-fill)(value)
#let set-leading-zero(value) = (theorem-counter.set-leading-zero)(value)