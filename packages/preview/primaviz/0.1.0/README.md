# Primaviz

A charting library for [Typst](https://typst.app) built entirely with native primitives (`rect`, `circle`, `line`, `polygon`, `place`). No external dependencies required.

## Features

- **50 chart types** for data visualization
- **Theme system** — 6 preset themes and custom overrides
- **Pure Typst** — no packages or external tools needed

## Quick Start

```typst
#import "@preview/primaviz:0.1.0": *

#bar-chart(
  (labels: ("A", "B", "C", "D"), values: (25, 40, 30, 45)),
  width: 300pt, height: 200pt,
  title: "My Chart",
)
```

## Chart Types

**Bar Charts**: `bar-chart`, `horizontal-bar-chart`, `grouped-bar-chart`, `stacked-bar-chart`, `grouped-stacked-bar-chart`, `lollipop-chart`, `horizontal-lollipop-chart`, `diverging-bar-chart`

**Line & Area**: `line-chart`, `multi-line-chart`, `dual-axis-chart`, `area-chart`, `stacked-area-chart`

**Circular**: `pie-chart` (+ donut mode), `radar-chart`, `radial-bar-chart`, `sunburst-chart`

**Scatter & Bubble**: `scatter-plot`, `multi-scatter-plot`, `bubble-chart`

**Gauges & Progress**: `gauge-chart`, `progress-bar`, `circular-progress`, `ring-progress`, `progress-bars`

**Sparklines**: `sparkline`, `sparkbar`, `sparkdot`

**Heatmaps**: `heatmap`, `calendar-heatmap`, `correlation-matrix`

**Statistical**: `histogram`, `waterfall-chart`, `funnel-chart`, `box-plot`, `treemap`, `slope-chart`, `bullet-chart`, `bullet-charts`, `violin-plot`

**Proportional**: `waffle-chart`, `parliament-chart`

**Ranking & Comparison**: `bump-chart`, `dumbbell-chart`

**Flow & Timeline**: `sankey-chart`, `gantt-chart`, `timeline-chart`, `chord-diagram`

**Dashboard**: `metric-card`, `metric-row`, `word-cloud`

## Theming

```typst
// Use a preset theme
#bar-chart(data, theme: themes.dark)

// Custom overrides
#bar-chart(data, theme: (show-grid: true, palette: (red, blue, green)))
```

Presets: `themes.default`, `themes.minimal`, `themes.dark`, `themes.presentation`, `themes.print`, `themes.accessible`

## Data Formats

```typst
// Simple data
(labels: ("Jan", "Feb", "Mar"), values: (100, 150, 120))

// Multi-series
(labels: ("Q1", "Q2", "Q3"),
 series: ((name: "A", values: (100, 120, 140)),
          (name: "B", values: (80, 90, 110))))
```

## License

MIT
