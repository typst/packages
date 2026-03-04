// Compact showcase — All chart types using page-grid layout engine
#import "../src/lib.typ": *

#set page(margin: (x: 0.6cm, y: 0.6cm), paper: "a4", fill: rgb("#1a1a2e"))
#set text(size: 7pt, fill: rgb("#e0e0e0"))

#let dk = themes.dark
#let gk = (..dk, title-size: 7pt)

// Standard cell sizes for 2-col × 4-row layout on A4
#let W = 250pt
#let H = 100pt
#let Hs = 95pt

// ── All charts as a flat array ─────────────────────────────────────────────────

#page-grid(cols: 2, rows: 4, (

  // 1. bar-chart
  bar-chart(
    (labels: ("net", "fs", "drivers", "mm", "arch", "kernel"),
     values: (4820, 3150, 8930, 2710, 2340, 1890)),
    width: W, height: H, title: "bar-chart", y-label: "Commits", theme: dk,
  ),

  // 2. horizontal-bar-chart
  horizontal-bar-chart(
    (labels: ("drivers", "net", "fs", "arch", "sound", "crypto"),
     values: (312, 187, 145, 98, 67, 42)),
    width: W, height: H, title: "horizontal-bar-chart", x-label: "Patches", theme: dk,
  ),

  // 3. grouped-bar-chart
  grouped-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     series: (
       (name: "net", values: (1240, 1380, 1150, 1050)),
       (name: "fs", values: (780, 820, 910, 640)),
       (name: "mm", values: (620, 710, 680, 700)),
     )),
    width: W, height: H, title: "grouped-bar-chart", theme: dk,
  ),

  // 4. stacked-bar-chart
  stacked-bar-chart(
    (labels: ("6.1", "6.2", "6.3", "6.4", "6.5"),
     series: (
       (name: "Memory", values: (42, 38, 35, 31, 28)),
       (name: "Concurrency", values: (28, 32, 25, 22, 19)),
       (name: "Logic", values: (55, 48, 52, 45, 40)),
     )),
    width: W, height: H, title: "stacked-bar-chart", theme: dk,
  ),

  // 5. line-chart
  line-chart(
    (labels: ("5.15", "5.19", "6.1", "6.3", "6.5", "6.7", "6.9"),
     values: (11.2, 11.8, 12.1, 12.5, 12.9, 13.2, 13.6)),
    width: W, height: Hs, title: "line-chart", show-points: true, y-label: "M LoC", theme: dk,
  ),

  // 6. multi-line-chart
  multi-line-chart(
    (labels: ("5.15", "6.0", "6.3", "6.6", "6.9"),
     series: (
       (name: "defconfig", values: (85, 92, 98, 105, 112)),
       (name: "allmodconfig", values: (340, 365, 390, 420, 445)),
       (name: "tinyconfig", values: (18, 19, 20, 21, 22)),
     )),
    width: W, height: Hs, title: "multi-line-chart", theme: dk,
  ),

  // 7. area-chart
  area-chart(
    (labels: ("5.0", "5.5", "5.10", "5.15", "6.0", "6.5", "6.9"),
     values: (26.1, 27.8, 29.2, 30.5, 31.4, 33.1, 35.2)),
    width: W, height: Hs, title: "area-chart", fill-opacity: 40%, y-label: "M LoC", theme: dk,
  ),

  // 8. stacked-area-chart
  stacked-area-chart(
    (labels: ("2020", "2021", "2022", "2023", "2024"),
     series: (
       (name: "Corporate", values: (1850, 1920, 2050, 2180, 2310)),
       (name: "Independent", values: (620, 580, 550, 510, 480)),
       (name: "Academic", values: (180, 195, 210, 230, 250)),
     )),
    width: W, height: Hs, title: "stacked-area-chart", theme: dk,
  ),

  // ── page 2 ──

  // 9. pie-chart
  pie-chart(
    (labels: ("drivers", "arch", "fs", "net", "sound", "other"),
     values: (42, 16, 12, 10, 5, 15)),
    size: 85pt, title: "pie-chart", theme: dk,
  ),

  // 10. pie-chart (donut)
  pie-chart(
    (labels: ("merged", "rejected", "pending", "deferred"),
     values: (65, 15, 12, 8)),
    size: 85pt, title: "pie-chart (donut)", donut: true, donut-ratio: 0.5, theme: dk,
  ),

  // 11. radar-chart
  radar-chart(
    (labels: ("Test Cov", "Doc", "Review", "Latency", "Churn", "Bugs"),
     series: (
       (name: "net", values: (85, 70, 92, 78, 65, 80)),
       (name: "mm", values: (72, 55, 88, 90, 45, 70)),
     )),
    size: 100pt, title: "radar-chart", fill-opacity: 25%, theme: dk,
  ),

  // 12. scatter-plot
  scatter-plot(
    (x: (12, 28, 45, 8, 35, 18, 52),
     y: (3, 12, 22, 2, 18, 8, 28)),
    width: W, height: Hs, title: "scatter-plot",
    x-label: "Complexity", y-label: "Bugs",
    annotations: (
      (type: "h-line", value: 15, label: "Threshold", color: rgb("#ff6b6b"), dash: "dashed"),
    ),
    theme: dk,
  ),

  // 13. multi-scatter-plot
  multi-scatter-plot(
    (series: (
       (name: "net", points: ((5, 12), (8, 18), (12, 25), (15, 30))),
       (name: "fs", points: ((4, 8), (7, 14), (11, 16), (14, 22))),
       (name: "mm", points: ((3, 5), (6, 10), (10, 13), (13, 18))),
     )),
    width: W, height: Hs, title: "multi-scatter-plot",
    x-label: "Commits (K)", y-label: "Churn (K LoC)", theme: dk,
  ),

  // 14. bubble-chart
  bubble-chart(
    (x: (45, 85, 120, 65, 95),
     y: (12, 18, 8, 22, 15),
     size: (300, 180, 450, 120, 250),
     labels: ("net", "fs", "drv", "mm", "arch")),
    width: W, height: Hs, title: "bubble-chart",
    x-label: "Files (K)", y-label: "Open Bugs",
    show-labels: true, labels: ("net", "fs", "drv", "mm", "arch"), theme: dk,
  ),

  // 15. gauge-chart
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[gauge-chart]
    #v(2pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gauge-chart(78, size: 55pt, title: "Build", label: "pass", theme: gk),
      gauge-chart(94, size: 55pt, title: "Boot", label: "pass", theme: gk),
      gauge-chart(61, size: 55pt, title: "Perf", label: "score", theme: gk),
    )
  ],

  // 16. progress-bar + circular-progress
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[progress-bar · circular-progress]
    #v(3pt)
    #progress-bar(87, width: 230pt, title: "Test Coverage", theme: dk)
    #v(3pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      circular-progress(85, size: 50pt, title: "net", theme: dk),
      circular-progress(62, size: 50pt, title: "fs", color: rgb("#ff6b6b"), theme: dk),
      circular-progress(78, size: 50pt, title: "mm", color: rgb("#0be881"), theme: dk),
    )
  ],

  // ── page 3 ──

  // 17. ring-progress
  ring-progress(
    (
      (name: "Move", value: 420, max: 500),
      (name: "Exercise", value: 28, max: 30),
      (name: "Stand", value: 10, max: 12),
    ),
    size: 85pt, ring-width: 8pt, title: "ring-progress", theme: dk,
  ),

  // 18. dual-axis-chart
  dual-axis-chart(
    (labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
     left: (name: "Revenue ($K)", values: (120, 150, 180, 165, 210, 240)),
     right: (name: "Users (K)", values: (1.2, 1.8, 2.1, 2.5, 3.0, 3.8))),
    width: W, height: Hs, title: "dual-axis-chart", theme: dk,
  ),

  // 19. histogram
  histogram(
    (2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8,
     9, 9, 10, 10, 11, 12, 14, 15, 18, 22, 25, 30, 35, 42, 55, 70, 95),
    width: W, height: Hs, title: "histogram", bins: 12, theme: dk,
  ),

  // 20. waterfall-chart
  waterfall-chart(
    (labels: ("Start", "+Sales", "+Svc", "-COGS", "-OpEx", "Total"),
     values: (1200, 350, 180, -280, -150, 1300)),
    width: W, height: Hs, title: "waterfall-chart", theme: dk,
  ),

  // 21. funnel-chart
  funnel-chart(
    (labels: ("Submitted", "Reviewed", "Acked", "Applied", "Released"),
     values: (5000, 3200, 2100, 1800, 1650)),
    width: W, height: 110pt, title: "funnel-chart", theme: dk,
  ),

  // 22. box-plot
  box-plot(
    (labels: ("CFS", "EEVDF", "BPF", "RT"),
     boxes: (
       (min: 5, q1: 12, median: 18, q3: 28, max: 45),
       (min: 3, q1: 8, median: 14, q3: 22, max: 38),
       (min: 2, q1: 6, median: 11, q3: 18, max: 30),
       (min: 1, q1: 3, median: 5, q3: 8, max: 15),
     )),
    width: W, height: 110pt, title: "box-plot", show-grid: true, theme: dk,
  ),

  // 23. heatmap
  heatmap(
    (rows: ("net", "fs", "mm", "drv"),
     cols: ("Mon", "Tue", "Wed", "Thu", "Fri"),
     values: (
       (82, 95, 78, 88, 65),
       (45, 52, 68, 71, 38),
       (33, 41, 55, 48, 29),
       (91, 87, 93, 85, 72),
     )),
    cell-size: 22pt, title: "heatmap", palette: "viridis", theme: dk,
  ),

  // 24. correlation-matrix
  correlation-matrix(
    (labels: ("net", "fs", "mm", "drv", "arch"),
     values: (
       (1.0, 0.7, 0.4, 0.8, 0.3),
       (0.7, 1.0, 0.5, 0.6, 0.4),
       (0.4, 0.5, 1.0, 0.3, 0.6),
       (0.8, 0.6, 0.3, 1.0, 0.5),
       (0.3, 0.4, 0.6, 0.5, 1.0),
     )),
    cell-size: 22pt, title: "correlation-matrix", theme: dk,
  ),

  // ── page 4 ──

  // 25. calendar-heatmap
  calendar-heatmap(
    (dates: ("2024-03-01", "2024-03-02", "2024-03-03", "2024-03-04", "2024-03-05",
             "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10",
             "2024-03-11", "2024-03-12", "2024-03-13", "2024-03-14", "2024-03-15",
             "2024-03-16", "2024-03-17", "2024-03-18", "2024-03-19", "2024-03-20",
             "2024-03-21", "2024-03-22", "2024-03-23", "2024-03-24", "2024-03-25",
             "2024-03-26", "2024-03-27", "2024-03-28"),
     values: (12, 8, 3, 15, 22, 18, 5, 9, 14, 2, 20, 25, 11, 7, 16, 4, 1, 19, 23, 13, 10, 6, 17, 8, 21, 15, 12, 9)),
    cell-size: 10pt, title: "calendar-heatmap", palette: "heat", theme: dk,
  ),

  // 26. progress-bars
  progress-bars(
    (labels: ("net", "fs", "mm", "drivers", "arch"),
     values: (87, 72, 65, 91, 58)),
    width: W, title: "progress-bars", theme: dk,
  ),

  // 27. sparklines
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[sparkline · sparkbar · sparkdot]
    #v(2pt)
    #table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 3pt,
      stroke: rgb("#333355"),
      fill: rgb("#1a1a2e"),
      [*Subsystem*], [*sparkline*], [*sparkbar*], [*sparkdot*],
      [networking], [#sparkline((45, 52, 48, 61, 58, 72, 68), color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar((8, 12, 9, 15, 11, 18, 14), color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot((5, 3, 4, 2, 3, 1, 2), color: rgb("#ff6b6b"), width: 50pt, height: 12pt)],
      [memory], [#sparkline((32, 28, 35, 31, 38, 42, 40), color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar((6, 8, 5, 10, 7, 12, 9), color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot((8, 6, 7, 5, 4, 3, 2), color: rgb("#0be881"), width: 50pt, height: 12pt)],
      [filesystems], [#sparkline((22, 25, 19, 28, 24, 30, 27), color: rgb("#00d2ff"), width: 50pt, height: 12pt)], [#sparkbar((4, 6, 3, 8, 5, 9, 7), color: rgb("#ff9f43"), width: 50pt, height: 12pt)], [#sparkdot((3, 4, 2, 3, 2, 1, 1), color: rgb("#0be881"), width: 50pt, height: 12pt)],
    )
  ],

  // 28. treemap
  treemap(
    (labels: ("Rent", "Food", "Transport", "Fun", "Savings", "Health"),
     values: (1200, 800, 400, 300, 500, 250)),
    width: W, height: 110pt, title: "treemap", theme: dk,
  ),

  // 29. sankey-chart
  sankey-chart(
    (nodes: ("Budget", "Salary", "Invest", "Rent", "Food", "Save", "Stocks", "Bonds"),
     flows: (
       (from: 0, to: 1, value: 5000),
       (from: 0, to: 2, value: 2000),
       (from: 1, to: 3, value: 2000),
       (from: 1, to: 4, value: 1500),
       (from: 1, to: 5, value: 1500),
       (from: 2, to: 6, value: 1200),
       (from: 2, to: 7, value: 800),
     )),
    width: W, height: 110pt, title: "sankey-chart", show-labels: true, theme: dk,
  ),

  // 30. lollipop-chart
  lollipop-chart(
    (labels: ("A", "B", "C", "D", "E", "F"),
     values: (35, 58, 42, 71, 29, 53)),
    width: W, height: Hs, title: "lollipop-chart", theme: dk,
  ),

  // 31. horizontal-lollipop-chart
  horizontal-lollipop-chart(
    (labels: ("Alpha", "Beta", "Gamma", "Delta"),
     values: (82, 65, 91, 47)),
    width: W, height: Hs, title: "horizontal-lollipop-chart", theme: dk,
  ),

  // 32. diverging-bar-chart
  diverging-bar-chart(
    (labels: ("Product A", "Product B", "Product C", "Product D"),
     left-values: (45, 30, 60, 25),
     right-values: (55, 70, 40, 75),
     left-label: "Disagree",
     right-label: "Agree"),
    width: W, height: Hs, title: "diverging-bar-chart", theme: dk,
  ),

  // ── page 5 ──

  // 33. slope-chart
  slope-chart(
    (labels: ("Company A", "Company B", "Company C", "Company D"),
     start-values: (85, 70, 60, 45),
     end-values: (65, 90, 55, 80),
     start-label: "2023",
     end-label: "2024"),
    width: W, height: 105pt, title: "slope-chart", theme: dk,
  ),

  // 34. bullet-chart
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[bullet-chart]
    #v(2pt)
    #bullet-chart(275, 250, (150, 225, 300), width: 230pt, height: 22pt, title: "Revenue", theme: dk)
    #v(2pt)
    #bullet-chart(82, 90, (60, 80, 100), width: 230pt, height: 22pt, title: "Satisfaction", theme: dk)
    #v(2pt)
    #bullet-chart(45, 50, (25, 40, 60), width: 230pt, height: 22pt, title: "Customers", theme: dk)
  ],

  // 35. grouped-stacked-bar-chart
  grouped-stacked-bar-chart(
    (labels: ("Q1", "Q2", "Q3", "Q4"),
     groups: (
       (name: "Product A", segments: (
         (name: "Online", values: (40, 50, 60, 70)),
         (name: "Retail", values: (30, 35, 40, 45)),
       )),
       (name: "Product B", segments: (
         (name: "Online", values: (25, 30, 35, 40)),
         (name: "Retail", values: (20, 25, 30, 35)),
       )),
     )),
    width: W, height: H, title: "grouped-stacked-bar-chart", theme: dk,
  ),

  // 36. gantt-chart
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[gantt-chart]
    #v(2pt)
    #gantt-chart(
      (tasks: (
        (name: "Research", start: 0, end: 3, group: "Plan"),
        (name: "Design", start: 2, end: 5, group: "Plan"),
        (name: "Backend", start: 4, end: 9, group: "Dev"),
        (name: "Frontend", start: 5, end: 10, group: "Dev"),
        (name: "Testing", start: 8, end: 12, group: "QA"),
        (name: "Launch", start: 12, end: 13, group: "Ship"),
       ),
       time-labels: ("W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10", "W11", "W12", "W13")),
      width: 230pt, bar-height: 10pt, gap: 2pt, today: 7, title: none, theme: dk,
    )
  ],

  // 37. waffle-chart
  waffle-chart(
    (labels: ("Rust", "C", "Python", "Go", "Other"),
     values: (35, 28, 18, 12, 7)),
    size: 120pt, gap: 1pt, title: "waffle-chart", theme: dk,
  ),

  // 38. bump-chart
  bump-chart(
    (labels: ("Jan", "Feb", "Mar", "Apr", "May"),
     series: (
       (name: "Alpha", values: (1, 2, 1, 3, 2)),
       (name: "Beta", values: (3, 1, 2, 1, 1)),
       (name: "Gamma", values: (2, 3, 3, 2, 3)),
     )),
    width: W, height: 110pt, title: "bump-chart", dot-size: 4pt, theme: dk,
  ),

  // 39. dumbbell-chart
  dumbbell-chart(
    (labels: ("Revenue", "Users", "NPS", "Uptime", "Latency"),
     start-values: (45, 60, 72, 88, 35),
     end-values: (78, 85, 68, 95, 22),
     start-label: "2023",
     end-label: "2024"),
    width: W, height: 110pt, title: "dumbbell-chart", show-values: true, theme: dk,
  ),

  // 40. radial-bar-chart
  radial-bar-chart(
    (labels: ("Sales", "Marketing", "Eng", "Design", "Support"),
     values: (85, 72, 95, 60, 78)),
    size: 120pt, title: "radial-bar-chart", show-labels: true, theme: dk,
  ),

  // ── page 6 ──

  // 41. sunburst-chart
  sunburst-chart(
    (name: "Total",
     children: (
       (name: "A", value: 40,
        children: (
          (name: "A1", value: 25),
          (name: "A2", value: 15),
        )),
       (name: "B", value: 35,
        children: (
          (name: "B1", value: 20),
          (name: "B2", value: 15),
        )),
       (name: "C", value: 25),
     )),
    size: 120pt, inner-radius: 20pt, ring-width: 25pt, title: "sunburst-chart", theme: dk,
  ),

  // 42. metric-card + metric-row
  [
    #text(size: 8pt, weight: "bold", fill: rgb("#e0e0e0"))[metric-card · metric-row]
    #v(3pt)
    #metric-row(
      (
        (value: 12847, label: "Users", delta: 12.3, trend: (45, 52, 48, 61, 58, 72)),
        (value: 94.2, label: "Uptime", delta: 0.5, suffix: "%", trend: (91, 93, 92, 94, 93, 94)),
        (value: 342, label: "Issues", delta: -8.1, trend: (380, 365, 370, 355, 350, 342)),
      ),
      width: 250pt, gap: 5pt, theme: dk,
    )
  ],

  // 43. violin-plot
  violin-plot(
    (labels: ("Group A", "Group B", "Group C"),
     datasets: (
       (5, 8, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35, 38, 40, 42, 45, 48, 50, 52, 55),
       (10, 15, 20, 22, 25, 25, 28, 30, 30, 32, 35, 35, 38, 40, 42, 45, 50, 55, 60, 65),
       (2, 5, 8, 10, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35, 38, 42, 48, 55, 62, 70),
     )),
    width: W, height: 115pt, title: "violin-plot", theme: dk,
  ),

  // 44. timeline-chart
  timeline-chart(
    (events: (
       (date: "Jan 2024", title: "Kickoff", description: "Project started"),
       (date: "Mar 2024", title: "Alpha", description: "First release"),
       (date: "Jun 2024", title: "Beta", description: "Public beta"),
       (date: "Sep 2024", title: "v1.0", description: "Stable release"),
     )),
    width: W, event-gap: 45pt, title: "timeline-chart", theme: dk,
  ),

  // 45. parliament-chart
  parliament-chart(
    (labels: ("Party A", "Party B", "Party C", "Party D", "Indep"),
     values: (120, 95, 55, 25, 5)),
    size: 130pt, dot-size: 3pt, title: "parliament-chart", theme: dk,
  ),

  // 46. chord-diagram
  chord-diagram(
    (labels: ("Web", "API", "DB", "Cache", "Queue"),
     matrix: (
       (0, 25, 15, 10, 5),
       (20, 0, 30, 8, 12),
       (10, 25, 0, 20, 5),
       (8, 5, 15, 0, 10),
       (3, 10, 5, 8, 0),
     )),
    size: 130pt, arc-width: 10pt, title: "chord-diagram", theme: dk,
  ),

))

