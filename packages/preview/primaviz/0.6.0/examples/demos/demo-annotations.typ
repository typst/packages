// Annotations, error bars, and outliers: content/point/errorbar/rect overlays
// plus native errors: parameter and box-plot outliers: field.
#import "@preview/primaviz:0.6.0": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

// --- Bar chart with native error bars + h-line target + content annotation ---
#let bar-data = (
  labels: ("Q1", "Q2", "Q3", "Q4"),
  values: (120, 150, 165, 180),
)
#let bar-errors = (10, 12, 8, 15)  // symmetric

// --- Line chart with h-band confidence + point + content annotations ---
#let line-data = (
  labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
  values: (42, 55, 48, 72, 68, 85),
)

// --- Box plot with outliers ---
#let box-data = (
  labels: ("Group A", "Group B", "Group C"),
  boxes: (
    (min: 20, q1: 35, median: 50, q3: 65, max: 80, outliers: (95, 5)),
    (min: 15, q1: 30, median: 45, q3: 60, max: 75, outliers: (92, 88)),
    (min: 25, q1: 40, median: 52, q3: 68, max: 82, outliers: (2,)),
  ),
)

// --- Scatter with errorbar annotations + rect region + content label ---
#let scatter-data = (
  x: (1, 2, 3, 4, 5, 6),
  y: (12, 18, 15, 22, 28, 25),
)

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  bar-chart(bar-data,
    width: W, height: H,
    title: "errors + annotations",
    x-label: "Quarter", y-label: "Revenue (k$)",
    errors: bar-errors,
    show-values: false,
    annotations: (
      (type: "h-line", value: 160, color: rgb("#c0392b"), dash: "dashed", label: "target"),
      (type: "content", x: 2, y: 165, body: text(weight: "bold", fill: rgb("#c0392b"))[★ hit], anchor: "bottom"),
    ),
    theme: lt,
  ),
  line-chart(line-data,
    width: W, height: H,
    title: "h-band + content",
    x-label: "Month", y-label: "Sales",
    show-points: true,
    annotations: (
      (type: "h-band", from: 60, to: 75, color: rgb("#2ecc71"), opacity: 18%, label: "goal zone"),
      (type: "content", x: 5, y: 85, body: text(fill: rgb("#e74c3c"), weight: "bold")[peak], anchor: "bottom"),
      (type: "point", x: 5, y: 85, radius: 4pt, fill: rgb("#e74c3c")),
    ),
    theme: dk,
  ),
  box-plot(box-data,
    width: W, height: H,
    title: "outliers",
    x-label: "Group", y-label: "Value",
    show-grid: true,
    theme: lt,
  ),
  scatter-plot(scatter-data,
    width: W, height: H,
    title: "errorbar + rect + point",
    x-label: "X", y-label: "Y",
    show-grid: true,
    annotations: (
      (type: "rect", x1: 3.5, y1: 20, x2: 5.5, y2: 30, color: rgb("#3498db"), opacity: 15%, label: "region"),
      (type: "errorbar", x: 1, low: 10, high: 14, color: rgb("#7f8c8d")),
      (type: "errorbar", x: 2, low: 16, high: 20, color: rgb("#7f8c8d")),
      (type: "errorbar", x: 3, low: 13, high: 17, color: rgb("#7f8c8d")),
      (type: "errorbar", x: 4, low: 20, high: 24, color: rgb("#7f8c8d")),
      (type: "errorbar", x: 5, low: 26, high: 30, color: rgb("#7f8c8d")),
      (type: "errorbar", x: 6, low: 23, high: 27, color: rgb("#7f8c8d")),
      (type: "content", x: 5, y: 28, body: text(size: 7pt, fill: rgb("#2c3e50"))[outlier], anchor: "left", dx: 6pt),
    ),
    theme: dk,
  ),
))
