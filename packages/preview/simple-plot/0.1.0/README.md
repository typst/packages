# simple-plot

A simple, pgfplots-like function plotting library for Typst. Create beautiful mathematical plots with minimal code.

> **Note:** This package is built on top of [CeTZ](https://github.com/cetz-package/cetz) v0.4.2.

## Gallery

Click on an image to see the source code.

| | | |
|:---:|:---:|:---:|
| [![Parabola](gallery/parabola.png)](gallery/parabola.typ) | [![Trigonometric Functions](gallery/trig-functions.png)](gallery/trig-functions.typ) | [![Scatter Plot](gallery/scatter.png)](gallery/scatter.typ) |
| Parabola | Trigonometric Functions | Scatter Plot |
| [![Exponential](gallery/exponential.png)](gallery/exponential.typ) | [![Data Fit](gallery/data-fit.png)](gallery/data-fit.typ) | [![Markers](gallery/markers.png)](gallery/markers.typ) |
| Exponential & Logarithmic | Data with Model Fit | Marker Types |

## Features

- **Simple API** - Plot functions with just a few lines of code
- **Multiple plot types** - Functions, scatter plots, line plots with markers
- **Customizable axes** - Position, labels, ticks, and tick labels
- **Grid support** - Major and minor grids with custom styling
- **14 marker types** - Circles, squares, triangles, diamonds, stars, and more
- **Global defaults** - Set defaults for all plots in your document
- **Full styling** - Customize colors, strokes, backgrounds, and more

## Quick Start

```typst
#import "@preview/simple-plot:0.1.0": plot

#plot(
  xmin: -3, xmax: 3,
  ymin: -1, ymax: 9,
  xlabel: $x$,
  ylabel: $y$,
  show-grid: true,
  (fn: x => calc.pow(x, 2), stroke: blue + 1.5pt),
)
```

## Basic Usage

### Plotting Functions

```typst
#import "@preview/simple-plot:0.1.0": plot

// Single function
#plot(
  xmin: -5, xmax: 5,
  ymin: -5, ymax: 5,
  xlabel: $x$, ylabel: $y$,
  show-grid: "major",
  (fn: x => calc.sin(x), stroke: blue + 1.5pt),
)

// Multiple functions
#plot(
  xmin: -2 * calc.pi, xmax: 2 * calc.pi,
  ymin: -1.5, ymax: 1.5,
  (fn: x => calc.sin(x), stroke: blue + 1.2pt, label: $sin(x)$),
  (fn: x => calc.cos(x), stroke: red + 1.2pt, label: $cos(x)$),
)
```

### Scatter Plots

```typst
#import "@preview/simple-plot:0.1.0": plot, scatter

#plot(
  xmin: 0, xmax: 10,
  ymin: 0, ymax: 10,
  show-grid: true,
  scatter(
    ((1, 2), (2, 3.5), (3, 2.8), (4, 5.2), (5, 4.8)),
    mark: "*",
    mark-fill: blue,
  ),
)
```

### Line Plots with Markers

```typst
#import "@preview/simple-plot:0.1.0": plot, line-plot

#plot(
  xmin: 0, xmax: 10,
  ymin: 0, ymax: 12,
  axis-x-pos: "bottom",
  axis-y-pos: "left",
  line-plot(
    ((0, 0), (1, 0.5), (2, 1.8), (3, 4.2), (4, 5.1)),
    stroke: blue + 1.2pt,
    mark: "*",
    mark-fill: blue,
  ),
)
```

## Parameters Reference

### Plot Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `xmin`, `xmax` | float | -5, 5 | X-axis range |
| `ymin`, `ymax` | float | -5, 5 | Y-axis range |
| `width`, `height` | float | 8, 6 | Plot size in cm |
| `xlabel`, `ylabel` | content | none | Axis labels |
| `show-grid` | bool/str | false | Grid display: `true`, `false`, `"major"`, `"minor"`, `"both"` |
| `minor-grid-step` | int | 2 | Minor grid subdivisions per major tick |
| `axis-x-pos` | float/str | 0 | X-axis position: value, `"bottom"`, `"center"` |
| `axis-y-pos` | float/str | 0 | Y-axis position: value, `"left"`, `"center"` |

### Axis Label Placement

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `xlabel-pos` | str/array | "end" | Position: `"end"`, `"center"`, or `(x, y)` |
| `ylabel-pos` | str/array | "end" | Position: `"end"`, `"center"`, or `(x, y)` |
| `xlabel-anchor` | str | "west" | Text anchor point |
| `ylabel-anchor` | str | "south" | Text anchor point |
| `xlabel-offset` | array | (0.3, 0) | Offset `(x, y)` in cm |
| `ylabel-offset` | array | (0, 0.3) | Offset `(x, y)` in cm |

### Tick Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `xtick`, `ytick` | auto/none/array | auto | Tick positions |
| `xtick-step`, `ytick-step` | auto/float | auto | Step between ticks |
| `xtick-labels`, `ytick-labels` | auto/array | auto | Custom tick labels |

### Function Specification

Each function is a dictionary with:

```typst
(
  fn: x => ...,           // Required: the function
  stroke: blue + 1.2pt,   // Line style
  domain: (min, max),     // Optional: restrict domain
  samples: 100,           // Number of sample points
  label: $f(x)$,          // Optional label
  label-pos: 0.8,         // Label position (0-1)
  mark: "o",              // Marker type
  mark-size: 0.1,         // Marker size
  mark-fill: white,       // Marker fill color
  mark-stroke: blue,      // Marker stroke
  mark-interval: 10,      // Show marker every N points
)
```

## Marker Types

| Type | Description | Type | Description |
|------|-------------|------|-------------|
| `"o"` | Hollow circle | `"*"` | Filled circle |
| `"square"` | Hollow square | `"square*"` | Filled square |
| `"triangle"` | Hollow triangle | `"triangle*"` | Filled triangle |
| `"diamond"` | Hollow diamond | `"diamond*"` | Filled diamond |
| `"star"` | Hollow star | `"star*"` | Filled star |
| `"+"` | Plus sign | `"x"` | Cross |
| `"|"` | Vertical bar | `"-"` | Horizontal bar |
| `"none"` | No marker | | |

## Custom Styling

```typst
#plot(
  // ...
  style: (
    background: (
      fill: white,
      stroke: black + 0.5pt,
    ),
    axis: (
      stroke: black + 1pt,
      arrow: "stealth",
    ),
    grid: (
      major: (stroke: gray + 0.6pt),
      minor: (stroke: gray.lighten(50%) + 0.3pt),
    ),
    ticks: (
      length: 0.1,
      stroke: black + 0.6pt,
      label-offset: 0.15,
      label-size: 0.8em,
    ),
    plot: (
      stroke: blue + 1.2pt,
      samples: 100,
    ),
    marker: (
      size: 0.12,
      stroke: black + 0.8pt,
      fill: black,
    ),
  ),
)
```

## Setting Global Defaults

Set defaults that apply to all subsequent plots:

```typst
#import "@preview/simple-plot:0.1.0": plot, set-plot-defaults, reset-plot-defaults

// Set defaults
#set-plot-defaults(
  width: 6,
  height: 4,
  show-grid: "major",
  xlabel: $x$,
  ylabel: $y$,
)

// All plots now use these defaults
#plot(xmin: -2, xmax: 2, ymin: 0, ymax: 4,
  (fn: x => calc.pow(x, 2)))

#plot(xmin: -3, xmax: 3, ymin: -1, ymax: 1,
  (fn: x => calc.sin(x)))

// Override specific values
#plot(width: 10, xlabel: $t$,
  xmin: 0, xmax: 5,
  (fn: x => 2*x))

// Reset all defaults
#reset-plot-defaults()
```

## Examples

### Trigonometric Functions

```typst
#plot(
  xmin: -2 * calc.pi, xmax: 2 * calc.pi,
  ymin: -2, ymax: 2,
  width: 10, height: 5,
  show-grid: "major",
  xtick: (-2*calc.pi, -calc.pi, 0, calc.pi, 2*calc.pi),
  xtick-labels: ($-2pi$, $-pi$, $0$, $pi$, $2pi$),
  (fn: x => calc.sin(x), stroke: blue + 1.2pt),
  (fn: x => calc.cos(x), stroke: red + 1.2pt),
)
```

### Exponential and Logarithmic

```typst
#plot(
  xmin: -2, xmax: 3,
  ymin: -2, ymax: 5,
  show-grid: true,
  (fn: x => calc.exp(x), stroke: green + 1.5pt, label: $e^x$),
  (fn: x => if x > 0 { calc.ln(x) } else { float.nan },
   domain: (0.01, 3), stroke: orange + 1.5pt, label: $ln(x)$),
)
```

### Piecewise Functions

```typst
#plot(
  xmin: -3, xmax: 4,
  ymin: -1, ymax: 5,
  show-grid: true,
  (fn: x => if x < 0 { calc.pow(x, 2) } else { calc.sqrt(x) },
   stroke: blue + 1.5pt),
)
```

### Experimental Data with Fit

```typst
#import "@preview/simple-plot:0.1.0": plot, line-plot

#plot(
  xmin: 0, xmax: 10,
  ymin: 0, ymax: 12,
  xlabel: [Time (s)],
  ylabel: [Distance (m)],
  show-grid: true,
  axis-x-pos: "bottom",
  axis-y-pos: "left",
  // Experimental data
  line-plot(
    ((0, 0), (1, 0.5), (2, 1.8), (3, 4.2), (4, 5.1), (5, 6.8)),
    mark: "*",
    mark-fill: blue,
    label: [Data],
  ),
  // Theoretical fit
  (fn: x => 0.15 * calc.pow(x, 2) + 0.3 * x,
   stroke: red + 1pt, label: [Model]),
)
```

## Dependencies

- [CeTZ](https://github.com/cetz-package/cetz) (v0.4.2+)

## License

MIT License - see LICENSE file for details.
