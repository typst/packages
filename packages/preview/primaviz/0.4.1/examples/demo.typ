// Chart Demo — Getting started walkthrough using shared datasets
#import "@preview/primaviz:0.4.1": *
#import "demo-data.typ": sales, codebase, league, rpg, words

#set page(margin: 1cm)
#set text(size: 10pt)

= Typst Charting Library Demo

== Bar Charts

=== Vertical Bar Chart
#bar-chart(
  (labels: rpg.characters.map(c => c.name), values: rpg.characters.map(c => c.kills)),
  width: 400pt, height: 180pt,
  title: "Enemy Kills by Character", y-label: "Kills",
)

#v(20pt)

=== Horizontal Bar Chart
#horizontal-bar-chart(codebase.patches,
  width: 400pt, height: 200pt,
  title: "Patches by Subsystem", x-label: "Patches",
)

#pagebreak()

=== Grouped Bar Chart
#grouped-bar-chart(league.team-stats,
  width: 400pt, height: 200pt,
  title: "Team Stats Comparison", y-label: "Count",
)

#v(20pt)

=== Stacked Bar Chart
#stacked-bar-chart(sales.quarterly,
  width: 350pt, height: 200pt,
  title: "Quarterly Sales by Product",
)

#pagebreak()

== Line Charts

=== Single Line Chart
#line-chart(rpg.party-gold,
  width: 450pt, height: 200pt,
  title: "Party Gold by Session", show-points: true,
)

#v(20pt)

=== Multi-Line Chart
#multi-line-chart(league.weekly-goals,
  width: 450pt, height: 200pt,
  title: "Goals per Gameweek",
)

#pagebreak()

== Area Charts

=== Single Area Chart
#area-chart(sales.monthly,
  width: 450pt, height: 180pt,
  title: "Monthly Revenue", fill-opacity: 50%,
)

#v(20pt)

=== Stacked Area Chart
#stacked-area-chart(codebase.commits-by-lang,
  width: 450pt, height: 200pt,
  title: "Commits by Language Over Time",
)

#pagebreak()

== Pie Charts

#grid(
  columns: (1fr, 1fr),
  column-gutter: 20pt,

  [
    === Pie Chart
    #pie-chart(codebase.languages,
      size: 150pt, title: "Language Mix",
    )
  ],

  [
    === Donut Chart
    #pie-chart(rpg.loot-breakdown,
      size: 150pt, title: "Loot Distribution",
      donut: true, donut-ratio: 0.5,
    )
  ]
)

#pagebreak()

== Radar Charts

=== Multi-Series Radar
#radar-chart(league.player-stats,
  size: 250pt, title: "Player Comparison — Striker vs Midfielder",
  fill-opacity: 25%,
)

#pagebreak()

== Scatter Plots

=== Simple Scatter Plot
#scatter-plot(
  (x: rpg.characters.map(c => c.hp), y: rpg.characters.map(c => c.kills)),
  width: 350pt, height: 250pt,
  title: "HP vs Kills", x-label: "Hit Points", y-label: "Kill Count",
)

#v(15pt)

=== Multi-Series Scatter Plot
#multi-scatter-plot(league.home-away,
  width: 350pt, height: 250pt,
  title: "Home vs Away Performance",
  x-label: "Goals Scored", y-label: "Goals Conceded",
)

#pagebreak()

== Bubble Chart

#bubble-chart(league.team-bubble,
  width: 400pt, height: 300pt,
  title: "Goals vs Possession (bubble = market value)",
  x-label: "Goals", y-label: "Possession %",
  min-radius: 8pt, max-radius: 35pt,
  show-labels: true, labels: league.team-bubble.labels,
)

#pagebreak()

== Gauges & Progress Indicators

=== Gauge Charts
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  gauge-chart(sales.conversion-rate, size: 120pt, title: "Conversion", label: "rate"),
  gauge-chart(sales.uptime, size: 120pt, title: "Uptime", label: "%"),
  gauge-chart(sales.nps, size: 120pt, title: "NPS", label: "score"),
)

#v(20pt)

=== Progress Bars
#grid(
  columns: (1fr, 1fr),
  column-gutter: 30pt,

  [
    ==== Horizontal Progress
    #progress-bar(rpg.quest-completion, width: 200pt, title: "Main Quest")
    #v(10pt)
    #progress-bar(rpg.xp-progress, width: 200pt, title: "XP Progress", color: rgb("#f28e2b"))
    #v(10pt)
    #progress-bar(rpg.party-health, width: 200pt, title: "Party Health", color: rgb("#e15759"))
  ],

  [
    ==== Circular Progress
    #grid(
      columns: (1fr, 1fr, 1fr),
      circular-progress(rpg.quest-completion, size: 70pt, title: "Quest"),
      circular-progress(rpg.xp-progress, size: 70pt, title: "XP", color: rgb("#f28e2b")),
      circular-progress(rpg.party-health, size: 70pt, title: "Health", color: rgb("#59a14f")),
    )
  ]
)

