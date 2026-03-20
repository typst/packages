# Primaviz

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Typst](https://img.shields.io/badge/typst-%3E%3D0.12.0-239dad)](https://github.com/typst/typst)
[![Charts](https://img.shields.io/badge/chart_types-50%2B-orange)](screenshots/)
[![Pure Typst](https://img.shields.io/badge/dependencies-zero-brightgreen)]()

A charting library for [Typst](https://github.com/typst/typst) built entirely with native primitives (`rect`, `circle`, `line`, `polygon`, `place`). No external dependencies required.

## Gallery

All 50+ chart types across 8 pages — see [`examples/showcase.typ`](examples/showcase.typ) for the source:

![Showcase Page 1](screenshots/showcase/showcase-1.png)
![Showcase Page 2](screenshots/showcase/showcase-2.png)
![Showcase Page 3](screenshots/showcase/showcase-3.png)
![Showcase Page 4](screenshots/showcase/showcase-4.png)
![Showcase Page 5](screenshots/showcase/showcase-5.png)
![Showcase Page 6](screenshots/showcase/showcase-6.png)
![Showcase Page 7](screenshots/showcase/showcase-7.png)
![Showcase Page 8](screenshots/showcase/showcase-8.png)
![Showcase Page 9](screenshots/showcase/showcase-9.png)

## Examples

| File | Description |
|---|---|
| [`examples/demos/`](examples/demos/) | 19 per-chart demo files, each a 2×2 grid (light/dark + variations) |
| [`examples/showcase.typ`](examples/showcase.typ) | Compact 8-page showcase of all chart types (dark theme) |
| [`examples/demo.typ`](examples/demo.typ) | Comprehensive demo with all features, themes, and data loading |

Shared datasets in [`data/`](data/) used by both demo and showcase:
- [`data/sales.json`](data/sales.json) — SaaS startup metrics
- [`data/codebase.json`](data/codebase.json) — Open source project stats
- [`data/league.json`](data/league.json) — Soccer league data
- [`data/rpg.json`](data/rpg.json) — D&D campaign tracker
- [`data/words.json`](data/words.json) — Data visualization vocabulary

```bash
just demos      # Compile all per-chart demos
just showcase   # Compile the showcase
just demo       # Compile the comprehensive demo
```

## Features

- **50+ chart types** for data visualization
- **JSON data input** — load data directly from JSON files
- **Theme system** — golden-ratio proportional scaling from two seeds (`base-size`, `base-gap`), preset themes, custom overrides, and `with-theme()` for document-wide defaults
- **Smart label placement** — automatic fit detection, font shrinking, and greedy deconfliction for overlapping labels
- **Layout primitives** — shared utilities for label density, font scaling, and label placement
- **Annotations** — overlay reference lines, bands, and labels on Cartesian charts
- **Relative widths** — use `width: 100%` for responsive charts inside containers and grids
- **Dashboard primitives** — `card`, `compact-table`, `alert`, `badge`, `separator`, and `dashboard-layout` for report layouts
- **Customizable** — colors, sizes, labels, legends
- **Pure Typst** — no packages or external tools needed

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
- `bubble-chart` - Scatter with size dimension, smart label deconfliction (inside/outside with leaders)
- `multi-bubble-chart` - Multi-series bubble chart

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
- `funnel-chart` - Conversion funnel with percentages, auto external labels for narrow sections
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
- `card` - Themed container with optional title and description
- `compact-table` - Dense data table with header styling and highlight column
- `alert` - Info/warning/error/success notification block with left border accent
- `badge` - Inline colored pill (default/secondary/destructive/outline/success)
- `separator` - Themed horizontal rule
- `dashboard-layout` - Grid layout helper for multi-row dashboard pages
- `word-cloud` - Weighted text layout sized by importance

### Annotations
Overlay reference lines, bands, and labels on bar, line, and scatter charts:
- `h-line` - Horizontal reference line (target, average, threshold)
- `v-line` - Vertical reference line
- `h-band` - Horizontal shaded region (goal zone, range)
- `label` - Text label at a data point

## Installation

```typst
#import "@preview/primaviz:0.5.3": *
```

## Usage

```typst
#import "@preview/primaviz:0.5.3": *

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
#import "@preview/primaviz:0.5.3": *

#bar-chart(data, theme: themes.dark)
```

### Document-wide theme

Use `with-theme()` to set a default theme for all charts in a block — no need to pass `theme:` to every chart. Explicit per-chart `theme:` parameters still override.

```typst
// Block wrapper
#with-theme(themes.dark)[
  #bar-chart(data)       // uses dark theme
  #pie-chart(data2)      // uses dark theme
  #line-chart(data3, theme: themes.minimal) // explicit override wins
]

// Or as a show rule for the entire document
#show: with-theme.with(themes.dark)
```

### Scaling with seeds

All font sizes and spacing are derived from two seed values via golden-ratio (φ = 1.618) powers. Change the seeds to scale everything proportionally:

```typst
#bar-chart(data, theme: (base-size: 10pt, base-gap: 8pt))  // larger text and spacing
#bar-chart(data, theme: (base-size: 5pt, base-gap: 3pt))   // compact
```

### Custom overrides

Pass a dictionary with only the keys you want to change. Unspecified keys fall back to the active theme (global or default). Partial overrides merge onto the global theme set by `with-theme()`, so `theme: (show-grid: true)` inside a `with-theme(themes.dark)` block gives you dark + grid:

```typst
#bar-chart(data, theme: (show-grid: true, palette: (red, blue, green)))
```

### Theme from JSON

Build a theme from a JSON tokens file (e.g., exported from a CSS design system):

```typst
#let tokens = json("tokens.json")
#let my-theme = theme-from-json(tokens.light)
#let my-dark = theme-from-json(tokens.dark)

#show: with-theme.with(my-theme)
```

Expected JSON format: `palette` (array of hex strings), `text-color`, `text-color-light`, `text-color-inverse`, `background` (hex or null), `border-color`, `border-radius` (number in pt).

### Extracting themes from CSS

The repo includes two scripts for converting CSS design tokens into primaviz theme files (both `.typ` and `.json`). They parse CSS custom properties from `:root` and dark-mode blocks, convert colors (oklch, hsl, rgb, hex) to hex with alpha blending, and map `--chart-1`..N to a palette array and semantic properties (`--foreground`, `--background`, `--border`, `--radius`, etc.) to primaviz theme keys.

**Python** (`scripts/extract-theme.py`) — the most sophisticated tool in the repo. Uses `uv run` for zero-install execution (dependencies are declared inline). Powered by `coloraide` for color space conversion:

```bash
just extract-theme src/index.css                          # default: outputs typst + json to ./typst/
just extract-theme styles.css --name shadcn --format json  # json only, custom name
just extract-theme globals.css --dark-selector '[data-theme="dark"]'
```

**TypeScript** (`scripts/extract-theme.ts`) — equivalent functionality using Bun and `culori`. Extracts additional semantic tokens (card, accent, destructive, etc.) in an `all` field:

```bash
just extract-theme-ts src/index.css
just extract-theme-ts styles.css --name shadcn --format typst
```

Both scripts accept the same flags: `--out-dir`, `--format` (typst/json/both), `--name`, and `--dark-selector`. Run either with `--help` for full usage.

### Custom theme keys

Themes support passthrough of custom keys not in the default theme. This lets you extend the theme system for your own components:

```typst
#let my-theme = (
  palette: (red, blue, green),
  card-fill: rgb("#f5f5f5"),  // custom key — preserved and accessible
)
#show: with-theme.with(my-theme)
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
| `themes.compact` | Smaller fonts, tighter padding for dense dashboard layouts |

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
#import "@preview/primaviz:0.5.3": get-color, themes

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
    lib.typ                  # Public entrypoint — re-exports everything
    theme.typ                # Theme system and preset themes
    util.typ                 # Shared utilities
    validate.typ             # Input validation helpers
    charts/                  # One module per chart family
      bar.typ                # bar, horizontal, grouped, stacked, grouped-stacked
      line.typ               # line, multi-line
      dual-axis.typ          # dual Y-axis
      area.typ               # area, stacked-area
      pie.typ                # pie, donut
      radar.typ              # spider/radar chart
      scatter.typ            # scatter, multi-scatter, bubble, multi-bubble
      gauge.typ              # gauge, progress-bar, circular-progress, progress-bars
      rings.typ              # ring-progress (fitness rings)
      heatmap.typ            # heatmap, calendar-heatmap, correlation-matrix
      sparkline.typ          # sparkline, sparkbar, sparkdot
      waterfall.typ          # bridge/waterfall chart
      funnel.typ             # conversion funnel
      boxplot.typ            # box-and-whisker plot
      histogram.typ          # auto-binned frequency distribution
      treemap.typ            # nested rectangles
      lollipop.typ           # lollipop, horizontal-lollipop
      sankey.typ             # flow diagram
      bullet.typ             # bullet-chart, bullet-charts
      slope.typ              # two-period comparison
      diverging.typ          # left/right diverging bars
      gantt.typ              # project timeline
      waffle.typ             # proportional grid
      bump.typ               # ranking chart
      dumbbell.typ           # before/after comparison
      radial-bar.typ         # circular bars
      sunburst.typ           # multi-level hierarchical pie
      metric.typ             # metric-card, metric-row
      dashboard.typ          # card, compact-table, alert, badge, separator, dashboard-layout
      violin.typ             # kernel density estimation
      timeline.typ           # vertical event timeline
      parliament.typ         # semicircle seat chart
      chord.typ              # circular flow diagram
      wordcloud.typ          # spiral-placement word cloud
    primitives/              # Low-level drawing helpers
      axes.typ               # axis lines, ticks, labels, grid, cartesian-layout
      layout.typ             # resolve-size, density-skip, font-for-space, page-grid, label placement, deconfliction
      annotations.typ        # reference lines, bands, labels
      container.typ          # chart container wrapper
      legend.typ             # horizontal, vertical, draw-legend-auto
      polar.typ              # shared polar/radial helpers (arcs, slices, labels)
      title.typ              # title rendering
  examples/
    demos/                   # Per-chart demo files (19 files, 2×2 grids)
      demo-bar.typ           # bar-chart, horizontal-bar-chart
      demo-bar-multi.typ     # grouped-bar, stacked-bar
      demo-bar-advanced.typ  # grouped-stacked, diverging
      demo-line.typ          # line-chart, multi-line-chart
      demo-area.typ          # area-chart, stacked-area-chart
      demo-dual-axis.typ     # dual-axis-chart (4 themes)
      demo-pie.typ           # pie-chart, donut
      demo-radar.typ         # radar-chart (4 variants)
      demo-scatter.typ       # scatter, multi-scatter, bubble
      demo-gauge.typ         # gauge, progress-bar, circular-progress
      demo-heatmap.typ       # heatmap, calendar-heatmap, correlation-matrix
      demo-statistical.typ   # histogram, box-plot, violin, waterfall
      demo-comparison.typ    # slope, dumbbell, lollipop, bullet
      demo-flow.typ          # sankey, gantt, timeline, chord
      demo-misc.typ          # waffle, parliament, radial-bar, sunburst
      demo-dashboard.typ     # metric-row, word-cloud, sparklines, progress-bars
      demo-rings.typ         # ring-progress, treemap
      demo-bump.typ          # bump-chart, funnel-chart
      demo-themes.typ        # theme comparison (all 7 presets + with-theme)
    showcase.typ             # 8-page compact showcase (dark theme)
    demo.typ                 # Comprehensive demo with JSON data loading
  data/                      # Sample JSON data files
  screenshots/
    demo/                    # Per-chart demo screenshots (demo-*.png)
    showcase/                # Showcase page screenshots (showcase-*.png)
  scripts/
    extract-theme.py         # CSS → primaviz theme extractor (uv script, zero-install, coloraide)
    extract-theme.ts         # CSS → primaviz theme extractor (bun script, culori)
  justfile                   # Common dev commands
```

## Development

Dev commands via [just](https://github.com/casey/just):

```bash
just demos           # Compile all per-chart demos
just demo            # Compile the comprehensive demo
just showcase        # Compile the showcase
just watch           # Live-reload during development
just watch-demo bar  # Watch a specific demo (e.g., bar, pie, scatter)
just test            # Run all compilation tests
just check           # Full CI check (demo + demos + showcase + tests)
just screenshots     # Regenerate screenshots (screenshots/demo/ + screenshots/showcase/)
just open            # Compile and open the demo PDF
just dev             # Watch with live-reload and open PDF
just clean           # Clean generated artifacts
just release         # Full release prep (check + screenshots)
just extract-theme   # Extract CSS tokens → JSON theme via Python (e.g., just extract-theme src/index.css)
just extract-theme-ts # Extract CSS tokens → JSON theme via Bun/TS (same options)
just stats           # Show project stats
```

Issue tracking with [beads](https://github.com/steveyegge/beads).

## License

MIT
