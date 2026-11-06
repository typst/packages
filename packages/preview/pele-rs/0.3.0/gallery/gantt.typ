#import "@preview/pele-rs:0.3.0": mermaid

#set page(width: 12cm, height: 8cm, margin: 5mm, fill: white)
#set text(font: "Libertinus Serif")
#set align(center + horizon)

// Gantt charts need a fixed clock: 15 January 2026, 12:00 UTC.
#mermaid(width: 100%, height: 100%, now: 1768478400000,
  config: (gantt: (useWidth: 480, barHeight: 26, fontSize: 13, sectionFontSize: 13)), "
gantt
  title Release plan
  dateFormat YYYY-MM-DD
  section Engine
    Port flowcharts :done, f, 2026-01-05, 7d
    Port pie charts :done, p, after f, 3d
    Port the rest   :active, r, after p, 14d
  section Package
    Publish         :milestone, after r, 0d
")
