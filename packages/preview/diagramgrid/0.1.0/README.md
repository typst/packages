# diagramgrid

Sometimes you just want a quick block diagram to explain a concept without learning complex diagram syntax. This is a lightweight Typst package for exactly that.

Recursive block diagrams with CSS flexbox-like layouts, built on native Typst primitives. Perfect for architecture overviews, system diagrams, and layered component visualizations.

## Features

- **Pure Typst** — No external dependencies
- **CSS Flexbox-inspired** — Familiar `row`/`column`, `justify`, `align-items` semantics
- **Deep nesting** — Compose diagrams recursively to any depth
- **Container headers** — Title bars for grouping nested components
- **Decorators** — UML-style stereotypes and status indicators
- **Theming** — Built-in themes and easy customization

## Installation

```typst
#import "@preview/diagramgrid:0.1.0": *
```

## Quick Start

```typst
#import "@preview/diagramgrid:0.1.0": *

// Simple vertical stack
#dg-layers(
  [Presentation Layer],
  [Business Logic],
  [Data Access Layer],
  [Database],
)
```

## Core Functions

| Function | Description |
|----------|-------------|
| `dg-rect` | Rectangle shape (default) |
| `dg-circle` | Circle shape |
| `dg-ellipse` | Ellipse shape |
| `dg-flex` | Flex container (row/column layout) |
| `dg-layers` | Vertical layer stack with auto-styling |
| `dg-group` | Simple wrapper for padding/grouping |
| `dg-row` | Shorthand for `dg-flex(direction: "row")` |
| `dg-col` | Shorthand for `dg-flex(direction: "column")` |

## Examples

### Horizontal Components

```typst
#dg-flex(
  direction: "row",
  justify: "space-between",
  gap: 2em,
  dg-rect([API Gateway]),
  dg-rect([Auth Service]),
  dg-rect([User Service]),
)
```

### Nested Architecture

```typst
#dg-layers(
  gap: 1.5em,
  [Frontend],
  dg-flex(
    direction: "row",
    justify: "center",
    gap: 1em,
    dg-rect([Service A], fill: rgb("#e3f2fd")),
    dg-rect([Service B], fill: rgb("#e8f5e9")),
    dg-rect([Service C], fill: rgb("#fff3e0")),
  ),
  [Database Layer],
)
```

### Container with Header

```typst
#dg-rect(
  dg-flex(
    dg-rect([Service A], fill: white),
    dg-rect([Service B], fill: white),
  ),
  header: text(weight: "bold")[API Gateway],
  header-fill: rgb("#1e40af"),
  fill: rgb("#dbeafe"),
)
```

### Decorators

```typst
// Stereotype labels
#dg-rect([UserService], stereotype: "service", fill: rgb("#dbeafe"))
#dg-rect([IRepository], stereotype: "interface", fill: rgb("#dcfce7"))

// Status indicators
#dg-rect([Database], status: green)
#dg-rect([External API], status: red)

// Combined
#dg-rect([OrderService], stereotype: "service", status: green)
```

## Theming

```typst
#import "@preview/diagramgrid:0.1.0": *

// Use a preset theme
#themed-layers(theme-blueprint,
  [Layer 1],
  [Layer 2],
)

// Or create a custom theme
#let my-theme = dg-theme(
  fill: rgb("#fef3c7"),
  stroke: 1pt + rgb("#d97706"),
  radius: 8pt,
)
```

### Available Themes

- `theme-light` — Default, subtle grays
- `theme-dark` — Dark backgrounds
- `theme-blueprint` — Blue tones
- `theme-warm` — Earth/orange tones
- `theme-minimal` — No fills, just strokes

## API Reference

### Shapes

**`dg-rect(content, ..options)`** — Rectangle block
- `width`, `height`: Dimensions (default: `auto`)
- `fill`: Background color (default: `none`)
- `stroke`: Border (default: `0.8pt + luma(120)`)
- `radius`: Corner radius (default: `5pt`)
- `inset`: Padding (default: `(x: 8pt, y: 6pt)`)
- `content-align`: Content alignment (default: `center + horizon`)
- `header`: Header text/content displayed at top
- `header-fill`: Background color for header section
- `header-inset`: Padding for header (default: `(x: 8pt, y: 4pt)`)
- `stereotype`: UML-style label (e.g., `"service"`, `"interface"`)
- `status`: Status indicator dot color (e.g., `green`, `red`)

**`dg-circle(content, ..options)`** — Circle block (same options, no radius/header)

**`dg-ellipse(content, ..options)`** — Ellipse block

### Layouts

**`dg-flex(direction, justify, align-items, gap, ..children)`**
- `direction`: `"row"` or `"column"` (default: `"row"`)
- `justify`: `"start"`, `"center"`, `"end"`, `"space-between"`, `"space-around"` (default: `"start"`)
- `align-items`: `"stretch"`, `"start"`, `"center"`, `"end"` (default: `"stretch"`)
- `gap`: Spacing between items (default: `0.8em`)

**`dg-layers(gap, inset, radius, fill, stroke, content-align, ..children)`**
- Vertical stack with automatic rect wrapping
- `gap`: Space between layers (default: `0.6em`)
- `fill`: Background color (default: light gray)
- `wrap-children`: Auto-wrap in rects (default: `true`)

**`dg-group(width, height, padding, fill, stroke, ..children)`**
- Simple wrapper for grouping and adding space

**`dg-row(..args)`** — Shorthand for `dg-flex(direction: "row", ..args)`

**`dg-col(..args)`** — Shorthand for `dg-flex(direction: "column", ..args)`

## License

MIT
