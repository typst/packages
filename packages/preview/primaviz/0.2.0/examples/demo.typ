// Chart Demo - Comprehensive showcase of all chart types
#import "../src/lib.typ": *

#set page(margin: 1cm)
#set text(size: 10pt)

// Load JSON data
#let chars = json("../data/characters.json")
#let events = json("../data/events.json")
#let analytics = json("../data/analytics.json")

= Typst Charting Library Demo

== Bar Charts

=== Vertical Bar Chart
#bar-chart(
  (
    labels: chars.characters.map(c => c.name.split(" ").at(0)),
    values: chars.characters.map(c => c.kills),
  ),
  width: 400pt,
  height: 180pt,
  title: "Enemy Kills by Character",
  y-label: "Kills",
)

#v(20pt)

=== Horizontal Bar Chart
#horizontal-bar-chart(
  (
    labels: chars.characters.map(c => c.name.split(" ").at(0)),
    values: chars.characters.map(c => c.gold),
  ),
  width: 400pt,
  height: 200pt,
  title: "Gold by Character (Horizontal)",
  x-label: "Gold",
)

#pagebreak()

=== Grouped Bar Chart
#grouped-bar-chart(
  (
    labels: events.attendance.days,
    series: (
      (name: "Registered", values: events.attendance.registered),
      (name: "In-Person", values: events.attendance.actual),
      (name: "Virtual", values: events.attendance.virtual),
    ),
  ),
  width: 400pt,
  height: 200pt,
  title: "Daily Attendance Breakdown",
  y-label: "Attendees",
)

#v(20pt)

=== Stacked Bar Chart
#stacked-bar-chart(
  (
    labels: ("Q1", "Q2", "Q3", "Q4"),
    series: (
      (name: "Product A", values: (120, 150, 180, 200)),
      (name: "Product B", values: (80, 100, 90, 120)),
      (name: "Product C", values: (50, 70, 85, 95)),
    ),
  ),
  width: 350pt,
  height: 200pt,
  title: "Quarterly Sales by Product",
)

#pagebreak()

== Line Charts

=== Single Line Chart
#line-chart(
  (
    labels: chars.session_history.sessions.map(s => "S" + str(s)),
    values: chars.session_history.party_gold,
  ),
  width: 450pt,
  height: 200pt,
  title: "Party Gold by Session",
  show-points: true,
)

#v(20pt)

=== Multi-Line Chart
#multi-line-chart(
  (
    labels: chars.damage_by_session.sessions,
    series: (
      (name: "Thorin", values: chars.damage_by_session.thorin),
      (name: "Elara", values: chars.damage_by_session.elara),
      (name: "Grok", values: chars.damage_by_session.grok),
    ),
  ),
  width: 450pt,
  height: 200pt,
  title: "Damage Dealt per Session",
)

#pagebreak()

== Area Charts

=== Single Area Chart
#area-chart(
  (
    labels: chars.session_history.sessions.map(s => "S" + str(s)),
    values: chars.session_history.exp_gained,
  ),
  width: 450pt,
  height: 180pt,
  title: "Experience Gained Over Time",
  fill-opacity: 50%,
)

#v(20pt)

=== Stacked Area Chart
#stacked-area-chart(
  analytics.area_chart_data,
  width: 450pt,
  height: 200pt,
  title: "Gold Flow Over Time",
)

#pagebreak()

== Pie Charts

#grid(
  columns: (1fr, 1fr),
  column-gutter: 20pt,

  [
    === Pie Chart
    #pie-chart(
      (
        labels: chars.characters.map(c => c.name.split(" ").at(0)),
        values: chars.characters.map(c => c.kills),
      ),
      size: 150pt,
      title: "Kill Distribution",
    )
  ],

  [
    === Donut Chart
    #pie-chart(
      events.budget_breakdown,
      size: 150pt,
      title: "Budget Allocation",
      donut: true,
      donut-ratio: 0.5,
    )
  ]
)

#pagebreak()

== Radar Charts

=== Single Series Radar
#radar-chart(
  (
    labels: ("STR", "DEX", "CON", "INT", "WIS", "CHA"),
    series: (
      (name: "Thorin", values: (18, 12, 16, 10, 13, 8)),
    ),
  ),
  size: 220pt,
  title: "Thorin - Ability Scores",
)

#v(20pt)

=== Multi-Series Radar
#radar-chart(
  (
    labels: ("STR", "DEX", "CON", "INT", "WIS", "CHA"),
    series: (
      (name: "Fighter", values: (18, 12, 16, 10, 13, 8)),
      (name: "Wizard", values: (8, 14, 12, 18, 15, 11)),
      (name: "Barbarian", values: (20, 14, 18, 6, 10, 8)),
    ),
  ),
  size: 250pt,
  title: "Class Comparison",
  fill-opacity: 25%,
)

#pagebreak()

== Scatter Plots

=== Simple Scatter Plot
#scatter-plot(
  (
    x: chars.characters.map(c => c.hp),
    y: chars.characters.map(c => c.kills),
  ),
  width: 350pt,
  height: 250pt,
  title: "HP vs Kills",
  x-label: "Hit Points",
  y-label: "Kill Count",
)

