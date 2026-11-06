#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#import "bookly-defaults.typ": *
#import "bookly-helper.typ": *

#let tufte-content(body) = block(width: 5cm, body)
#let margin-factor = 1.4

#let note = note.with(
  counter: states.sidenotecounter,
  numbering: (..i) => super(numbering("1", ..i)),
  keep-order: true
)

#let notefigure = notefigure.with(keep-order: true)

#let notecite(key, supplement: none, dy: 0em, alignment: "baseline") = context {
  let elems = query(bibliography)
  if elems.len() > 0 {
    cite(key, supplement: supplement)
    note(
      counter: none,
      dy: dy,
      alignment: alignment,
      keep-order: true,
      cite(key, form: "full", style: "resources/short_ref.csl"))
  } else {
    panic("No bibliography found. Please add a bibliography to use notecite.")
  }
}