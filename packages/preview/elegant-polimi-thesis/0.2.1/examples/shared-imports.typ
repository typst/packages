#import "@preview/algo:0.3.6": *
#import "@preview/lovelace:0.3.1": *
#import "@preview/metalogo:1.2.0": LaTeX, TeX

#let frame(color) = (
  (x, y) => (
    left: if x > 0 {
      0pt
    } else {
      color
    },
    right: color,
    top: if y < 2 {
      color
    } else {
      0pt
    },
    bottom: color,
  )
)

#let shading(color) = (
  (x, y) => {
    if y == 0 {
      color
    } else {
      none
    }
  }
)

#let Typst = {
  text(
    fill: eastern,
    font: "Libertinus Serif",
    weight: "semibold",
    "Typst",
  )
}
