// import any packages here that you want globally accessible
// https://typst.app/universe/search/?kind=packages

// NOTE: these package-versions may be outdated - please look for newer versions
#import "todo.typ": note-outline, todo // custom todo box
#import "@preview/subpar:0.2.2" // subfigures
#import "@preview/headcount:0.1.0": dependent-numbering
#import "@preview/glossy:0.8.0": * // acronyms / glossary
// #import "@preview/codly:1.3.0": * // listings with line numbers
// #import "@preview/codly-languages:0.1.8": * // icons along said listings
// #import "@preview/fletcher:0.5.8" // drawing

// introduce your math shorthands here, like these
#let iff = $arrow.l.r.long.double$ // or $<==>$
#let implies = $arrow.r.long.double$

#let _added-color = color.rgb("#0000ff")
#let _removed-color = color.rgb("#ff0000")
#let aau-blue = rgb(33, 26, 82)

// macros for adding, removing and changing stuff
// makes it easier to detect changes across supervisor meetings
#let revision = 0

#let add(rev, content) = {
  if rev == revision {
    text(fill: _added-color, content)
  } else if rev < revision {
    content
  }
}

#let rmv(rev, content) = {
  if rev == revision {
    strike(text(fill: _removed-color, content))
  } else if rev > revision {
    content
  }
}

#let change(rev, old, new) = context {
  if rev == revision {
    (
      strike(text(fill: _removed-color, old))
        + " "
        + text(fill: _added-color, new)
    )
  } else if rev > revision {
    old
  } else {
    new
  }
}

#let subfig(..args) = context subpar.grid(
  numbering: dependent-numbering(heading.numbering),
  numbering-sub-ref: (fig, sub) => dependent-numbering(heading.numbering)(fig) + numbering("a", sub),
  ..args
)

// custom todo commands to distinguish authors etc
// the macro also takes the arguments `font-color` and `font-size`
#let alice(..rest, body) = todo(color: teal, ..rest,)[Alice:~#body]
#let bob(..rest, body) = todo(color: yellow, ..rest)[Bob:~#body]
#let question = todo.with(color: olive.lighten(20%)) // or just modify the color

// put any other macros here that you would like accessible everywhere
