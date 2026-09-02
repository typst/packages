# DGS — Dynamic Geometry Software for Typst

A GeoGebra-like dynamic geometry plugin for Typst, powered by a WASM rendering engine.

## Features

- Coordinate system with customizable grid and axes
- Geometric shapes: points, lines, circles, polygons, ellipses, arcs
- Equation plotting: `f(x)` functions and parametric curves `(x(t), y(t))`
- Named points: reference by name or raw coordinates
- Themes: light, dark, or custom color schemes
- Colors: named strings ("red", "blue") and Typst color values

## Usage

```typst
#import "@preview/dgs:0.0.1": *

#dgs-canvas(
  x1: -5, y1: -5, x2: 5, y2: 5,
  width: 300pt, height: 300pt,
  theme: "dark",
  objects: (
    dgs-point("A", 1, 2, color: "yellow"),
    dgs-line("A", (3, -1), color: "cyan"),
    dgs-circle((0,0), 3, color: "green", stroke: 2pt),
    dgs-eq("x^2", color: "blue"),
  )
)
```

## License

MIT