#v(15pt)

=== Multi-Series Scatter Plot
#multi-scatter-plot(
  analytics.scatter_data,
  width: 350pt,
  height: 250pt,
  title: "Character Classes: Level vs Kills",
  x-label: "Level",
  y-label: "Kills",
)

#pagebreak()

== Bubble Chart

#bubble-chart(
  analytics.bubble_data,
  width: 400pt,
  height: 300pt,
  title: "Characters: HP vs AC (bubble size = gold)",
  x-label: "Hit Points",
  y-label: "Armor Class",
  min-radius: 8pt,
  max-radius: 35pt,
  show-labels: true,
  labels: analytics.bubble_data.labels,
)

=== Multi-Series Bubble Chart
#multi-bubble-chart(
  (series: (
    (name: "Warriors", points: ((18, 16, 50), (15, 14, 120), (20, 18, 80))),
    (name: "Mages", points: ((8, 12, 200), (10, 10, 150), (6, 11, 300))),
    (name: "Rogues", points: ((12, 14, 90), (14, 15, 60), (11, 13, 110))),
  )),
  width: 400pt,
  height: 300pt,
  title: "Class Comparison: HP vs AC (bubble = gold)",
  x-label: "Hit Points",
  y-label: "Armor Class",
)

#pagebreak()

== Gauges & Progress Indicators

=== Gauge Charts
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,

  gauge-chart(
    analytics.kpi_gauges.quest_completion,
    size: 120pt,
    title: "Quest Progress",
    label: "completion",
  ),

  gauge-chart(
    analytics.kpi_gauges.party_health,
    size: 120pt,
    title: "Party Health",
    label: "average",
  ),

  gauge-chart(
    analytics.kpi_gauges.xp_progress,
    size: 120pt,
    title: "XP to Level",
    label: "progress",
  ),
)

#v(20pt)

=== Progress Bars
#grid(
  columns: (1fr, 1fr),
  column-gutter: 30pt,

  [
    ==== Horizontal Progress
    #progress-bar(75, width: 200pt, title: "Main Quest")
    #v(10pt)
    #progress-bar(45, width: 200pt, title: "Side Quests", color: rgb("#f28e2b"))
    #v(10pt)
    #progress-bar(92, width: 200pt, title: "Combat Rating", color: rgb("#e15759"))
  ],

  [
    ==== Circular Progress
    #grid(
      columns: (1fr, 1fr, 1fr),
      circular-progress(85, size: 70pt, title: "STR"),
      circular-progress(62, size: 70pt, title: "DEX", color: rgb("#f28e2b")),
      circular-progress(78, size: 70pt, title: "CON", color: rgb("#59a14f")),
    )
  ]
)

#v(20pt)

=== Multiple Progress Bars
#progress-bars(
  analytics.progress_data,
  width: 350pt,
  title: "Campaign Progress by Category",
)

#pagebreak()

== Heatmaps

=== Skill Usage Heatmap
#heatmap(
  analytics.heatmap_data,
  cell-size: 35pt,
  title: "Skill Usage by Character",
  palette: "viridis",
)

#v(30pt)

=== Correlation Matrix
#correlation-matrix(
  analytics.correlation_data,
  cell-size: 40pt,
  title: "Stat Correlations",
)

#pagebreak()

=== Activity Calendar Heatmap
#calendar-heatmap(
  analytics.activity_data,
  cell-size: 14pt,
  title: "28-Day Activity",
  palette: "heat",
)

#pagebreak()

== Sparklines

Sparklines are tiny inline charts designed for tables and running text.

#v(10pt)

