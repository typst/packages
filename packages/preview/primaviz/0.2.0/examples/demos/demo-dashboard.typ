// Dashboard: metric-row, word-cloud, sparklines-table, progress-bars
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  [
    #text(size: 9pt, weight: "bold")[metric-row]
    #v(4pt)
    #metric-row(
      (
        (value: 12847, label: "Users", delta: 12.3, trend: (45, 52, 48, 61, 58, 72)),
        (value: 94.2, label: "Uptime", delta: 0.5, suffix: "%", trend: (91, 93, 92, 94, 93, 94)),
        (value: 342, label: "Issues", delta: -8.1, trend: (380, 365, 370, 355, 350, 342)),
      ),
      width: 250pt, gap: 5pt, theme: lt,
    )
  ],
  word-cloud(
    (words: (
       (text: "Typst", weight: 10),
       (text: "Charts", weight: 8),
       (text: "Data", weight: 7),
       (text: "Visualization", weight: 6),
       (text: "Graphs", weight: 5),
       (text: "Plots", weight: 5),
       (text: "Analytics", weight: 4),
       (text: "Dashboard", weight: 4),
       (text: "Metrics", weight: 3),
       (text: "Trends", weight: 3),
       (text: "Reports", weight: 2),
       (text: "Insights", weight: 2),
     )),
    width: W, height: 300pt, title: "word-cloud (dark, circle)", shape: "circle", theme: dk,
  ),
  [
    #text(size: 9pt, weight: "bold")[sparkline / sparkbar / sparkdot]
    #v(4pt)
    #table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 3pt,
      [*Subsystem*], [*sparkline*], [*sparkbar*], [*sparkdot*],
      [networking], [#sparkline((45, 52, 48, 61, 58, 72, 68), color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar((8, 12, 9, 15, 11, 18, 14), color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot((5, 3, 4, 2, 3, 1, 2), color: rgb("#e15759"), width: 50pt, height: 12pt)],
      [memory], [#sparkline((32, 28, 35, 31, 38, 42, 40), color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar((6, 8, 5, 10, 7, 12, 9), color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot((8, 6, 7, 5, 4, 3, 2), color: rgb("#59a14f"), width: 50pt, height: 12pt)],
      [filesystems], [#sparkline((22, 25, 19, 28, 24, 30, 27), color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar((4, 6, 3, 8, 5, 9, 7), color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot((3, 4, 2, 3, 2, 1, 1), color: rgb("#59a14f"), width: 50pt, height: 12pt)],
    )
  ],
  progress-bars(
    (labels: ("net", "fs", "mm", "drivers", "arch"),
     values: (87, 72, 65, 91, 58)),
    width: W, title: "progress-bars", theme: dk,
  ),
))
