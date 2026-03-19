// Gauge & progress: gauge, dark gauge, progress-bar, circular-progress
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  [
    #align(center, text(size: 9pt, weight: "bold")[gauge-chart (light)])
    #v(4pt)
    #grid(columns: (1fr, 1fr, 1fr),
      gauge-chart(sales.conversion-rate, size: 80pt, title: "Conversion", label: "rate", theme: lt),
      gauge-chart(sales.uptime, size: 80pt, title: "Uptime", label: "%", theme: lt),
      gauge-chart(sales.nps, size: 80pt, title: "NPS", label: "score", theme: lt),
    )
  ],
  box(fill: rgb("#1a1a2e"), inset: 8pt, radius: 4pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#e0e0e0"))[gauge-chart (dark)]
    #v(4pt)
    #grid(columns: (1fr, 1fr, 1fr),
      gauge-chart(sales.conversion-rate, size: 80pt, title: "Conversion", label: "rate", theme: dk),
      gauge-chart(sales.uptime, size: 80pt, title: "Uptime", label: "%", theme: dk),
      gauge-chart(sales.nps, size: 80pt, title: "NPS", label: "score", theme: dk),
    )
  ],
  [
    #align(center, text(size: 9pt, weight: "bold")[progress-bar])
    #v(4pt)
    #progress-bar(sales.targets.values.at(0), width: 230pt, title: "Sales", theme: lt)
    #v(6pt)
    #progress-bar(sales.targets.values.at(1), width: 230pt, title: "Engineering", color: rgb("#f28e2b"), theme: lt)
    #v(6pt)
    #progress-bar(sales.targets.values.at(2), width: 230pt, title: "Marketing", color: rgb("#e15759"), theme: lt)
  ],
  [
    #align(center, text(size: 9pt, weight: "bold")[circular-progress])
    #v(4pt)
    #grid(columns: (1fr, 1fr, 1fr),
      circular-progress(sales.targets.values.at(0), size: 80pt, title: "Sales", theme: lt),
      circular-progress(sales.targets.values.at(1), size: 80pt, title: "Eng", color: rgb("#f28e2b"), theme: lt),
      circular-progress(sales.targets.values.at(2), size: 80pt, title: "Mktg", color: rgb("#59a14f"), theme: lt),
    )
  ],
))