#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  [*Metric*], [*Sparkline*], [*Sparkbar*], [*Sparkdot*],
  [Revenue],
    [#sparkline((3, 5, 4, 7, 6, 9, 8), color: rgb("#59a14f"))],
    [#sparkbar((3, 5, 4, 7, 6, 9, 8), color: rgb("#59a14f"))],
    [#sparkdot((3, 5, 4, 7, 6, 9, 8), color: rgb("#59a14f"))],
  [Users],
    [#sparkline((2, 4, 3, 6, 5, 8, 7), color: rgb("#4e79a7"))],
    [#sparkbar((2, 4, 3, 6, 5, 8, 7), color: rgb("#4e79a7"))],
    [#sparkdot((2, 4, 3, 6, 5, 8, 7), color: rgb("#4e79a7"))],
  [Errors],
    [#sparkline((8, 6, 7, 4, 5, 2, 3), color: rgb("#e15759"))],
    [#sparkbar((8, 6, 7, 4, 5, 2, 3), color: rgb("#e15759"))],
    [#sparkdot((8, 6, 7, 4, 5, 2, 3), color: rgb("#e15759"))],
  [Latency],
    [#sparkline((5, 3, 4, 2, 6, 3, 4), fill-area: true)],
    [#sparkbar((5, 3, 4, 2, 6, 3, 4))],
    [#sparkdot((5, 3, 4, 2, 6, 3, 4))],
)

#v(20pt)

=== Sparkline Variants
#grid(
  columns: (1fr, 1fr),
  column-gutter: 20pt,
  [
    *Default:* #sparkline((4, 7, 2, 9, 5, 8, 3, 6))
    #v(5pt)
    *With fill:* #sparkline((4, 7, 2, 9, 5, 8, 3, 6), fill-area: true)
    #v(5pt)
    *Wide:* #sparkline((4, 7, 2, 9, 5, 8, 3, 6), width: 120pt, height: 20pt)
  ],
  [
    *Sparkbar:* #sparkbar((4, 7, 2, 9, 5, 8, 3, 6))
    #v(5pt)
    *No gap:* #sparkbar((4, 7, 2, 9, 5, 8, 3, 6), gap: 0pt)
    #v(5pt)
    *Sparkdot:* #sparkdot((4, 7, 2, 9, 5, 8, 3, 6))
  ],
)

#pagebreak()

== Waterfall Chart

#waterfall-chart(
  (
    labels: ("Start", "+Sales", "+Service", "-COGS", "-OpEx", "Total"),
    values: (1000, 400, 150, -300, -200, 1050),
  ),
  width: 400pt,
  height: 220pt,
  title: "Revenue Waterfall",
)

#v(30pt)

== Funnel Chart

#funnel-chart(
  (
    labels: ("Visitors", "Leads", "Qualified", "Proposals", "Closed"),
    values: (10000, 5000, 2500, 1200, 500),
  ),
  width: 300pt,
  height: 250pt,
  title: "Sales Funnel",
)

#pagebreak()

== Box Plot

#box-plot(
  (
    labels: ("Group A", "Group B", "Group C", "Group D"),
    boxes: (
      (min: 10, q1: 25, median: 35, q3: 50, max: 70),
      (min: 15, q1: 30, median: 42, q3: 55, max: 65),
      (min: 5, q1: 20, median: 28, q3: 40, max: 60),
      (min: 20, q1: 35, median: 45, q3: 58, max: 75),
    ),
  ),
  width: 350pt,
  height: 220pt,
  title: "Distribution Comparison",
  show-grid: true,
)

#pagebreak()

== Annotations

Annotations overlay reference lines, bands, and labels on cartesian charts.

#v(10pt)

=== Line Chart with Target & Goal Zone
#line-chart(
  (
    labels: ("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
    values: (30, 45, 35, 60, 50, 70),
  ),
  width: 400pt,
  height: 200pt,
  title: "Monthly Sales with Annotations",
  show-points: true,
  annotations: (
    (type: "h-band", from: 40, to: 60, label: "Goal Zone", color: rgb("#59a14f")),
    (type: "h-line", value: 50, label: "Target", color: rgb("#e15759"), dash: "dashed"),
  ),
)

#v(20pt)

=== Bar Chart with Average Line
#bar-chart(
  (labels: ("A", "B", "C", "D", "E"), values: (20, 45, 30, 55, 40)),
  width: 350pt,
  height: 200pt,
  title: "Bar Chart with Average Reference",
  annotations: (
    (type: "h-line", value: 38, label: "Avg", color: rgb("#4e79a7"), dash: "dashed"),
  ),
)

#pagebreak()

=== Scatter Plot with Annotations
#scatter-plot(
  (x: (1, 2, 3, 4, 5), y: (10, 25, 15, 30, 20)),
  width: 350pt,
  height: 250pt,
  title: "Scatter with Reference Lines & Labels",
  x-label: "X Axis",
  y-label: "Y Axis",
  annotations: (
    (type: "h-line", value: 20, label: "Threshold", color: rgb("#e15759"), dash: "dotted"),
    (type: "v-line", value: 3, label: "Midpoint", color: rgb("#4e79a7"), dash: "dashed"),
    (type: "label", x: 4, y: 30, text: "Peak!", color: rgb("#e15759")),
  ),
)

#pagebreak()

== Theme Showcase

=== Dark Theme
#bar-chart(
  (labels: ("Mon", "Tue", "Wed", "Thu", "Fri"), values: (120, 200, 150, 280, 190)),
  width: 350pt,
  height: 180pt,
  title: "Weekly Revenue",
  theme: themes.dark,
)

#v(20pt)

=== Minimal Theme (with grid)
#line-chart(
  (labels: ("Q1", "Q2", "Q3", "Q4"), values: (100, 150, 130, 180)),
  width: 350pt,
  height: 180pt,
  title: "Quarterly Growth",
  show-points: true,
  theme: themes.minimal,
)

#v(20pt)

=== Print Theme (grayscale)
#grouped-bar-chart(
  (
    labels: ("2023", "2024", "2025"),
    series: (
      (name: "Revenue", values: (100, 130, 160)),
      (name: "Costs", values: (80, 90, 100)),
    ),
  ),
  width: 300pt,
  height: 160pt,
  title: "Financial Summary",
  theme: themes.print,
)

#v(40pt)

#align(center)[
  #text(size: 8pt, fill: gray)[
    Charts generated using Typst primitives (rect, circle, line, polygon, place) \
    25+ chart types with theme system, validation, and annotations \
    No external dependencies required
  ]
]
