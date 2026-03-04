// Comparison: slope, dumbbell, lollipop, bullet
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  slope-chart(
    (labels: ("Company A", "Company B", "Company C", "Company D"),
     start-values: (85, 70, 60, 45),
     end-values: (65, 90, 55, 80),
     start-label: "2023",
     end-label: "2024"),
    width: W, height: H, title: "slope-chart", theme: lt,
  ),
  dumbbell-chart(
    (labels: ("Revenue", "Users", "NPS", "Uptime", "Latency"),
     start-values: (45, 60, 72, 88, 35),
     end-values: (78, 85, 68, 95, 22),
     start-label: "2023",
     end-label: "2024"),
    width: W, height: H, title: "dumbbell-chart", show-values: true, theme: dk,
  ),
  lollipop-chart(
    (labels: ("A", "B", "C", "D", "E", "F"),
     values: (35, 58, 42, 71, 29, 53)),
    width: W, height: H, title: "lollipop-chart", theme: lt,
  ),
  box(fill: rgb("#1a1a2e"), inset: 8pt, radius: 4pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#e0e0e0"))[bullet-chart (dark)]
    #v(6pt)
    #bullet-chart(275, 250, (150, 225, 300), width: 210pt, height: 28pt, title: "Revenue", theme: dk)
    #v(6pt)
    #bullet-chart(82, 90, (60, 80, 100), width: 210pt, height: 28pt, title: "Satisfaction", theme: dk)
    #v(6pt)
    #bullet-chart(45, 50, (25, 40, 60), width: 210pt, height: 28pt, title: "Customers", theme: dk)
  ],
))
