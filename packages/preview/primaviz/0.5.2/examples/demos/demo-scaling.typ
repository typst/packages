// Golden-ratio scaling demo: everything auto-sizes from two seed values
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales
#set page(margin: 0.4cm, paper: "a4")
#set text(size: 7pt)

#let sample = (labels: sales.monthly.labels.slice(0, 4), values: sales.monthly.values.slice(0, 4))

// Just change seeds — container, padding, text, strokes all follow
#let scales = (
  (name: "0.5×  (4pt / 3pt)", bs: 4pt, bg: 3pt),
  (name: "1× default  (8pt / 6pt)", bs: 8pt, bg: 6pt),
  (name: "2×  (16pt / 12pt)", bs: 16pt, bg: 12pt),
)

#align(center, text(size: 11pt, weight: "bold")[φ-Scaling: two seeds control everything])
#v(2pt)
#align(center, text(size: 7.5pt, fill: luma(100))[No manual width, height, or cell-size — charts self-size from `base-size` and `base-gap`])
#v(6pt)

// Bar charts — auto width & height from seeds
#for s in scales {
  bar-chart(sample, title: s.name, y-label: "Rev",
    theme: (base-size: s.bs, base-gap: s.bg, show-grid: true))
  v(6pt)
}

#pagebreak()
#align(center, text(size: 11pt, weight: "bold")[φ-Scaling: line charts])
#v(6pt)

#for s in scales {
  line-chart(sample, title: s.name, y-label: "Rev",
    theme: (base-size: s.bs, base-gap: s.bg, show-grid: true))
  v(6pt)
}

#pagebreak()
#align(center, text(size: 11pt, weight: "bold")[φ-Scaling: heatmaps])
#v(6pt)

#let heat-data = (
  rows: ("A", "B", "C"),
  cols: ("X", "Y", "Z"),
  values: ((82, 95, 78), (45, 52, 68), (33, 41, 55)),
)

// cell-size auto-derived from seeds — no manual value needed
#for s in scales {
  heatmap(heat-data, title: s.name,
    theme: (base-size: s.bs, base-gap: s.bg))
  v(6pt)
}