#v(20pt)

=== Multiple Progress Bars
#progress-bars(rpg.quest-progress,
  width: 350pt, title: "Campaign Progress",
)

#pagebreak()

== Heatmaps

=== Skill Usage Heatmap
#heatmap(rpg.skill-usage,
  cell-size: 35pt, title: "Skill Usage by Character", palette: "viridis",
)

#v(30pt)

=== Correlation Matrix
#correlation-matrix(codebase.correlation,
  cell-size: 40pt, title: "Module Coupling",
)

#pagebreak()

=== Calendar Heatmap
#calendar-heatmap(league.match-calendar,
  cell-size: 14pt, title: "Match-Day Total Goals", palette: "heat",
)

#pagebreak()

== Sparklines

#v(10pt)

#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  [*Metric*], [*Sparkline*], [*Sparkbar*], [*Sparkdot*],
  [Networking],
    [#sparkline(sales.sparklines.networking, color: rgb("#59a14f"))],
    [#sparkbar(sales.sparklines.networking, color: rgb("#59a14f"))],
    [#sparkdot(sales.sparklines.networking, color: rgb("#59a14f"))],
  [Memory],
    [#sparkline(sales.sparklines.memory, color: rgb("#4e79a7"))],
    [#sparkbar(sales.sparklines.memory, color: rgb("#4e79a7"))],
    [#sparkdot(sales.sparklines.memory, color: rgb("#4e79a7"))],
  [Storage],
    [#sparkline(sales.sparklines.storage, color: rgb("#e15759"))],
    [#sparkbar(sales.sparklines.storage, color: rgb("#e15759"))],
    [#sparkdot(sales.sparklines.storage, color: rgb("#e15759"))],
)

#pagebreak()

== Waterfall Chart

#waterfall-chart(rpg.dungeon-loot,
  width: 400pt, height: 220pt,
  title: "Dungeon Loot — Profit & Loss",
)

#v(30pt)

== Funnel Chart

#funnel-chart(sales.funnel,
  width: 300pt, height: 250pt,
  title: "Sales Pipeline",
)

#pagebreak()

== Box Plot

#box-plot(league.minutes-played,
  width: 350pt, height: 220pt,
  title: "Minutes Played by Position", show-grid: true,
)

#pagebreak()

== Annotations

#v(10pt)

=== Line Chart with Target & Goal Zone
#line-chart(
  sales.monthly,
  width: 400pt, height: 200pt,
  title: "Monthly Revenue with Annotations", show-points: true,
  annotations: (
    (type: "h-band", from: 140, to: 180, label: "Target Zone", color: rgb("#59a14f")),
    (type: "h-line", value: 160, label: "Target", color: rgb("#e15759"), dash: "dashed"),
  ),
)

#v(20pt)

=== Bar Chart with Average Line
#bar-chart(
  (labels: rpg.characters.map(c => c.name), values: rpg.characters.map(c => c.kills)),
  width: 350pt, height: 200pt,
  title: "Kills with Party Average",
  annotations: (
    (type: "h-line", value: 39, label: "Avg", color: rgb("#4e79a7"), dash: "dashed"),
  ),
)

#pagebreak()

== Theme Showcase

=== Dark Theme
#bar-chart(
  (labels: rpg.characters.map(c => c.name), values: rpg.characters.map(c => c.gold)),
  width: 350pt, height: 180pt,
  title: "Gold per Character", theme: themes.dark,
)

#v(20pt)

=== Minimal Theme
#line-chart(sales.monthly,
  width: 350pt, height: 180pt,
  title: "Monthly Revenue", show-points: true, theme: themes.minimal,
)

#v(20pt)

=== Print Theme (grayscale)
#grouped-bar-chart(league.team-stats,
  width: 300pt, height: 160pt,
  title: "Team Stats", theme: themes.print,
)

#v(40pt)

#align(center)[
  #text(size: 8pt, fill: gray)[
    Charts generated using Typst primitives (rect, circle, line, polygon, place) \
    50+ chart types with theme system, validation, and annotations \
    No external dependencies required
  ]
]
