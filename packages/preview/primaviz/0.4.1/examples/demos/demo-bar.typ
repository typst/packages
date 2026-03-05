// Bar charts: vertical + horizontal, light + dark
#import "../../src/lib.typ": *
#import "../demo-data.typ": codebase
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  bar-chart(codebase.subsystems,
    width: W, height: H, title: "bar-chart (light)", y-label: "LoC", theme: lt,
  ),
  bar-chart(codebase.subsystems,
    width: W, height: H, title: "bar-chart (dark)", y-label: "LoC", theme: dk,
  ),
  horizontal-bar-chart(codebase.patches,
    width: W, height: H, title: "horizontal-bar-chart (light)", x-label: "Patches", theme: lt,
  ),
  horizontal-bar-chart(codebase.patches,
    width: W, height: H, title: "horizontal-bar-chart (dark)", x-label: "Patches", theme: dk,
  ),
))
