// Rings & treemap: ring-progress light + dark, treemap light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  ring-progress(
    (
      (name: "Move", value: 420, max: 500),
      (name: "Exercise", value: 28, max: 30),
      (name: "Stand", value: 10, max: 12),
    ),
    size: 180pt, ring-width: 16pt, title: "ring-progress (light)", theme: lt,
  ),
  ring-progress(
    (
      (name: "Move", value: 420, max: 500),
      (name: "Exercise", value: 28, max: 30),
      (name: "Stand", value: 10, max: 12),
    ),
    size: 180pt, ring-width: 16pt, title: "ring-progress (dark)", theme: dk,
  ),
  treemap(
    (labels: ("Rent", "Food", "Transport", "Fun", "Savings", "Health"),
     values: (1200, 800, 400, 300, 500, 250)),
    width: W, height: H, title: "treemap (light)", theme: lt,
  ),
  treemap(
    (labels: ("Rent", "Food", "Transport", "Fun", "Savings", "Health"),
     values: (1200, 800, 400, 300, 500, 250)),
    width: W, height: H, title: "treemap (dark)", theme: dk,
  ),
))