// ── Page 7: Full-page word cloud ─────────────────────────────────────────────
#pagebreak()
#word-cloud(
  (words: (
     (text: "Typst", weight: 10),
     (text: "Charts", weight: 9),
     (text: "Data", weight: 8),
     (text: "Visualization", weight: 8),
     (text: "Graphs", weight: 7),
     (text: "Plots", weight: 7),
     (text: "Analytics", weight: 6),
     (text: "Dashboard", weight: 6),
     (text: "Metrics", weight: 5),
     (text: "Trends", weight: 5),
     (text: "Reports", weight: 5),
     (text: "Insights", weight: 4),
     (text: "KPI", weight: 4),
     (text: "Heatmap", weight: 4),
     (text: "Scatter", weight: 4),
     (text: "Histogram", weight: 3),
     (text: "Sunburst", weight: 3),
     (text: "Funnel", weight: 3),
     (text: "Radar", weight: 3),
     (text: "Gauge", weight: 3),
     (text: "Pie", weight: 3),
     (text: "Donut", weight: 3),
     (text: "Waterfall", weight: 3),
     (text: "Violin", weight: 3),
     (text: "Sankey", weight: 2),
     (text: "Treemap", weight: 2),
     (text: "Bubble", weight: 2),
     (text: "Waffle", weight: 2),
     (text: "Gantt", weight: 2),
     (text: "Timeline", weight: 2),
     (text: "Sparkline", weight: 2),
     (text: "Progress", weight: 2),
     (text: "Slope", weight: 2),
     (text: "Bullet", weight: 2),
     (text: "Chord", weight: 2),
     (text: "Bump", weight: 2),
     (text: "Lollipop", weight: 2),
     (text: "Dumbbell", weight: 2),
     (text: "Parliament", weight: 2),
     (text: "Diverging", weight: 2),
     (text: "Stacked", weight: 2),
     (text: "Grouped", weight: 2),
     (text: "Correlation", weight: 2),
     (text: "Calendar", weight: 2),
     (text: "Radial", weight: 2),
     (text: "Ring", weight: 2),
     (text: "Axis", weight: 1),
     (text: "Legend", weight: 1),
     (text: "Theme", weight: 1),
     (text: "Grid", weight: 1),
     (text: "Label", weight: 1),
     (text: "Tick", weight: 1),
     (text: "Scale", weight: 1),
     (text: "Color", weight: 1),
     (text: "Layout", weight: 1),
     (text: "Density", weight: 1),
     (text: "Distribution", weight: 1),
     (text: "Percentage", weight: 1),
     (text: "Comparison", weight: 1),
     (text: "Proportion", weight: 1),
     (text: "Hierarchy", weight: 1),
     (text: "Flow", weight: 1),
     (text: "Series", weight: 1),
     (text: "Category", weight: 1),
     (text: "Value", weight: 1),
     (text: "Range", weight: 1),
     (text: "Median", weight: 1),
     (text: "Quartile", weight: 1),
   )),
  width: 100%, height: 100%, title: "word-cloud", shape: "circle", theme: dk,
)
