# Primaviz

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Typst](https://img.shields.io/badge/typst-%3E%3D0.12.0-239dad)](https://typst.app)
[![Charts](https://img.shields.io/badge/chart_types-50-orange)](screenshots/)
[![Pure Typst](https://img.shields.io/badge/dependencies-zero-brightgreen)]()

A charting library for [Typst](https://typst.app) built entirely with native primitives (`rect`, `circle`, `line`, `polygon`, `place`). No external dependencies required.

## Gallery

All 50 chart types across 6 pages — see [`examples/showcase.typ`](examples/showcase.typ) for the source:

![Showcase Page 1](screenshots/showcase-1.png)
![Showcase Page 2](screenshots/showcase-2.png)
![Showcase Page 3](screenshots/showcase-3.png)
![Showcase Page 4](screenshots/showcase-4.png)
![Showcase Page 5](screenshots/showcase-5.png)
![Showcase Page 6](screenshots/showcase-6.png)

## Examples

| File | Description |
|---|---|
| [`examples/showcase.typ`](examples/showcase.typ) | Compact 6-page showcase of all 50 chart types (dark theme) |
| [`examples/demo.typ`](examples/demo.typ) | Comprehensive 18-page demo with all features, themes, and data loading |

Sample data files used by the demo:
- [`data/characters.json`](data/characters.json) — RPG character stats
- [`data/events.json`](data/events.json) — Conference/event data
- [`data/analytics.json`](data/analytics.json) — Dashboard analytics data

```bash
typst compile --root . examples/showcase.typ
typst compile --root . examples/demo.typ
```

## Features

- **50 chart types** for data visualization
- **JSON data input** - load data directly from JSON files
- **Theme system** - preset themes and custom overrides for consistent styling
- **Customizable** - colors, sizes, labels, legends
- **Pure Typst** - no packages or external tools needed

## Chart Types

### Bar Charts
- `bar-chart` - Vertical bar chart
- `horizontal-bar-chart` - Horizontal bar chart
- `grouped-bar-chart` - Side-by-side grouped bars
- `stacked-bar-chart` - Stacked bar segments
- `grouped-stacked-bar-chart` - Groups of stacked segments side by side
- `lollipop-chart` - Vertical stem + dot (cleaner bar alternative)
- `horizontal-lollipop-chart` - Horizontal stem + dot
- `diverging-bar-chart` - Left/right bars from center axis

### Line & Area Charts
- `line-chart` - Single line with points
- `multi-line-chart` - Multiple series comparison
- `dual-axis-chart` - Two independent Y-axes
- `area-chart` - Filled area under line
- `stacked-area-chart` - Stacked area series

### Circular Charts
- `pie-chart` - Pie chart with legend
- `pie-chart` (donut mode) - Donut/ring chart
- `radar-chart` - Spider/radar chart

### Scatter & Bubble
- `scatter-plot` - X/Y point plotting
- `multi-scatter-plot` - Multi-series scatter
- `bubble-chart` - Scatter with size dimension

### Gauges & Progress
- `gauge-chart` - Semi-circular dial gauge
- `progress-bar` - Horizontal progress bar
- `circular-progress` - Ring progress indicator
- `ring-progress` - Concentric fitness rings (Apple Watch style)
- `progress-bars` - Multiple comparison bars

### Sparklines (inline)
- `sparkline` - Tiny line chart for tables and text
- `sparkbar` - Tiny bar chart
- `sparkdot` - Tiny dot chart

### Heatmaps
- `heatmap` - Grid heatmap with color scale
- `calendar-heatmap` - GitHub-style activity grid
- `correlation-matrix` - Symmetric correlation display

### Statistical
- `histogram` - Auto-binned frequency distribution
- `waterfall-chart` - Bridge/waterfall chart with pos/neg/total segments
- `funnel-chart` - Conversion funnel with percentages
- `box-plot` - Box-and-whisker distribution plot
- `treemap` - Nested rectangles for hierarchical data
- `slope-chart` - Two-period comparison with connecting lines
- `bullet-chart` - Compact gauge with qualitative ranges and target
- `bullet-charts` - Multiple bullet charts stacked vertically

### Proportional & Hierarchical
- `waffle-chart` - 10×10 grid of colored squares for proportions
- `sunburst-chart` - Multi-level hierarchical pie with nested rings
- `parliament-chart` - Semicircle dot layout for seat visualization

### Comparison & Ranking
- `bump-chart` - Multi-period ranking chart
- `dumbbell-chart` - Before/after dot comparisons with connecting lines
- `radial-bar-chart` - Circular bars radiating from center

### Distribution
- `violin-plot` - Kernel density estimation with mirrored polygon

### Flow & Timeline
- `sankey-chart` - Flow diagram with curved bands between nodes
- `gantt-chart` - Timeline bar chart for project scheduling
- `timeline-chart` - Vertical event timeline with alternating layout
- `chord-diagram` - Circular flow diagram with chord bands

### Dashboard
- `metric-card` - KPI tile with value, delta, and sparkline
- `metric-row` - Horizontal row of metric cards
- `word-cloud` - Weighted text layout sized by importance

### Annotations
Overlay reference lines, bands, and labels on bar, line, and scatter charts:
- `h-line` - Horizontal reference line (target, average, threshold)
- `v-line` - Vertical reference line
- `h-band` - Horizontal shaded region (goal zone, range)
- `label` - Text label at a data point

## Installation

```typst
#import "@preview/primaviz:0.1.1": *
```

## Usage

```typst
#import "@preview/primaviz:0.1.1": *

// Load data from JSON
#let data = json("mydata.json")

// Create a bar chart
#bar-chart(
  (
    labels: ("A", "B", "C", "D"),
    values: (25, 40, 30, 45),
  ),
  width: 300pt,
  height: 200pt,
  title: "My Chart",
)

// Create a pie chart
#pie-chart(
  (
    labels: ("Red", "Blue", "Green"),
    values: (30, 45, 25),
  ),
  size: 150pt,
  donut: true,
)

// Create a radar chart
#radar-chart(
  (
    labels: ("STR", "DEX", "CON", "INT", "WIS", "CHA"),
    series: (
      (name: "Fighter", values: (18, 12, 16, 10, 13, 8)),
      (name: "Wizard", values: (8, 14, 12, 18, 15, 11)),
    ),
  ),
  size: 200pt,
  title: "Character Comparison",
)
```

## Theming

Every chart function accepts an optional `theme` parameter. Themes control colors, font sizes, grid lines, backgrounds, and other visual properties.

### Using a preset theme

```typst
#import "@preview/primaviz:0.1.1": *

#bar-chart(data, theme: themes.dark)
```

### Custom overrides

Pass a dictionary with only the keys you want to change. Unspecified keys fall back to the default theme:

```typst
#bar-chart(data, theme: (show-grid: true, palette: (red, blue, green)))
```

### Available presets

| Preset | Description |
|---|---|
| `themes.default` | Tableau 10 color palette, no grid, standard font sizes |
| `themes.minimal` | Lighter axis strokes, grid enabled, regular-weight titles |
| `themes.dark` | Dark background (`#1a1a2e`), vibrant neon palette (cyan, pink, purple, ...) |
| `themes.presentation` | Larger font sizes across the board for slides and projectors |
| `themes.print` | Grayscale palette with grid lines, optimized for black-and-white printing |
| `themes.accessible` | Okabe-Ito colorblind-safe palette |

## Data Formats

### Simple data (labels + values)
```typst
(
  labels: ("Jan", "Feb", "Mar"),
  values: (100, 150, 120),
)
```

### Multi-series data
```typst
(
  labels: ("Q1", "Q2", "Q3"),
  series: (
    (name: "Product A", values: (100, 120, 140)),
    (name: "Product B", values: (80, 90, 110)),
  ),
)
```

### Scatter/bubble data
```typst
(
  x: (1, 2, 3, 4, 5),
  y: (10, 25, 15, 30, 20),
  size: (5, 10, 8, 15, 12),  // for bubble chart
)
```

### Heatmap data
```typst
(
  rows: ("Row1", "Row2", "Row3"),
  cols: ("Col1", "Col2", "Col3"),
  values: (
    (1, 2, 3),
    (4, 5, 6),
    (7, 8, 9),
  ),
)
```

## Color Palette

The default theme uses Tableau 10 colors. You can access colors from any theme via the `get-color` function:

```typst
#import "@preview/primaviz:0.1.1": get-color, themes

// Default palette
#get-color(themes.default, 0)  // blue
#get-color(themes.default, 1)  // orange
#get-color(themes.default, 2)  // red

// Or use a theme preset
#get-color(themes.dark, 0)  // cyan
```

## Project Structure

```text
primaviz/
  src/
    lib.typ            # Public entrypoint - re-exports everything
    theme.typ          # Theme system and preset themes
    util.typ           # Shared utilities
    charts/            # One module per chart family
      bar.typ          # bar, horizontal, grouped, stacked, grouped-stacked
      line.typ         # line, multi-line
      dual-axis.typ    # dual Y-axis
      area.typ         # area, stacked-area
      pie.typ          # pie, donut
      radar.typ
      scatter.typ      # scatter, multi-scatter, bubble
      gauge.typ        # gauge, progress-bar, circular-progress, progress-bars
      rings.typ        # ring-progress (fitness rings)
      heatmap.typ      # heatmap, calendar-heatmap, correlation-matrix
      sparkline.typ    # sparkline, sparkbar, sparkdot
      waterfall.typ
      funnel.typ
      boxplot.typ
      histogram.typ
      treemap.typ
      lollipop.typ     # lollipop, horizontal-lollipop
      sankey.typ
      bullet.typ       # bullet-chart, bullet-charts
      slope.typ
      diverging.typ
      gantt.typ
      waffle.typ
      bump.typ
      dumbbell.typ
      radial-bar.typ
      sunburst.typ
      metric.typ       # metric-card, metric-row
      violin.typ
      timeline.typ
      parliament.typ
      chord.typ
      wordcloud.typ
    primitives/        # Low-level drawing helpers
      axes.typ
      annotations.typ
      container.typ
      legend.typ
      title.typ
    validate.typ       # Input validation helpers
  examples/
    showcase.typ       # 6-page compact showcase (dark theme)
    demo.typ           # Comprehensive 18-page demo
  data/                # Sample JSON data files
  screenshots/         # Gallery images
  justfile             # Common dev commands
```

## Development

Dev commands via [just](https://github.com/casey/just):

```bash
just demo         # Compile the full demo
just showcase     # Compile the 3-page showcase
just watch        # Live-reload during development
just test         # Run all compilation tests
just check        # Full CI check (demo + showcase + tests)
just screenshots  # Regenerate gallery images
just open         # Compile and open the demo PDF
just dev          # Watch with live-reload and open PDF
just clean        # Clean generated artifacts
just release      # Full release prep (check + screenshots)
just stats        # Show project stats
```

Issue tracking with [beads](https://github.com/steveyegge/beads).

## License

MIT
