// Draft todo notes in the outside margin. Visibility is controlled by the
// `draft` flag in main.typ (via drafting's `hidden` default set in thesis.typ).

#import "@preview/drafting:0.2.2": margin-note, note-outline

#let todo(body, fill: yellow.lighten(70%)) = margin-note(
  fill: fill,
  text(size: 7pt, body),
)

#let should = todo.with(fill: red.lighten(60%))
#let could = todo.with(fill: orange.lighten(60%))
#let would = todo.with(fill: yellow.lighten(60%))
#let may = todo.with(fill: white)
#let feedback = todo.with(fill: luma(200))
#let at-prof = todo.with(fill: blue.lighten(60%))

#let list-of-todos = note-outline.with(title: "List of Todos")
