#import "@preview/touying:0.5.3": *


#let intern-tableau(self: none, columns: [],..cells) = {

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

  set table(
    fill: (_, y) => if calc.odd(y) { self.colors.primary.lighten(90%) },
  stroke: frame(rgb(self.colors.neutral-dark)),
  )

  table(
    columns: columns,

    ..cells
)

}


#let tableau(columns: [],..cells) = {
  touying-fn-wrapper(intern-tableau, columns: columns,..cells)
}


