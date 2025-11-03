// import any packages here that you want globally accessible
// https://typst.app/universe/search/?kind=packages

#import "todo.typ": todo, note-outline // custom todo box
#import "@preview/subpar:0.2.0" // subfigures
#import "@preview/t4t:0.4.1": get // utils
#import "@preview/headcount:0.1.0": dependent-numbering
#import "@preview/glossy:0.5.2": * // acronyms / glossary
// #import "@preview/codly:1.2.0": * // listings with line numbers
// #import "@preview/codly-languages:0.1.5": * // icons along said listings
// #import "@preview/cetz:0.3.1" // drawing

#let _revision = state("revision", 0)
#let set-revision(rev) = {
  _revision.update(r => rev)
}

#let _added-color = color.rgb("#0000ff")
#let _removed-color = color.rgb("#ff0000")
#let aau-blue = rgb(33, 26, 82)

// macros for adding, removing and changing stuff
#let add(rev, content) = context {
  if rev == _revision.get() {
    text(fill: _added-color, content)
  } else if rev < _revision.get() {
    content
  }
}

#let rmv(rev, content) = context {
  if rev == _revision.get() {
    strike(text(fill: _removed-color, content))
  } else if rev > _revision.get() {
    content
  }
}

#let change(rev, old, new) = context {
  if rev == _revision.get() {
    strike(text(fill: _removed-color, old)) + " " + text(fill: _added-color, new)
  } else if rev > _revision.get() {
    old
  } else {
    new
  }
}

#let _subfigure-ref(fig, sub) = {
  dependent-numbering(heading.numbering)(fig) + numbering("a", sub)
}

#let subfig(..args) = context subpar.grid(
  numbering: dependent-numbering(heading.numbering),
  numbering-sub-ref: _subfigure-ref,
  ..args
)

// custom todo commands to distinguish authors etc
// the macro also takes the arguments `font-color` and `font-size`
#let alice(..rest, body) = todo(color: teal, ..rest)[Alice:~#body] // show who the author is
#let bob(..rest, body) = todo(color: yellow, ..rest)[Bob:~#body]
#let question = todo.with(color: olive.lighten(20%)) // or just modify the color

// put any other macros here that you would like accessible everywhere
