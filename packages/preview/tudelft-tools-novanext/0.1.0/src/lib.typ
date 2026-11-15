/* Package Entrypoint */

#import "tud-color-cmyk.typ"
#import "tud-color-rgb.typ"
#import "tud-logo.typ": *
#import "tud-fonts.typ": *
#import "@preview/elembic:1.1.1" as e

/// generates lorem ipsum, but removes a number of words from the beginning. For example, `#ipsum(2, 1)` returns `Ipsum dolor`
#let ipsum(n, offset) = {
//  let t = lorem(n + offset).replace(regex("\\w+\\W+"), "", count: offset)
  let t = lorem(n + offset).split(regex(" \b"))
  let t = t.slice(-n, -1) + (t.at(-1).replace(regex("\\W"),""),)
  let t = t.join(" ")
  upper(t.first()) + t.slice(1) + "."
}

/// removes all square brackets from the argument, and adds an outer pair of square brackets, to replace, e.g. `[1], [2]` by `[1, 2]`.
#let multicite(cites) = {
  [\[]
  {
    show "[": ""
    show "]": ""
    cites
  }
  [\]]
}

#let if-classic-else = e.element.declare(
  "if-classic-else",
  prefix: "@preview/tudelft-tools-novanext,v0.1.0",
  doc: "Simple switch to choose contents depending on whether the style is 'classic'.",

  display: it => if it.is-classic {
    it.classic-body
  } else {
    it.body
  },

  fields: (
    // Force this field to be specified.
    e.field("classic-body", content, required: true),
    e.field("body", content, required: true),
    e.field("is-classic", bool, default: false),
  )
)
