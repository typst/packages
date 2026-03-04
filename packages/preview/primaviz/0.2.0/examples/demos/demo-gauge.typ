// Gauge & progress: gauge, dark gauge, progress-bar, circular-progress
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  [
    #text(size: 9pt, weight: "bold")[gauge-chart (light)]
    #v(4pt)
    #grid(columns: (1fr, 1fr, 1fr),
      gauge-chart(78, size: 80pt, title: "Build", label: "pass", theme: lt),
      gauge-chart(94, size: 80pt, title: "Boot", label: "pass", theme: lt),
      gauge-chart(61, size: 80pt, title: "Perf", label: "score", theme: lt),
    )
  ],
  box(fill: rgb("#1a1a2e"), inset: 8pt, radius: 4pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#e0e0e0"))[gauge-chart (dark)]
    #v(4pt)
    #grid(columns: (1fr, 1fr, 1fr),
      gauge-chart(78, size: 80pt, title: "Build", label: "pass", theme: dk),
      gauge-chart(94, size: 80pt, title: "Boot", label: "pass", theme: dk),
      gauge-chart(61, size: 80pt, title: "Perf", label: "score", theme: dk),
    )
  ],
  [
    #text(size: 9pt, weight: "bold")[progress-bar]
    #v(4pt)
    #progress-bar(87, width: 230pt, title: "Test Coverage", theme: lt)
    #v(6pt)
    #progress-bar(62, width: 230pt, title: "Build Pass Rate", color: rgb("#f28e2b"), theme: lt)
    #v(6pt)
    #progress-bar(45, width: 230pt, title: "Doc Coverage", color: rgb("#e15759"), theme: lt)
  ],
  [
    #text(size: 9pt, weight: "bold")[circular-progress]
    #v(4pt)
    #grid(columns: (1fr, 1fr, 1fr),
      circular-progress(85, size: 80pt, title: "net", theme: lt),
      circular-progress(62, size: 80pt, title: "fs", color: rgb("#f28e2b"), theme: lt),
      circular-progress(78, size: 80pt, title: "mm", color: rgb("#59a14f"), theme: lt),
    )
  ],
))
