# math-plot

[![Distributed under the MIT license](https://img.shields.io/badge/License-MIT-333333?labelColor=eee)](LICENSE)

Mathematical plotting for Typst, covering calculus I through III. Built on top of [simple-plot](https://github.com/nathan-ed/typst-package-simple-plot) (1.1.0, MIT, Nathan Scheinmann), extending it with vector fields, contour plots, 3D surfaces, parametric surfaces and curves, and 3D vector fields.

> Built on [CeTZ](https://github.com/cetz-package/cetz) v0.5.2, [komet](https://typst.app/universe/package/komet) v0.2.0, and [tiptoe](https://typst.app/universe/package/tiptoe) v0.4.0.

## Manual

A full manual (87 pages) with narrative tutorial and tidy-generated API reference is available in the [GitHub repository](https://github.com/hebertodelrio/math-plot/blob/main/docs/manual.pdf).

## Gallery

Click on an image to see the source code.

| | | |
|:---:|:---:|:---:|
| [![Parabola](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/parabola-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/parabola.typ) | [![Trig functions](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/trig-functions-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/trig-functions.typ) | [![Scatter](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/scatter-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/scatter.typ) |
| Parabola | Trigonometric Functions | Scatter Plot |
| [![Exponential & Log](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/exponential-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/exponential.typ) | [![Data fit](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/data-fit-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/data-fit.typ) | [![Markers](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/markers-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/markers.typ) |
| Exponential & Logarithmic | Data with Model Fit | Marker Types |
| [![Extended axes](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/extended-axes-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/extended-axes.typ) | [![Area fills](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/area-features-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/area-features.typ) | [![Revolution](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/revolution-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/revolution.typ) |
| Extended Axes | Area Fills & Riemann Sums | Volume of Revolution |
| [![Riemann features](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/riemann-features-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/riemann-features.typ) | [![Zoom spy](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/zoom-spy-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/zoom-spy.typ) | [![Quiver](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/quiver-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/quiver.typ) |
| Riemann Sum Features | Zoom / Spy Insets | Vector Field (Quiver) |
| [![Quiver styled](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/quiver-styled-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/quiver-styled.typ) | [![Contour](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/contour-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/contour.typ) | [![Filled contour](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/contour-filled-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/contour-filled.typ) |
| Styled Vector Field | Contour Lines | Filled Contours |
| [![Contour + quiver](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/contour-quiver-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/contour-quiver.typ) | [![Surface](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/surface-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/surface.typ) | [![Parametric surface](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/parametric-surface-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/parametric-surface.typ) |
| Contour + Gradient Field | 3D Surface | Parametric Surface |
| [![Parametric curve 3D](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/parametric-curve-3d-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/parametric-curve-3d.typ) | [![Quiver 3D](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/quiver3d-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/quiver3d.typ) | [![Surface + quiver 3D](https://raw.githubusercontent.com/hebertodelrio/math-plot/main/gallery/surface-quiver3d-1.svg)](https://github.com/hebertodelrio/math-plot/blob/main/gallery/surface-quiver3d.typ) |
| 3D Parametric Curve | 3D Vector Field | Surface + Vector Field |

## Features

- **Simple API** — Plot functions with just a few lines of code
- **Multiple plot types** — Functions, scatter plots, line plots with markers
- **Vector fields** — 2D quiver plots with auto-scaling, pivot control, and custom styling
- **Contour plots** — Unfilled and filled contour lines via marching squares (komet)
- **3D surfaces** — `z = f(x, y)` with depth-sorted rendering and color mapping
- **Parametric surfaces** — `(x(u,v), y(u,v), z(u,v))` mesh rendering
- **3D parametric curves** — Space curves `(x(t), y(t), z(t))`
- **3D vector fields** — Quiver plots in 3D space
- **Customizable axes** — Position, labels, ticks, and tick labels; tkz-fct style placement
- **Stealth arrows** — Elegant axis arrowheads matching LaTeX/pgfplots style
- **Grid support** — Major and minor grids with custom styling
- **14 marker types** — Circles, squares, triangles, diamonds, stars, and more
- **Riemann sums** — Left/right/midpoint/lower/upper rectangles with annotations
- **Volume of revolution** — 3D-style solids with disk cross-sections
- **Zoom / spy insets** — Magnified sub-views with rectangular or circular lens
- **Global defaults** — Set defaults for all plots in your document
- **Full styling** — Customize colors, strokes, backgrounds, and more

## Quick Start

```typst
#import "@preview/math-plot:0.1.0": plot

#plot(
  xmin: -3, xmax: 3,
  ymin: -1, ymax: 9,
  show-grid: true,
  (fn: x => calc.pow(x, 2), stroke: blue + 1.5pt),
)
```

## 2D Plotting

### Functions

```typst
#import "@preview/math-plot:0.1.0": plot

#plot(
  xmin: -2 * calc.pi, xmax: 2 * calc.pi,
  ymin: -1.5, ymax: 1.5,
  (fn: x => calc.sin(x), stroke: blue + 1.2pt, label: $sin(x)$),
  (fn: x => calc.cos(x), stroke: red + 1.2pt, label: $cos(x)$),
)
```

### Scatter and Line Plots

```typst
#import "@preview/math-plot:0.1.0": plot, scatter, line-plot

#plot(
  xmin: 0, xmax: 10, ymin: 0, ymax: 10,
  show-grid: true,
  scatter(
    ((1, 2), (2, 3.5), (3, 2.8), (4, 5.2), (5, 4.8)),
    mark: "*", mark-fill: blue,
  ),
)
```

### Vector Fields

```typst
#import "@preview/math-plot:0.1.0": plot, quiver

#plot(
  xmin: -3, xmax: 3, ymin: -3, ymax: 3,
  quiver(
    (x, y) => (-y, x),
    x-step: 1, y-step: 1,
    stroke: 1pt + blue, color: blue,
  ),
)
```

### Contour Plots

```typst
#import "@preview/math-plot:0.1.0": plot, contour

// Unfilled contour lines
#plot(
  xmin: -3, xmax: 3, ymin: -3, ymax: 3,
  contour(
    (x, y) => x * x - y * y,
    levels: (-4, -2, 0, 2, 4),
    samples: 80,
  ),
)

// Filled contours
#plot(
  xmin: -3, xmax: 3, ymin: -3, ymax: 3,
  contour(
    (x, y) => x * x - y * y,
    levels: (-4, -2, 0, 2, 4),
    fill: true,
  ),
)
```

### Riemann Sums

```typst
#import "@preview/math-plot:0.1.0": plot, riemann-sum

#plot(
  xmin: 0, xmax: 3, ymin: 0, ymax: 5,
  riemann-sum(
    x => calc.pow(x, 2),
    domain: (0.0, 3.0), n: 6, method: "left",
    color: blue.lighten(75%),
    show-points: true, show-dx: true, show-xi: true,
  ),
  (fn: x => calc.pow(x, 2), stroke: blue + 1.5pt),
)
```

### Volume of Revolution

```typst
#import "@preview/math-plot:0.1.0": volume-of-revolution

#volume-of-revolution(
  x => calc.sqrt(x),
  domain: (0.0, 4.0), n-disks: 5,
  width: 8.0, height: 4.0,
  label-f: $f(x)=sqrt(x)$,
)
```

## 3D Plotting

The presence of `zmin`/`zmax` or a 3D child (surface, parametric-surface, parametric-curve, quiver3d) promotes the plot to 3D rendering.

### Surface

```typst
#import "@preview/math-plot:0.1.0": plot, surface

#plot(
  xmin: -2, xmax: 2, ymin: -2, ymax: 2,
  zmin: 0, zmax: 8,
  surface((x, y) => x * x + y * y),
)
```

### Parametric Surface

```typst
#import "@preview/math-plot:0.1.0": plot, parametric-surface

#plot(
  xmin: -1.5, xmax: 1.5, ymin: -1.5, ymax: 1.5,
  zmin: -1.5, zmax: 1.5,
  parametric-surface(
    (u, v) => (
      calc.cos(u) * calc.cos(v),
      calc.sin(u) * calc.cos(v),
      calc.sin(v),
    ),
    u-range: (0, 2 * calc.pi),
    v-range: (-calc.pi / 2, calc.pi / 2),
  ),
)
```

### 3D Parametric Curve

```typst
#import "@preview/math-plot:0.1.0": plot, parametric-curve

#plot(
  xmin: -1.5, xmax: 1.5, ymin: -1.5, ymax: 1.5,
  zmin: 0, zmax: 6,
  parametric-curve(
    t => (calc.cos(t), calc.sin(t), t / calc.pi),
    t-range: (0, 3 * calc.pi),
    stroke: 1.5pt + blue, samples: 150,
  ),
)
```

### 3D Vector Field

```typst
#import "@preview/math-plot:0.1.0": plot, quiver3d

#plot(
  xmin: -2, xmax: 2, ymin: -2, ymax: 2,
  zmin: -2, zmax: 2,
  quiver3d(
    (x, y, z) => (-y, x, 0),
    stroke: 1pt + red, color: red,
  ),
)
```

## Styling

```typst
#plot(
  style: (
    background: (fill: rgb("#202124")),
    axis: (stroke: white + 1pt, arrow: (symbol: "stealth", fill: white, scale: 0.55)),
    grid: (major: (stroke: luma(120) + 0.5pt)),
    ticks: (stroke: white + 0.6pt, label-fill: white),
    labels: (fill: white),
  ),
  // ...
)
```

## Global Defaults

```typst
#import "@preview/math-plot:0.1.0": set-plot-defaults, reset-plot-defaults

#set-plot-defaults(width: 6, height: 4, show-grid: "major")

// All subsequent plots use these defaults
#plot(xmin: -2, xmax: 2, ymin: 0, ymax: 4,
  (fn: x => calc.pow(x, 2)))

#reset-plot-defaults()
```

## Dependencies

| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| [CeTZ](https://github.com/cetz-package/cetz) | 0.5.2 | MIT | Canvas drawing |
| [komet](https://typst.app/universe/package/komet) | 0.2.0 | MIT | Contour line computation (marching squares) |
| [tiptoe](https://typst.app/universe/package/tiptoe) | 0.4.0 | MIT | Arrow drawing for quiver plots |

## License

MIT License — see LICENSE file for details.

Forked from [simple-plot](https://github.com/nathan-ed/typst-package-simple-plot) 1.1.0 by Nathan Scheinmann.
