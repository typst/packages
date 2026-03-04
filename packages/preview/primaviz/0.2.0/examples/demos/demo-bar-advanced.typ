// Advanced bar charts: grouped-stacked + diverging, light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  grouped-stacked-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     groups: (
       (name: "Product A", segments: (
         (name: "Online", values: (40, 50, 60, 70)),
         (name: "Retail", values: (30, 35, 40, 45)),
       )),
       (name: "Product B", segments: (
         (name: "Online", values: (25, 30, 35, 40)),
         (name: "Retail", values: (20, 25, 30, 35)),
       )),
     )),
    width: W, height: H, title: "grouped-stacked (light)", theme: lt,
  ),
  grouped-stacked-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     groups: (
       (name: "Product A", segments: (
         (name: "Online", values: (40, 50, 60, 70)),
         (name: "Retail", values: (30, 35, 40, 45)),
       )),
       (name: "Product B", segments: (
         (name: "Online", values: (25, 30, 35, 40)),
         (name: "Retail", values: (20, 25, 30, 35)),
       )),
     )),
    width: W, height: H, title: "grouped-stacked (dark)", theme: dk,
  ),
  diverging-bar-chart(
    (labels: ("Product A", "Product B", "Product C", "Product D"),
     left-values: (45, 30, 60, 25),
     right-values: (55, 70, 40, 75),
     left-label: "Disagree",
     right-label: "Agree"),
    width: W, height: H, title: "diverging-bar (light)", theme: lt,
  ),
  diverging-bar-chart(
    (labels: ("Product A", "Product B", "Product C", "Product D"),
     left-values: (45, 30, 60, 25),
     right-values: (55, 70, 40, 75),
     left-label: "Disagree",
     right-label: "Agree"),
    width: W, height: H, title: "diverging-bar (dark)", theme: dk,
  ),
))
