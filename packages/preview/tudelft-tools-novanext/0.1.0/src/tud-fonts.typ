#import "tud-color-rgb.typ": *

#let set-fonts(it) = {
  set par(justify: true)
  set text(font: "Arial", size: 10pt)
  show math.equation: set text(font: "Fira Math")
  show raw: set text(font: "Fira Mono", size: 1.3em)
  
  show link: it => {
    if type(it.dest) == str {
      // External link: URL string
      text(olive, font: "Fira Mono", it)
    } else {
      // Internal link: Label or location
      it
    }
  }
  show ref: set text(tud-blue)
  show cite: set text(tud-blue)
  // alternatively, format explicit url links:
  // show regex("https?://\\S*"): it => {set text(olive, font: "Fira Mono"); it}
  
  // '69 'm 'n 's 't are probably apostrophes
  show regex("'(\\d{2}|[mnst])\\b"): it => sym.quote.r.single + it.text.slice(1)
  it
}

#import "@preview/elembic:1.1.1" as e

///Aspect ratio symbol as used, e.g., by https://arc.aiaa.org/doi/10.2514/3.9252
#let aspect-ratio-symbol = e.element.declare(
  "aspect-ratio-symbol",
  prefix: "@preview/tudelft-thesis-novanext,v0.1.0",
  doc: "Formats the subtitle.",

  display: it => $ #hide($A$) #h(it.h-before) // make sure spacing on left side is variable-like
  #box(align(left, skew(
    ax: it.skew-outer,
    box(
      clip: true,
      width: it.clip-width,
      height: it.clip-height,
      box(width: 1em,
        h(it.h-inner) + box(skew(ax: it.skew-inner, "Æ"))
      ),
      outset:0pt,
      inset:0pt,
    )
  ))) #h(it.h-between) R $,

  fields: (
    // Force this field to be specified.
    e.field("clip-width", length, default: .5em),
    e.field("clip-height", length, default: .9em),
    e.field("skew-outer", angle, default: -9deg),
    e.field("skew-inner", angle, default: -13deg),
    e.field("h-before", length, default: -.5em),
    e.field("h-inner", length, default: .1em),
    e.field("h-between", length, default: -.12em),
  )
)

#let AR = $#aspect-ratio-symbol()$

#let set-fonts-classic(it) = {
  // revert to Typst defaults:
  show math.equation: set text(font: "New Computer Modern Math")
  set text(font: "Libertinus Serif")
  show raw: set text(size: 0.65em)

  // furthermore:
  show: e.set_(aspect-ratio-symbol,
    clip-width: .5em,
    clip-height: .7em,
    skew-outer: -14deg,
    skew-inner: -0deg,
    h-before: -.7em,
    h-inner: -.0em,
    h-between: -.3em)
  it
}
