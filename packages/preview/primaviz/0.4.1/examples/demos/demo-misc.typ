// Miscellaneous: waffle, parliament, radial-bar, sunburst
#import "../../src/lib.typ": *
#import "../demo-data.typ": codebase, sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  waffle-chart(codebase.languages,
    size: 200pt, gap: 1.5pt, title: "waffle-chart (light)", theme: lt,
  ),
  parliament-chart(codebase.contributors,
    size: 210pt, dot-size: 4pt, title: "parliament-chart (dark)", theme: dk,
  ),
  radial-bar-chart(codebase.health,
    size: 200pt, title: "radial-bar-chart (light)", show-labels: true, theme: lt,
  ),
  sunburst-chart(sales.org,
    size: 200pt, inner-radius: 25pt, ring-width: 40pt, title: "sunburst-chart (dark)", theme: dk,
  ),
))
