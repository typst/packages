// Compact showcase — All chart types using page-grid layout engine
#import "../src/lib.typ": *
#import "demo-data.typ": sales, codebase, league, rpg, words

#set page(margin: (x: 0.6cm, y: 0.6cm), paper: "a4", fill: themes.dark.background)
#set text(size: 7pt, fill: themes.dark.text-color)

#let dk = themes.dark
#let gk = (..dk, title-size: 7pt)

// Standard cell sizes for 2-col × 4-row layout on A4
#let W = 250pt
#let H = 100pt
#let Hs = 95pt

// ── All charts as a flat array ─────────────────────────────────────────────────

#page-grid(cols: 2, rows: 4, (

  // 1. bar-chart — RPG: kills by character
  bar-chart(
    (labels: rpg.characters.map(c => c.name), values: rpg.characters.map(c => c.kills)),
    width: W, height: H, title: "bar-chart", y-label: "Kills", theme: dk,
  ),

  // 2. horizontal-bar-chart — Codebase: patches by subsystem
  horizontal-bar-chart(codebase.patches,
    width: W, height: H, title: "horizontal-bar-chart", x-label: "Patches", theme: dk,
  ),

  // 3. grouped-bar-chart — League: goals/assists/cards by team
  grouped-bar-chart(league.team-stats,
    width: W, height: H, title: "grouped-bar-chart", y-label: "Count", theme: dk,
  ),

  // 4. stacked-bar-chart — Sales: quarterly revenue by product
  stacked-bar-chart(sales.quarterly,
    width: W, height: H, title: "stacked-bar-chart", y-label: "Revenue ($K)", theme: dk,
  ),

  // 5. line-chart — RPG: party gold over sessions
  line-chart(rpg.party-gold,
    width: W, height: Hs, title: "line-chart", show-points: true, x-label: "Session", y-label: "Gold", theme: dk,
  ),

  // 6. multi-line-chart — League: goals per gameweek
  multi-line-chart(league.weekly-goals,
    width: W, height: Hs, title: "multi-line-chart", x-label: "Gameweek", y-label: "Goals", theme: dk,
  ),

  // 7. area-chart — Sales: monthly revenue
  area-chart(sales.monthly,
    width: W, height: Hs, title: "area-chart", fill-opacity: 40%, x-label: "Month", y-label: "Revenue ($K)", theme: dk,
  ),

  // 8. stacked-area-chart — Codebase: commits by language
  stacked-area-chart(codebase.commits-by-lang,
    width: W, height: Hs, title: "stacked-area-chart", x-label: "Month", y-label: "Commits", theme: dk,
  ),

  // ── page 2 ──

  // 9. pie-chart — Codebase: language proportions
  pie-chart(codebase.languages,
    size: 85pt, title: "pie-chart", theme: dk,
  ),

  // 10. pie-chart (donut) — RPG: loot breakdown
  pie-chart(rpg.loot-breakdown,
    size: 85pt, title: "pie-chart (donut)", donut: true, donut-ratio: 0.35, theme: dk,
  ),

  // 11. radar-chart — League: player skill profiles
  radar-chart(league.player-stats,
    size: 100pt, title: "radar-chart", fill-opacity: 15%, theme: dk,
  ),

  // 12. scatter-plot — RPG: HP vs Kills
  scatter-plot(
    (x: rpg.characters.map(c => c.hp), y: rpg.characters.map(c => c.kills)),
    width: W, height: Hs, title: "scatter-plot",
    x-label: "Hit Points", y-label: "Kills", theme: dk,
  ),

  // 13. multi-scatter-plot — League: home vs away
  multi-scatter-plot(league.home-away,
    width: W, height: Hs, title: "multi-scatter-plot",
    x-label: "Goals Scored", y-label: "Goals Conceded", theme: dk,
  ),

  // 14. bubble-chart — League: goals × possession × market value
  bubble-chart(league.team-bubble,
    width: W, height: Hs, title: "bubble-chart",
    x-label: "Goals", y-label: "Possession %",
    size-label: "Value (£M)",
    show-labels: true, labels: league.team-bubble.labels, theme: dk,
  ),

  // 15. gauge-chart — Sales: conversion/uptime/NPS
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[gauge-chart])
    #v(2pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gauge-chart(sales.conversion-rate, size: 55pt, title: "Conversion", label: "rate", theme: gk),
      gauge-chart(sales.uptime, size: 55pt, title: "Uptime", label: "%", theme: gk),
      gauge-chart(sales.nps, size: 55pt, title: "NPS", label: "score", theme: gk),
    )
  ],

  // 16. progress-bar + circular-progress — RPG: quest progress
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[progress-bar · circular-progress])
    #v(3pt)
    #progress-bar(rpg.quest-completion, width: 230pt, title: "Main Quest", theme: dk)
    #v(3pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      circular-progress(rpg.quest-completion, size: 50pt, title: "Quest", theme: dk),
      circular-progress(rpg.xp-progress, size: 50pt, title: "XP", color: get-color(dk, 1), theme: dk),
      circular-progress(rpg.party-health, size: 50pt, title: "Health", color: get-color(dk, 4), theme: dk),
    )
  ],

  // ── page 3 ──

  // 17. ring-progress — League: season targets
  ring-progress(league.season-targets,
    size: 85pt, ring-width: 8pt, title: "ring-progress", theme: dk,
  ),

  // 18. dual-axis-chart — Sales: revenue + users
  dual-axis-chart(sales.dual-axis,
    width: W, height: Hs, title: "dual-axis-chart", theme: dk,
  ),

  // 19. histogram — League: goals per match distribution
  histogram(league.goals-per-match,
    width: W, height: Hs, title: "histogram", bins: 12, x-label: "Goals/Match", y-label: "Frequency", theme: dk,
  ),

  // 20. waterfall-chart — RPG: dungeon loot P&L
  waterfall-chart(rpg.dungeon-loot,
    width: W, height: Hs, title: "waterfall-chart", show-legend: true, x-label: "Stage", y-label: "Gold", theme: dk,
  ),

  // 21. funnel-chart — Sales: pipeline
  funnel-chart(sales.funnel,
    width: W, height: 110pt, title: "funnel-chart", theme: dk,
  ),

  // 22. box-plot — League: minutes played by position
  box-plot(league.minutes-played,
    width: W, height: 110pt, title: "box-plot", show-grid: true, x-label: "Position", y-label: "Minutes", theme: dk,
  ),

  // 23. heatmap — RPG: skill usage by character
  heatmap(rpg.skill-usage,
    cell-size: 22pt, title: "heatmap", palette: "viridis", theme: dk,
  ),

  // 24. correlation-matrix — Codebase: module coupling
  correlation-matrix(codebase.correlation,
    cell-size: 22pt, title: "correlation-matrix", theme: dk,
  ),

  // ── page 4 ──

  // 25. calendar-heatmap — League: match-day total goals
  calendar-heatmap(league.match-calendar,
    cell-size: 12pt, title: "calendar-heatmap", palette: "heat", theme: dk,
  ),

  // 26. progress-bars — Sales: department targets
  progress-bars(sales.targets,
    width: W, title: "progress-bars", max-val: 100, theme: dk,
  ),

  // 27. sparklines — Sales: server metrics
  [
    #let c0 = get-color(dk, 0)
    #let c1 = get-color(dk, 1)
    #let c2 = get-color(dk, 5)
    #let sw = 50pt
    #let sh = 12pt
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[sparkline · sparkbar · sparkdot])
    #v(2pt)
    #align(center, table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 3pt,
      stroke: dk.grid-stroke,
      fill: dk.background,
      [*Metric*], [*sparkline*], [*sparkbar*], [*sparkdot*],
      [Networking], [#sparkline(sales.sparklines.networking, color: c0, width: sw, height: sh)], [#sparkbar(sales.sparklines.networking, color: c2, width: sw, height: sh)], [#sparkdot(sales.sparklines.networking, color: c1, width: sw, height: sh)],
      [Memory], [#sparkline(sales.sparklines.memory, color: c0, width: sw, height: sh)], [#sparkbar(sales.sparklines.memory, color: c2, width: sw, height: sh)], [#sparkdot(sales.sparklines.memory, color: c1, width: sw, height: sh)],
      [Storage], [#sparkline(sales.sparklines.storage, color: c0, width: sw, height: sh)], [#sparkbar(sales.sparklines.storage, color: c2, width: sw, height: sh)], [#sparkdot(sales.sparklines.storage, color: c1, width: sw, height: sh)],
    ))
  ],

  // 28. treemap — League: squad value by team
  treemap(league.squad-value,
    width: W, height: 110pt, title: "treemap", theme: dk,
  ),

  // 29. sankey-chart — Sales: budget allocation flow
  sankey-chart(sales.budget-flow,
    width: W, height: 110pt, title: "sankey-chart", show-labels: true, theme: dk,
  ),

  // 30. lollipop-chart — RPG: damage dealt
  lollipop-chart(rpg.damage-dealt,
    width: W, height: Hs, title: "lollipop-chart", x-label: "Character", y-label: "Damage", theme: dk,
  ),

  // 31. horizontal-lollipop-chart — Codebase: PR merge time
  horizontal-lollipop-chart(codebase.pr-merge-time,
    width: W, height: Hs, title: "horizontal-lollipop-chart", x-label: "Days", theme: dk,
  ),

  // 32. diverging-bar-chart — League: home vs away win rate
  diverging-bar-chart(
    (..league.home-vs-away-pct, left-label: "Away %", right-label: "Home %"),
    width: W, height: Hs, title: "diverging-bar-chart", x-label: "Win Rate", theme: dk,
  ),

  // ── page 5 ──

  // 33. slope-chart — League: start → end season rankings
  slope-chart(
    (..league.season-slope, start-label: "GW1", end-label: "GW38"),
    width: W, height: 105pt, title: "slope-chart", theme: dk,
  ),

  // 34. bullet-chart — Sales: revenue/satisfaction/customers
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[bullet-chart])
    #v(2pt)
    #bullet-chart(sales.revenue-target.actual, sales.revenue-target.target, sales.revenue-target.ranges, width: 230pt, height: 22pt, title: "Revenue", theme: dk)
    #v(2pt)
    #bullet-chart(82, 90, (60, 80, 100), width: 230pt, height: 22pt, title: "Satisfaction", theme: dk)
    #v(2pt)
    #bullet-chart(45, 50, (25, 40, 60), width: 230pt, height: 22pt, title: "Customers", theme: dk)
  ],

  // 35. grouped-stacked-bar-chart — Sales: product × channel
  grouped-stacked-bar-chart(sales.channels,
    width: W, height: H, title: "grouped-stacked-bar-chart", y-label: "Revenue ($K)", theme: dk,
  ),

  // 36. gantt-chart — RPG: campaign arc schedule
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[gantt-chart])
    #v(2pt)
    #gantt-chart(rpg.campaign-arcs,
      width: 230pt, bar-height: 10pt, gap: 2pt, today: 7, show-legend: true, title: none, theme: dk,
    )
  ],

  // 37. waffle-chart — Codebase: language proportions
  waffle-chart(codebase.languages,
    size: 120pt, gap: 1pt, title: "waffle-chart", theme: dk,
  ),

  // 38. bump-chart — League: team rankings over gameweeks
  bump-chart(league.season-rankings,
    width: W, height: 110pt, title: "bump-chart", dot-size: 4pt, theme: dk,
  ),

  // 39. dumbbell-chart — RPG: stat gains level 1 → 8
  dumbbell-chart(
    (..rpg.stat-gains, start-label: "Lv1", end-label: "Lv8"),
    width: W, height: 110pt, title: "dumbbell-chart", show-values: true, theme: dk,
  ),

  // 40. radial-bar-chart — Codebase: subsystem health
  radial-bar-chart(codebase.health,
    size: 120pt, title: "radial-bar-chart", show-labels: true, theme: dk,
  ),

  // ── page 6 ──

  // 41. sunburst-chart — RPG: class → subclass → specialization
  sunburst-chart(rpg.class-tree,
    size: 120pt, inner-radius: 20pt, ring-width: 25pt, title: "sunburst-chart", theme: dk,
  ),

  // 42. metric-card + metric-row — Sales: KPIs
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[metric-card · metric-row])
    #v(3pt)
    #metric-row(sales.kpis,
      width: 250pt, gap: 5pt, theme: dk,
    )
  ],

  // 43. violin-plot — League: player ratings by position
  violin-plot(league.ratings,
    width: W, height: 115pt, title: "violin-plot", x-label: "Position", y-label: "Rating", theme: dk,
  ),

  // 44. timeline-chart — League: season milestones
  timeline-chart(league.season-timeline,
    width: W, event-gap: 45pt, title: "timeline-chart", theme: dk,
  ),

  // 45. parliament-chart — Codebase: contributor types
  parliament-chart(codebase.contributors,
    size: 130pt, dot-size: 3pt, title: "parliament-chart", theme: dk,
  ),

  // 46. chord-diagram — RPG: party interaction matrix
  chord-diagram(rpg.interaction-matrix,
    size: 130pt, arc-width: 10pt, title: "chord-diagram", theme: dk,
  ),

  // 47. card + compact-table — Dashboard layout
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[card · compact-table])
    #v(2pt)
    #card(title: "Revenue", desc: "Monthly", theme: dk)[
      #compact-table(
        ("Month", "Rev", "Cost", "Profit"),
        (
          ("Jan", "$12K", "$8K", "$4K"),
          ("Feb", "$15K", "$9K", "$6K"),
          ("Mar", "$11K", "$7K", "$4K"),
        ),
        highlight-col: 3,
        theme: dk,
      )
    ]
  ],

  // 48. alert + badge + separator — Dashboard components
  [
    #v(10pt)
    #align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[alert · badge · separator])
    #v(2pt)
    #alert(title: "Deployed", variant: "success", theme: dk)[Service v2.4.1 live.]
    #v(3pt)
    #alert(title: "Warning", variant: "warning", theme: dk)[Memory at 87%.]
    #v(4pt)
    #badge("Production", theme: dk) #h(3pt)
    #badge("Staging", variant: "secondary", theme: dk) #h(3pt)
    #badge("Failed", variant: "destructive", theme: dk)
    #separator(theme: dk)
  ],

))

