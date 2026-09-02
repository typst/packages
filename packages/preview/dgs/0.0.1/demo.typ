#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 1cm)

= DGS Demo

== Basic Shapes

#dgs-canvas(
  x1: -3, y1: -3, x2: 3, y2: 3,
  width: 250pt, height: 250pt,
  theme: "light",
  grid: true,
  axes: true,
  objects: (
    dgs-point("O", 0, 0, color: "red"),
    dgs-point("A", 2, 1, color: "blue"),
    dgs-point("B", -1, 2, color: "green"),
    dgs-line("O", "A", color: "blue"),
    dgs-line("O", "B", color: "green"),
    dgs-line("A", "B", color: "purple", stroke: 2pt),
    dgs-circle("O", 2, color: "gray", stroke: 1pt),
    dgs-polygon("O", "A", "B", fill: rgb("#ff000022")),
  )
)

== Function Plotting

#dgs-canvas(
  x1: -3, y1: -3, x2: 3, y2: 3,
  width: 250pt, height: 250pt,
  theme: "light",
  grid: true,
  axes: true,
  objects: (
    dgs-eq("x^2", color: "blue"),
    dgs-eq("sin(x * 3)", color: "red"),
    dgs-eq("0.5 * x + 0.5", color: "green"),
  )
)

== Parametric Curve

#dgs-canvas(
  x1: -2, y1: -2, x2: 2, y2: 2,
  width: 250pt, height: 250pt,
  theme: "dark",
  grid: true,
  axes: true,
  objects: (
    dgs-eq-param("cos(t)", "sin(t)", t1: 0, t2: 6.28, color: "cyan"),
    dgs-eq-param("cos(t) * 0.5", "sin(t) * 0.5", t1: 0, t2: 6.28, color: "orange"),
  )
)

== Dark Theme

#dgs-canvas(
  x1: -5, y1: -5, x2: 5, y2: 5,
  width: 300pt, height: 300pt,
  theme: "dark",
  grid: true,
  grid-color: luma(60),
  axes: true,
  objects: (
    dgs-point("P", 3, 2, color: "yellow", size: 6pt),
    dgs-circle((0, 0), 4, color: "cyan", stroke: 2pt),
    dgs-eq("sqrt(16 - x^2)", color: "green", stroke: 2pt),
    dgs-eq("-sqrt(16 - x^2)", color: "green", stroke: 2pt),
  )
)

== Ellipse and Arc

#dgs-canvas(
  x1: -4, y1: -3, x2: 4, y2: 3,
  width: 300pt, height: 200pt,
  theme: "light",
  grid: true,
  axes: true,
  objects: (
    dgs-ellipse((0, 0), 3, 1.5, rotation: 30deg, color: "purple", stroke: 1.5pt),
    dgs-arc((0, 0), 2, 0deg, 135deg, color: "orange", stroke: 2pt),
  )
)
