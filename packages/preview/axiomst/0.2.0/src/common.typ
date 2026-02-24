// axiomst/common.typ - Shared components for homework and slides
#import "@preview/showybox:2.0.4": showybox

// Counters
#let problem-counter = counter("problem")
#let theorem-counter = counter("theorem")
#let definition-counter = counter("definition")
#let lemma-counter = counter("lemma")
#let corollary-counter = counter("corollary")
#let example-counter = counter("example")
#let algorithm-counter = counter("algorithm")

// Global state for solution visibility
#let show-solutions-state = state("show-solutions", true)

// Column layout utility
#let columns(
  count: 2,
  gutter: 1em,
  separator: none,
  widths: none,
  ..children,
) = {
  let content = children.pos()

  let col-widths = ()
  if widths == none {
    let available-width = 100% - gutter * (count - 1)
    let column-width = available-width / count
    col-widths = (column-width,) * count
  } else {
    col-widths = widths
  }

  if separator == "line" {
    grid(
      columns: col-widths,
      column-gutter: gutter,
      ..content.enumerate().map(((i, c)) => {
        if i < content.len() - 1 {
          (c, line(angle: 90deg, length: 100%, stroke: (thickness: 0.5pt, dash: "solid")))
        } else {
          c
        }
      }).flatten()
    )
  } else if separator != none and type(separator) == "function" {
    grid(
      columns: col-widths,
      column-gutter: gutter,
      ..content.enumerate().map(((i, c)) => {
        if i < content.len() - 1 {
          (c, separator())
        } else {
          c
        }
      }).flatten()
    )
  } else {
    grid(
      columns: col-widths,
      column-gutter: gutter,
      ..content
    )
  }
}

// Base theorem-like box
#let theorem-base(
  ctr,
  prefix,
  title: none,
  numbered: true,
  color: blue.darken(20%),
  fill: blue.lighten(95%),
  body
) = {
  let number = if numbered { ctr.step(); context(ctr.display()) }

  block(
    width: 100%,
    fill: fill,
    radius: 4pt,
    stroke: color.darken(10%),
    inset: 0.6em,
  )[
    #text(weight: "bold")[#prefix #if numbered {number}]
    #if title != none [#text(style: "italic")[#title].]
    #v(0.5em)
    #body
  ]
}

// Theorem
#let theorem(
  title: none,
  numbered: true,
  color: blue.darken(20%),
  ..body
) = {
  theorem-base(
    theorem-counter,
    "Theorem",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

// Lemma
#let lemma(
  title: none,
  numbered: true,
  color: green.darken(20%),
  ..body
) = {
  theorem-base(
    lemma-counter,
    "Lemma",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

// Definition
#let definition(
  title: none,
  numbered: true,
  color: purple.darken(20%),
  ..body
) = {
  theorem-base(
    definition-counter,
    "Definition",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

// Corollary
#let corollary(
  title: none,
  numbered: true,
  color: orange.darken(20%),
  ..body
) = {
  theorem-base(
    corollary-counter,
    "Corollary",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

// Example
#let example(
  title: none,
  numbered: true,
  color: aqua.darken(20%),
  ..body
) = {
  theorem-base(
    example-counter,
    "Example",
    title: title,
    numbered: numbered,
    color: color,
    fill: color.lighten(95%),
    ..body
  )
}

// Proof block
#let proof(body, qed-symbol: "fill") = {
  block(body)

  let symbol = if qed-symbol == "fill" {
    text(fill: gray.darken(30%), size: 1.2em, weight: "bold")[■]
  } else if qed-symbol == "hollow" {
    text(fill: gray.darken(30%), size: 1.2em, weight: "bold")[□]
  } else if qed-symbol == "filled-cube" {
    text(fill: gray.darken(30%), size: 1.2em)[∎]
  } else if qed-symbol == "Q.E.D." {
    text(fill: gray.darken(30%), style: "italic")[Q.E.D.]
  } else {
    text(fill: gray.darken(30%))[#qed-symbol]
  }

  align(right, symbol)
}

// Problem box
#let problem(
  title: "",
  color: blue.darken(20%),
  numbered: true,
  ..body
) = {
  if numbered {
    [== Problem #problem-counter.step() #context {problem-counter.display()}]
  }

  showybox(
    frame: (
      border-color: color.darken(10%),
      title-color: color.lighten(85%),
      body-color: color.lighten(95%)
    ),
    title-style: (
      color: black,
      weight: "bold",
    ),
    breakable: true,
    title: title,
    ..body
  )
}

// Subquestions - accepts either a single body or multiple arguments
#let subquestions(..args) = {
  let items = args.pos()
  enum(
    numbering: n => text(weight: "bold")[Q#n:],
    tight: false,
    spacing: 1em,
    ..items
  )
}

// Solution block (toggleable)
#let solution(body) = {
  context {
    if show-solutions-state.get() {
      v(0.5em)
      block(
        width: 100%,
        breakable: true,
      )[
        #text(weight: "bold")[Solution:]
        #v(0.3em)
        #body
      ]
    }
  }
}

// Figure with caption
#let pfigure(image-path: "", caption: "", width: 80%) = {
  align(center)[
    #image(image-path, width: width)
    #if caption != "" [
      #v(0.3em)
      #text(size: 0.9em, style: "italic")[#caption]
    ]
  ]
}

// Table with caption
#let ptable(content, caption: "") = {
  align(center)[
    #content
    #if caption != "" [
      #v(0.3em)
      #text(size: 0.9em, style: "italic")[#caption]
    ]
  ]
}

// Instructions block
#let instructions(body) = {
  block(
    width: 100%,
    fill: yellow.lighten(90%),
    radius: 4pt,
    stroke: yellow.darken(20%),
    inset: 1em,
    breakable: true,
  )[
    #text(weight: "bold", size: 1.1em)[Assignment Instructions]
    #v(0.5em)
    #body
  ]
  v(1em)
}
