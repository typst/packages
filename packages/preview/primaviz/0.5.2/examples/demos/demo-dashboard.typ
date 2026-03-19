// Dashboard: metric-row, word-cloud, sparklines-table, progress-bars
#import "../../src/lib.typ": *
#import "../demo-data.typ": sales, words
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  [
    #align(center, text(size: 9pt, weight: "bold")[metric-row])
    #v(4pt)
    #metric-row(sales.kpis,
      width: 250pt, gap: 5pt, theme: lt,
    )
  ],
  word-cloud(words,
    width: W, height: 300pt, title: "word-cloud (dark, circle)", shape: "circle", max-size: 22pt, theme: dk,
  ),
  [
    #align(center, text(size: 9pt, weight: "bold")[sparkline / sparkbar / sparkdot])
    #v(4pt)
    #table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 3pt,
      [*Metric*], [*sparkline*], [*sparkbar*], [*sparkdot*],
      [Networking], [#sparkline(sales.sparklines.networking, color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.networking, color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.networking, color: rgb("#e15759"), width: 50pt, height: 12pt)],
      [Memory], [#sparkline(sales.sparklines.memory, color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.memory, color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.memory, color: rgb("#59a14f"), width: 50pt, height: 12pt)],
      [Storage], [#sparkline(sales.sparklines.storage, color: rgb("#4e79a7"), width: 50pt, height: 12pt)], [#sparkbar(sales.sparklines.storage, color: rgb("#f28e2b"), width: 50pt, height: 12pt)], [#sparkdot(sales.sparklines.storage, color: rgb("#59a14f"), width: 50pt, height: 12pt)],
    )
  ],
  progress-bars(sales.targets,
    width: W, title: "progress-bars", max-val: 100, theme: lt,
  ),
))

#pagebreak()

// Page 2: card, compact-table, alert, badge, separator
#let cp = themes.compact

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  card(title: "Quarterly Revenue", desc: "By plan tier", width: W, theme: lt)[
    #compact-table(
      ("Plan", "Q1", "Q2", "Q3", "Q4"),
      (
        ("Enterprise", "120", "150", "180", "210"),
        ("Growth", "80", "95", "110", "140"),
        ("Starter", "40", "45", "50", "55"),
      ),
      highlight-col: 4,
      theme: lt,
    )
  ],
  card(title: "System Alerts", desc: "Status notifications", width: W, theme: dk)[
    #alert([Deployment pipeline running.], variant: "info", title: "Info", theme: dk)
    #alert([CPU usage above 85%.], variant: "warning", title: "Warning", theme: dk)
    #alert([Build failed on staging.], variant: "error", title: "Error", theme: dk)
    #alert([All tests passing.], variant: "success", title: "Success", theme: dk)
  ],
  [
    #align(center, text(size: 9pt, weight: "bold")[badges + separator])
    #v(4pt)
    #badge("Default", variant: "default", theme: lt)
    #h(4pt)
    #badge("Secondary", variant: "secondary", theme: lt)
    #h(4pt)
    #badge("Destructive", variant: "destructive", theme: lt)
    #h(4pt)
    #badge("Outline", variant: "outline", theme: lt)
    #h(4pt)
    #badge("Success", variant: "success", theme: lt)
    #separator(theme: lt)
    #text(size: 8pt)[Badges indicate status, categories, or counts. Use the separator to divide sections visually.]
  ],
  card(title: "Expenses Breakdown", width: W, theme: cp)[
    #bar-chart(sales.expenses,
      width: 100%, height: 160pt,
      title: none, theme: cp,
    )
  ],
))
