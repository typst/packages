// Dual-axis chart: light, dark, presentation, minimal
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#let data = (labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
  left: (name: "Revenue ($K)", values: (120, 150, 180, 165, 210, 240)),
  right: (name: "Users (K)", values: (1.2, 1.8, 2.1, 2.5, 3.0, 3.8)))

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  dual-axis-chart(data,
    width: W, height: H, title: "dual-axis (light)", theme: lt,
  ),
  dual-axis-chart(data,
    width: W, height: H, title: "dual-axis (dark)", theme: dk,
  ),
  dual-axis-chart(data,
    width: W, height: H, title: "dual-axis (presentation)", theme: themes.presentation,
  ),
  dual-axis-chart(data,
    width: W, height: H, title: "dual-axis (minimal)", theme: themes.minimal,
  ),
))
