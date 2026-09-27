#import "@preview/showybox:2.0.4": showybox
#import "@preview/tablem:0.3.0": tablem
#import "@preview/lovelace:0.3.1": pseudocode-list
#import "@preview/syntree:0.3.1": listtree, syntree
#import "@preview/finite:0.5.1": automaton
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let conf(
  title: [],
  authors: (),
  description: none,
  doc,
) = {
  set page(
    flipped: true,
    numbering: "1/1",
    number-align: right,
    columns: 3,
    margin: (rest: 0.635cm),
    footer-descent: 0cm,
  )

  set document(
    title: title,
    author: authors,
    description: description,
  )

  set text(
    font: "New Computer Modern",
    lang: "en",
    size: 8pt,
  )

  set heading(numbering: "1.1.1.")
  set columns(gutter: 3%)

  doc
}

#let container(fill: white, title, body, ..rest) = {
  set heading(numbering: none)

  showybox(
    frame: (
      border-color: black,
      body-color: fill,
      title-color: fill,
      thickness: 1pt,
      radius: 3pt,
      inset: 5pt,
    ),
    sep: (
      dash: "dotted",
      thickness: 1pt,
    ),
    title-style: (
      sep-thickness: 0pt,
      color: black,
      boxed-style: (
        anchor: (
          x: left,
        ),
        radius: 3pt,
      ),
    ),
    footer-style: (
      sep-thickness: 2pt,
      color: black,
    ),
    breakable: false,
    spacing: 1em,

    [
      #underline[#title]
      #body
    ],
    ..rest,
  )
}

#let definition(title, body, ..rest) = container(
  fill: white.darken(20%),
  title,
  body,
  ..rest,
)
#let example(title, body, ..rest) = container(
  fill: white.darken(10%),
  title,
  body,
  ..rest,
)
#let recipe(title, body, ..rest) = container(fill: white, title, body, ..rest)

#let grid = tablem.with(
  render: (columns: auto, align: auto, ..args) => {
    table(
      columns: columns,
      stroke: (x, y) => (
        left: if x > 0 { 0.5pt },
        top: if y > 0 { 0.5pt },
      ),
      align: center + horizon,
      ..args,
    )
  },
)

#let pseudo = pseudocode-list