// ── Page 8: φ-scaling demo ───────────────────────────────────────────────────
#pagebreak()
#let scale-data = (labels: sales.monthly.labels.slice(0, 3), values: sales.monthly.values.slice(0, 3))
#align(center, text(size: dk.title-size, weight: dk.title-weight, fill: dk.text-color)[φ-Scaling: same data, different seeds])
#v(4pt)
#align(center, text(size: dk.axis-label-size, fill: dk.text-color)[No manual width, height, or cell-size — charts self-size from `base-size` and `base-gap`])
#v(6pt)

#let scales = (
  (name: "0.5×  (4pt / 3pt)", bs: 4pt, bg: 3pt),
  (name: "1× default  (8pt / 6pt)", bs: 8pt, bg: 6pt),
  (name: "2×  (16pt / 12pt)", bs: 16pt, bg: 12pt),
)

// 2-column grid: bar (left) × line (right), 3 rows (0.5×, 1×, 2×)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 6pt,
  ..scales.map(s => (
    bar-chart(scale-data, title: s.name, y-label: "Rev",
      theme: (..dk, base-size: s.bs, base-gap: s.bg, show-grid: true)),
    line-chart(scale-data, title: s.name, y-label: "Rev",
      theme: (..dk, base-size: s.bs, base-gap: s.bg, show-grid: true)),
  )).flatten()
)

// ── Page 9: Full-page word cloud ─────────────────────────────────────────────
#pagebreak()
#word-cloud(words,
  width: 100%, height: 100%, title: "word-cloud", shape: "circle", theme: dk,
)
