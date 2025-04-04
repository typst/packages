
#import "@preview/theorion:0.3.2": *
// #import "@preview/showybox:2.0.4": showybox
#import "colours.typ": *

#let tuhi-symbols = ($triangle.filled.t$, $▲$, $star.stroked$, $pilcrow$, $lozenge.filled$, $⧫$)

#let select-cols(style:"neutral") = {
  if style == "primary"{
    (border-color: tuhi-palette.primary-darker,
    title-color: tuhi-palette.primary-dark,
    body-color: tuhi-palette.primary-lightest,
  )
  } else if style == "secondary" {
    (border-color: tuhi-palette.secondary-dark,
    title-color: tuhi-palette.secondary-dark,
    body-color: tuhi-palette.secondary-lightest,
  )
  } else if style == "tertiary" {
    (border-color: tuhi-palette.tertiary-dark,
    title-color: tuhi-palette.tertiary-dark,
    body-color: tuhi-palette.tertiary-lightest,
  )
  } else {
    (border-color: tuhi-palette.neutral-dark,
    title-color: tuhi-palette.neutral-dark,
    body-color: tuhi-palette.neutral-lightest,
  )
  }

}
#let colour-box(style: "neutral", // primary, secondary, tertiary
  get-symbol: sym.suit.heart.stroked,
  prefix: none,
  title: "",
  full-title: auto,
  breakable: false,
  body,
) = context {
  let current-cols = select-cols(style:style)
  showybox(
  frame: (
    thickness: .05em,
    radius: .3em,
    inset: (x: 1.2em, top: if full-title != "" { .7em } else { 1.2em }, bottom: 1.2em),
    ..current-cols,
    title-inset: (x: 1em, y: .5em),
  ),
  title-style: (
    boxed-style: (
      anchor: (x: start, y: horizon),
      radius: 0em,
    ),
    color: white,
    weight: "semibold",
  ),
  breakable: breakable,
  title: {
    if full-title == auto {
      if prefix != none {
        [#prefix (#title)]
      } else {
        title
      }
    } else {
      full-title
    }
  },
  {
    body
    if get-symbol != none {
      place(
        end + bottom,
        dy: .8em,
        dx: .9em,
        text(size: .6em, fill: current-cols.border-color, get-symbol),
      )
    }
  },
)}


/// Create corresponding theorem box.
#let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
  "theorem",
  theorion-i18n-map.at("theorem"),
  inherited-levels: 2,
  render: colour-box.with(style: "secondary",
    get-symbol: $star.stroked$,
  ),
)

#let (definition-counter, definition-box, definition, show-definition) = make-frame(
  "definition",
  theorion-i18n-map.at("definition"),
  counter: theorem-counter,
  render: colour-box.with(style: "primary",
    get-symbol: $circle.stroked.small$,
  ),
)

#let (warning-counter, warning-box, warning, show-warning) = make-frame(
  "warning",
  theorion-i18n-map.at("warning"),
  counter: theorem-counter,
  render: colour-box.with(style: "tertiary",
    get-symbol: $diamond.stroked$,
  ),
)


#let (neutral-counter, neutral-box, neutral, show-neutral) = make-frame(
  "neutral",
  "neutral",
  counter: theorem-counter,
  render: colour-box.with(style: "neutral",
    get-symbol: $square.stroked.small$,
  ),
)


/// Collection of show rules for all theorem environments
/// Applies all theorion-related show rules to the document
///
/// - body (content): Content to apply the rules to
/// -> content
#let show-theorion(body) = {
  show: show-theorem
  show: show-definition
  show: show-warning
  show: show-neutral
  body
}
