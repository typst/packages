#import "@preview/equate:0.3.1": equate
#import "@preview/cetz:0.3.4": canvas
#import "@preview/cetz-plot:0.1.1"

#let tapestry(
  title: [],
  year: [],
  author: "",
  doc,
) = {
  set document(
    title: title,
    author: author,
  )

  set page(
    paper: "a5",
    margin: (x: 1.25cm, y: 1.75cm),
    header: [
      #set text(
      size: 9pt,
    )
      _ #title _
      #h(1fr)
      #year
    ],
    header-ascent: 42.5%,
  )

  set heading(
    numbering: "1.",
  )
  show heading: set block(below: 1em)
  show heading: smallcaps

  show link: underline
  show link: set text(
    fill: blue
  )

  set text(
    font: "New Computer Modern",
    size: 11pt
  )

  set math.equation(
    numbering: "(1.1)",
    supplement: "Eq."
  )
  show: equate.with(
    number-mode: "label",
    sub-numbering: true
  )

  outline()

  linebreak()

  doc
}

/// plot functions with colors and domain
/// axis-pos: either "inner" or "outer"
// legend: either "inner", "outer" or "none"
#let plot(
  funcs: (),
  colors: (red, blue, green, orange, purple),
  size: (8, 5),
  domain: (-4, 4),
  step: (2, 1),
  axis-pos: "outer",
  legend: "outer"
) = {
  assert(domain.len() == 2, message: "Domain must be a tuple of two numbers.")
  assert(domain.at(0) < domain.at(1), message: "Domain must be in ascending order.")

  assert(size.len() == 2, message: "Size must be a tuple of two numbers.")
  assert(size.at(0) > 0, message: "Width must be greater than 0.")
  assert(size.at(1) > 0, message: "Height must be greater than 0.")
  
  assert(step.len() == 2, message: "Step must be a tuple of two numbers.")
  assert(step.at(0) > 0, message: "X step must be greater than 0.")
  assert(step.at(1) > 0, message: "Y step must be greater than 0.")
  
  assert(funcs.len() > 0, message: "At least one function must be provided.")

  assert(axis-pos in ("inner", "outer"), message: "Axis position must be either 'inner' or 'outer'.")

  assert(legend in ("inner", "outer", "none"), message: "Legend must be either 'inner', 'outer' or 'none'.")

  let cvs = canvas({
    cetz-plot.plot.plot(
      size: size,
      x-tick-step: step.at(0),
      y-tick-step: step.at(1),
      legend: if legend == "inner" {
          "inner-north-west"
        } else if legend == "outer" {
          auto
        } else {
          none
        },
      legend-style: (item: (spacing: 0.1), padding: 0.1, stroke: .5pt),
      axis-style: if axis-pos == "inner" { "school-book" } else { "left" },
      x-grid: true,
      y-grid: true,
      {
        for (func, color) in funcs.zip(colors) {
          if type(func) == array {
            cetz-plot.plot.add(
              style: (stroke: color + 1.5pt),
              domain: domain,
              label: func.at(1),
              func.at(0),
            )
          } else {
            cetz-plot.plot.add(
              style: (stroke: color + 1.5pt),
              domain: (-4, 4),
              func,
            )
          }
        }
      },
    )
  })

  align(center, cvs)
}

#import "@preview/physica:0.9.5" : vecrow, va, vu, vb, dd, dv, pdv, hbar, grad, div, curl
