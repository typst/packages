// Bump & funnel: bump light + dark, funnel light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  bump-chart(
    (labels: ("Jan", "Feb", "Mar", "Apr", "May"),
     series: (
       (name: "Alpha", values: (1, 2, 1, 3, 2)),
       (name: "Beta", values: (3, 1, 2, 1, 1)),
       (name: "Gamma", values: (2, 3, 3, 2, 3)),
     )),
    width: W, height: H, title: "bump-chart (light)", dot-size: 4pt, theme: lt,
  ),
  bump-chart(
    (labels: ("Jan", "Feb", "Mar", "Apr", "May"),
     series: (
       (name: "Alpha", values: (1, 2, 1, 3, 2)),
       (name: "Beta", values: (3, 1, 2, 1, 1)),
       (name: "Gamma", values: (2, 3, 3, 2, 3)),
     )),
    width: W, height: H, title: "bump-chart (dark)", dot-size: 4pt, theme: dk,
  ),
  funnel-chart(
    (labels: ("Submitted", "Reviewed", "Acked", "Applied", "Released"),
     values: (5000, 3200, 2100, 1800, 1650)),
    width: W, height: H, title: "funnel-chart (light)", theme: lt,
  ),
  funnel-chart(
    (labels: ("Submitted", "Reviewed", "Acked", "Applied", "Released"),
     values: (5000, 3200, 2100, 1800, 1650)),
    width: W, height: H, title: "funnel-chart (dark)", theme: dk,
  ),
))
