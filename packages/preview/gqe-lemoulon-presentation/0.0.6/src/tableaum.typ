#import "@preview/touying:0.6.1": *
#import "@preview/tablem:0.3.0": tablem


#let intern-tableaum(self: none, coltable:auto, ..args,  body) = {
  tablem(
  render: (columns: columns, ..args) => {
  
// Medium bold table header.
  show table.cell.where(x: 1): set text(weight: "medium")

// Bold titles.
  show table.cell.where(y: 0): set text(weight: "bold")

// See the strokes section for details on this!
  let frame(stroke) = (x, y) => (
    left: if x > 0 { 0pt } else { stroke },
    right: stroke,
    top: if y < 2 { stroke } else { 0pt },
    bottom: stroke,
  )

    table(
      columns: coltable,
      stroke: frame(rgb(self.colors.neutral-dark)),
      fill: (_, y) => if calc.odd(y) { self.colors.primary.lighten(90%) },
      align: left + horizon,
      ..args,
    )
  },
  ignore-second-row: true,
  body
)
}

#let tableaum(columns: none, ..args,  body) = {
  touying-fn-wrapper(intern-tableaum, coltable: columns, ..args,  body)
}
