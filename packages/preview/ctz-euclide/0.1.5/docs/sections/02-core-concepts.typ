// Core Concepts
#import "../helpers.typ": *

= Core Concepts

== The Point Registry

The point registry is the heart of `ctz-euclide`. Once you define a point with a name, that name can be used directly in CeTZ drawing commands.

```typst
ctz-def-points(A: (0, 0), B: (3, 4))  // Register points A and B
ctz-draw(segment: ("A", "B"))              // Use them directly in CeTZ
```

Under the hood, `ctz-init()` installs a coordinate resolver that translates `"A"` to the stored coordinates.

== Figure Scaling

Control the size of your figures using CeTZ's `length` parameter:

```typst
#ctz-canvas(length: 0.8cm, { ... })
```

This scales everything proportionally, including stroke widths. Typical values:
- `0.6cm` – small inline figures
- `0.8cm` – standard examples
- `1.0cm` – large detailed figures

== Coordinate Systems

Points can be defined in multiple ways:

```typst
// Explicit coordinates
ctz-def-points(A: (2, 3))

// Using existing CeTZ coordinates
ctz-def-points(B: (rel: (1, 1), to: "A"))

// Mixed: numbers and existing points
ctz-def-points(C: (4, 0), D: "A", E: (3, 2))
```
