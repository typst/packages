// =====================================================
// NOTEWORTHY - Document entry point
// =====================================================
// Compile with: typst compile main.typ
//
// This file IS your book: configure it with the noteworthy show
// rule, then declare the structure with #cover / #preface / #toc /
// #chapter / #page. Page bodies can live inline (like this demo) or
// in separate files via #include. Chapter and page numbers (and the
// TOC) follow document order automatically - insert, remove, or
// reorder freely.

#import "@preview/noteworks:0.2.0": *

#show: noteworthy.with(
  title: "Noteworthy Framework",
  subtitle: "Examples & Documentation",
  authors: ("Lee Sihoo", "Lee Hojun"),
  affiliation: "Noteworthy",
  theme: "aether", // any name from the built-in schemes
)

#cover()

#preface[
  Welcome to the *Noteworthy Framework*. This document serves as both a demonstration of the framework's capabilities and a reference for its features.

  #v(1.5em)

  = About Noteworthy

  #v(0.5em)

  Noteworthy is a modular framework for creating beautiful educational documents in Typst. It provides a comprehensive set of tools for:

  - *Structured Layouts*: Automated chapters, sections, and covers.
  - *Themed Components*: Pre-styled blocks for definitions, theorems, examples, and more.
  - *Advanced Plotting*: Integrated 2D and 3D plotting capabilities.
  - *Customizable Themes*: A robust theming engine with multiple built-in presets.

  #v(1.5em)

  = Using This Guide

  #v(0.5em)

  Each section of this document demonstrates a specific module of the framework. The source of every page in this book lives right here in `main.typ`, which serves as a practical reference for your own documents.
]

#toc()

#chapter("Architecture & Modules", summary: "Understanding Noteworthy's modular structure and file organization.")
#page("Introduction")[
= Welcome to Noteworthy

Noteworthy is a powerful Typst framework for creating beautiful educational documents with rich content blocks and visualization tools.

== What is Noteworthy?
#definition("Noteworthy")[
  A modular Typst template system designed for creating professional educational materials, textbooks, and technical documentation.
]


== Key Features

#note("Modular Architecture")[
  Noteworthy is organized into modules, each handling a specific aspect of document creation:

  - *Block* — Semantic content containers (definitions, theorems, proofs)
  - *Cover* — Document covers and title pages
  - *Layout* — Page layouts and table of contents
  - *Shape* — 2D geometric primitives (points, lines, circles)
  - *Graph* — Functions, vectors, and calculus operations
  - *Canvas* — Rendering canvases for plots and visualizations
  - *Data* — Tables, data series, and curve interpolation
  - *Combi* — Combinatorics visualizations
  - *DSA* — Data structures and algorithms
  - *Trees* — Hierarchical data structures
  - *Timeline* — Chronological event timelines
]

== How to Use This Guide

This documentation is organized by module — each chapter of this book demonstrates one module. The table of contents mirrors the `#chapter` and `#page` declarations in `main.typ`.

#theorem("Getting Started")[
  Everything in this book comes from one import at the top of `main.typ`:
  ```typst
  #import "@preview/noteworks:0.2.0": *
  ```
  This single import gives you access to all modules. If you split pages
  out into separate files, start each file with the same import.
]
]
#page("File Structure")[
= File Structure

Understanding the project layout helps you navigate and extend Noteworthy.

== Project Root

#notation("Directory Legend")[
  - 📁 = Directory
  - 📄 = File
]

```
my-notes/
└── 📄 main.typ          # Your whole book: config, structure, pages
```

The scaffold is a single file — this entire demo book lives in
`main.typ`. As your notes grow, split pages out into their own files
and `#include` them:

```
my-notes/
├── 📄 main.typ          # Config + structure
└── 📁 content/          # One file per page
    └── 1/, 2/...        # One folder per chapter
```

Every file that uses Noteworthy features imports the package;
configuration lives in the `#show: noteworthy.with(...)` rule in `main.typ`.

== Inside the Package

The package itself (`@preview/noteworks`) is organized as:

#definition("templater.typ")[
  The single entry point that re-exports all modules. Importing the package gives you everything.
]

#definition("core/")[
  Core utilities shared across all modules:
  - `setup.typ` — Configuration state and theme access
  - `init.typ` — The `noteworthy` show rule
  - `scheme.typ` — Color scheme management
  - `book.typ` — Document assembly: `#chapter` and `#page`
]

#definition("module/")[
  Feature modules, each in its own folder with a `mod.typ` entry point:
  - `core/block/`, `core/cover/`, `core/layout/` — Always enabled
  - `canvas/`, `combi/`, `data/`, `dsa/`, `graph/`, `shape/`, `timeline/`, `trees/` — Optional, imported as qualified namespaces (e.g. `canvas.cartesian-canvas`)
]

== Module Pattern

Each module follows the same pattern:

#example("Module Structure")[
  ```
  module/core/block/
  ├── mod.typ      # Entry point (exports themed wrappers)
  └── block.typ    # Implementation
  ```

  The `mod.typ` file imports the implementation, applies theming, and exports ready-to-use functions.
]
]

#chapter("Block Module", summary: "Semantic content blocks for educational documents.")
#page("Block Fundamentals")[
= Block Fundamentals

The Block module provides semantic content containers for educational documents.

== What is a Block?

#definition("Block")[
  A styled container that gives semantic meaning to content. Blocks help readers identify the type of information they're reading.
]

== Block Syntax

All blocks follow the same pattern:

```typst
#blockname("Optional Title")[
  Content goes here...
]
```

Some blocks (like `proof` and `solution`) don't require a title:

```typst
#proof[
  Content without a title...
]
```

== Block Categories

Blocks are organized into three categories:

#note("Primary Blocks")[
  - `definition` — Define concepts
  - `theorem` — State theorems
  - `equation` — Named equations
]

#note("Supporting Blocks")[
  - `note` — Important information
  - `notation` — Explain symbols
  - `analysis` — Discussion and analysis
]

#note("Proofs & Examples")[
  - `proof` — Mathematical proofs
  - `example` — Worked examples
  - `solution` — Solutions (visibility controlled by config)
]

== Your First Block

#example("Creating a Definition")[
  ```typst
  #definition("Velocity")[
    The rate of change of position with respect to time:
    $ v = dif x / dif t $
  ]
  ```

  Renders as:

  #definition("Velocity")[
    The rate of change of position with respect to time:
    $ v = dif x / dif t $
  ]
]
]
#page("All Block Types")[
= All Block Types

A complete reference of every block type in the Block module.

== Primary Blocks

#definition("Definition Block")[
  Use `#definition("Title")[...]` to define concepts.
]

#theorem("Theorem Block")[
  Use `#theorem("Title")[...]` to state theorems.
]

#equation("Equation Block")[
  Use `#equation("Title")[...]` for named equations:
  $ E = m c^2 $
]

== Supporting Blocks

#note("Note Block")[
  Use `#note("Title")[...]` for important notes and tips.
]

#notation("Notation Block")[
  Use `#notation("Title")[...]` to explain mathematical notation and symbols.
]

#analysis("Analysis Block")[
  Use `#analysis("Title")[...]` for analysis, discussion, and elaboration.
]

== Proofs and Examples

#proof("Simple Proof")[
  Use `#proof[...]` or `#proof("Title")[...]` for mathematical proofs.

  The proof block has a special QED marker at the end.
]

#example("Example with Solution")[
  Use `#example("Title")[...]` for worked examples.

  Solutions can be nested inside examples:

  #solution[
    Use `#solution[...]` for solutions.

    Visibility is controlled by the `show-solution` option of the `noteworthy` show rule.
  ]
]

== Nesting Blocks

Blocks can be nested for complex content:

#theorem("Fundamental Theorem")[
  A theorem statement here.

  #proof[
    The proof of the theorem.
  ]

  #example("Application")[
    An example applying the theorem.

    #solution[
      The worked solution.
    ]
  ]
]

== Styling

Block colors are determined by your active theme — pick one with the `theme` option of the `noteworthy` show rule.
]

#chapter("Shape Module", summary: "2D geometric primitives: points, lines, circles, polygons.")
#page("Points & Lines")[
= Points & Lines

The Shape module provides 2D geometric primitives.

== Creating Points

#definition("point")[
  Creates a point at coordinates $(x, y)$.
  ```typst
  point(x, y, label: "A", label-anchor: "south", label-distance: 0.2)
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.point(2, 3, label: "A", label-anchor: "south"),
  shape.point(-1, 2, label: "B", label-anchor: "east"),
  shape.point(3, -1, label: "C", label-anchor: "north"),
)

== Creating Lines

#definition("line")[
  Creates an infinite line through two points.
  ```typst
  line(p1, p2, label: none, label-anchor: "south", label-distance: 0.15)
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.line(shape.point(-2, -1), shape.point(3, 2), label: $ell$, label-anchor: "west"),
)

== Line Segments

Use `segment` for lines with definite endpoints:

#definition("segment")[
  Creates a finite line segment between two points.
  ```typst
  segment(p1, p2, label: none, label-anchor: "south", label-distance: 0.15)
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.point(-2, 1, label: "A", label-anchor: "west"),
  shape.point(3, 2, label: "B", label-anchor: "east"),
  shape.segment(shape.point(-2, 1), shape.point(3, 2)),
)

== Combining Points and Lines

#example("Triangle Vertices")[
  #let A = shape.point(0, 0, label: "A", label-anchor: "south-east")
  #let B = shape.point(4, 0, label: "B", label-anchor: "south-east")
  #let C = shape.point(2, 3, label: "C", label-anchor: "north")

  #canvas.cartesian-canvas(
    x-tick: 1,
    y-tick: 1,
    A,
    B,
    C,
    shape.segment(A, B),
    shape.segment(B, C),
    shape.segment(C, A),
  )
]
]
#page("Circles & Polygons")[
= Circles & Polygons

Create circles and multi-sided shapes.

== Circles

#definition("circle")[
  Creates a circle from center and radius, or center and a point on the circle.
  ```typst
  circle(center, radius: r, label: none, label-anchor: "north", label-distance: 0.15)
  circle(center, through: point, label: none, label-anchor: "north", label-distance: 0.15)
  ```
]

#let O = shape.point(0, 0, label: "O", label-anchor: "south")
#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.circle(O, radius: 2, label: $C$, label-anchor: "south-west"),
  O,
)

== Circle Through Point

#let O = shape.point(1, 1, label: "O", label-anchor: "south")
#let P = shape.point(3, 2, label: "P", label-anchor: "west")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  O,
  P,
  shape.circle(O, through: P),
)

== Polygons

#definition("polygon")[
  Creates a closed polygon from vertices.
  ```typst
  polygon(p1, p2, p3, ..., label: none, label-anchor: "north", label-distance: 0.15)
  ```
]

#let A = shape.point(0, 0, label: "A", label-anchor: "south-west")
#let B = shape.point(4, 0, label: "B", label-anchor: "south-east")
#let C = shape.point(4, 3, label: "C", label-anchor: "north-east")
#let D = shape.point(0, 3, label: "D", label-anchor: "north-west")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.polygon(A, B, C, D, label: "Rectangle", label-anchor: "center"),
)

== Regular Polygons

#definition("regular-polygon")[
  Creates a regular n-sided polygon from a center and first vertex.
  ```typst
  regular-polygon(center, first-vertex, n, label: none, label-anchor: "north", label-distance: 0.15)
  ```
  The vertex position defines both the radius and orientation.
]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  canvas.blank-canvas(
    width: 4cm,
    shape.regular-polygon(shape.point(0, 0), shape.point(0, 1.5), 3, label: "Triangle"),
  ),
  canvas.blank-canvas(
    width: 4cm,
    shape.regular-polygon(shape.point(0, 0), shape.point(1.5, 1.5), 5, label: "Pentagon"),
  ),
)

== Arcs

#definition("arc")[
  Creates an arc from a center and two points on the arc.
  ```typst
  arc(center, p1, p2, label: none, label-anchor: "north", label-distance: 0.15)
  ```
  The arc is drawn from `p1` to `p2`. The radius is derived from the center-to-p1 distance.
]

#let O = shape.point(0, 0, label: "O", label-anchor: "south")
#let A = shape.point(2, 0, label: "A", label-anchor: "east")
#let B = shape.point(0, 2, label: "B", label-anchor: "north")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  O,
  A,
  B,
  shape.arc(O, A, B),
)

== Point at Angle

#definition("point-at-angle")[
  Creates a point at a given angle and radius from a center.
  ```typst
  point-at-angle(center, angle, radius, from: none, label: none, label-anchor: "north", label-distance: 0.2)
  ```
  When `from` is specified, the angle is measured counterclockwise from the center→from direction.
]

#example("67° Arc")[
  #let O = shape.point(0, 0, label: "O")
  #let A = shape.point(2, 0, label: "A")
  #let B = shape.point-at-angle(O, 67deg, 2, from: A, label: "B")

  #canvas.cartesian-canvas(
    x-tick: 1,
    y-tick: 1,
    O,
    A,
    B,
    shape.arc(O, A, B),
    shape.angle(A, O, B, label: "67°"),
  )
]

== Semicircles

#definition("semicircle")[
  Creates a 180° arc from a center and starting point.
  ```typst
  semicircle(center, start-point, label: none, style: auto)
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.semicircle(shape.point(0, 0), shape.point(2, 0)),
)

== Angles

#definition("angle")[
  Creates an angle marker between three points.
  ```typst
  angle(p1, vertex, p2, label: $theta$, label-anchor: "center", label-distance: none)
  ```
]

#let O = shape.point(0, 0, label: "O")
#let A = shape.point(3, 0, label: "A")
#let B = shape.point(2, 2, label: "B")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  O,
  A,
  B,
  shape.segment(O, A),
  shape.segment(O, B),
  shape.angle(A, O, B, label: $theta$),
)
]
#page("Intersections & Constructions")[
= Intersections & Constructions

Find intersections and construct derived objects.

== Line-Line Intersection

#definition("intersect-ll")[
  Finds the intersection of two lines.
  ```typst
  intersect-ll(line1, line2, label: "P")
  ```
]

#let l1 = shape.line(shape.point(-2, -1), shape.point(3, 2), label: $ell_1$, label-anchor: "south")
#let l2 = shape.line(shape.point(-1, 3), shape.point(2, -2), label: $ell_2$, label-anchor: "west")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  l1,
  l2,
  shape.intersect-ll(l1, l2, label: "P"),
)

== Line-Circle Intersection

#definition("intersect-lc")[
  Finds intersections of a line and circle.
  ```typst
  intersect-lc(line, circle, labels: ("A", "B"))
  ```
]

#let c = shape.circle(shape.point(0, 0), radius: 2)
#let l = shape.line(shape.point(-3, 1), shape.point(3, 1))

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  c,
  l,
  shape.intersect-lc(l, c, labels: ("A", "B")),
)

== Constructions

#definition("midpoint")[
  Constructs the midpoint of a segment.
  ```typst
  midpoint(p1, p2, label: "M", label-anchor: "south", label-distance: 0.2)
  ```
]

#let A = shape.point(1, 1, label: "A", label-anchor: "south-west")
#let B = shape.point(5, 3, label: "B", label-anchor: "north-east")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  A,
  B,
  shape.segment(A, B),
  shape.midpoint(A, B, label: "M", label-anchor: "south"),
)

== Perpendicular & Parallel

#definition("perpendicular")[
  Constructs a line perpendicular to a given line through a point.
  ```typst
  perpendicular(line, point, label: none)
  ```
]

#definition("parallel")[
  Constructs a line parallel to a given line through a point.
  ```typst
  parallel(line, point, label: none)
  ```
]

#let l = shape.line(shape.point(0, 0), shape.point(4, 2), label: $ell$, label-anchor: "south")
#let P = shape.point(1, 3, label: "P", label-anchor: "east")

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  l,
  P,
  shape.perpendicular(l, P),
  shape.parallel(l, P),
)
]

#chapter("Graph Module", summary: "Functions, vectors, and calculus operations.")
#page("Function Plotting")[
= Function Plotting

The Graph module provides function plotting and mathematical visualization.

== The graph Function

#definition("graph")[
  Plots a function $y = f(x)$ over a domain.
  ```typst
  graph(x => expr, domain: (min, max), label: $f(x)$)
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.graph(x => x * x, domain: (-2, 2), label: $x^2$),
)

== Multiple Functions

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.graph(x => x * x, domain: (-2, 2), label: $x^2$),
  graph.graph(x => x, domain: (-2, 2), label: $x$),
  graph.graph(x => 2 * x - 1, domain: (-2, 2), label: $2x - 1$),
)

== Trigonometric Functions

#canvas.trig-canvas(
  width: 10cm,
  graph.graph(x => calc.sin(x), domain: (-calc.pi, calc.pi), label: $sin(x)$),
  graph.graph(x => calc.cos(x), domain: (-calc.pi, calc.pi), label: $cos(x)$),
)

== Parametric Functions

#definition("parametric")[
  Plots a parametric curve $(x(t), y(t))$.
  ```typst
  parametric(t => (x(t), y(t)), domain: (min, max), label: none)
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.parametric(t => (calc.cos(t) * 2, calc.sin(t) * 2), domain: (0, 2 * calc.pi), label: "Circle"),
)
]
#page("Vectors")[
= Vectors

The Graph module includes vector operations for 2D vector mathematics.

== Creating Vectors

#definition("vec")[
  Creates a 2D vector object.
  ```typst
  vec((x, y), label: $arrow(v)$, origin: (0, 0))
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.vec((3, 2), label: $arrow(v)$),
)

== Vector from Point

Vectors can start from any origin:

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.point(1, 1, label: "A", label-anchor: "south"),
  graph.vec((2, 1.5), origin: (1, 1), label: $arrow(v)$),
)

== Vector Addition

#definition("vec-add")[
  Visualizes vector addition with parallelogram.
  ```typst
  vec-add(v1, v2, helplines: true)
  ```
]

#canvas.blank-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.vec((3, 1), label: $arrow(a)$),
  graph.vec((1, 2), label: $arrow(b)$),
  graph.vec-add(
    graph.vec((3, 1), label: $arrow(a)$),
    graph.vec((1, 2), label: $arrow(b)$),
    helplines: true,
  ),
)

== Vector Components

#definition("vec-components")[
  Shows vector decomposition into components.
  ```typst
  vec-components(v, labels: ($v_x$, $v_y$))
  ```
]

#canvas.blank-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.vec((4, 3)),
  graph.vec-components(
    graph.vec((4, 3)),
    labels: ($v_x$, $v_y$),
    helplines: true,
  ),
)

== Vector Projection

#definition("vec-project")[
  Projects one vector onto another.
  ```typst
  vec-project(v, onto: w, helplines: true)
  ```
]

#canvas.blank-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.vec((3, 4)),
  graph.vec-project(
    graph.vec((3, 4), label: $arrow(v)$),
    onto: graph.vec((5, 0), label: $arrow(w)$),
    helplines: true,
  ),
)
]

#chapter("Canvas Module", summary: "Plotting canvases for rendering shapes and graphs.")
#page("Cartesian Canvas")[
= Cartesian Canvas

The Canvas module provides rendering surfaces for shapes and graphs.

== Basic Canvas

#definition("cartesian-canvas")[
  Creates a 2D Cartesian coordinate system.
  ```typst
  cartesian-canvas(
    width: 8cm, height: 6cm,
    x-tick: 1, y-tick: 1,
    ..objects
  )
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  shape.point(2, 3, label: "P"),
)

== Canvas Options

#notation("Key Parameters")[
  - `width`, `height` -- Canvas dimensions
  - `x-tick`, `y-tick` -- Grid spacing
  - `x-label`, `y-label` -- Axis labels
  - `show-grid` -- Toggle grid visibility
]

#canvas.cartesian-canvas(
  width: 10cm,
  height: 6cm,
  x-tick: 2,
  y-tick: 1,
  x-label: $x$,
  y-label: $y$,
  shape.point(4, 2, label: "A"),
  shape.point(-2, 1, label: "B"),
)

== Combining Shapes and Graphs

The cartesian canvas can display both shapes and graphs:

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  graph.graph(x => x * x, domain: (-2, 2), label: $x^2$),
  shape.point(1, 1, label: "P"),
  shape.segment(shape.point(-2, 0), shape.point(2, 0)),
)

== Graph Canvas

For simpler function-only plots, use `graph-canvas`:

#canvas.graph-canvas(
  width: 10cm,
  height: 5cm,
  graph.graph(x => x * x - 2, domain: (-3, 3), label: $x^2 - 2$),
)
]
#page("Polar & Trig Canvas")[
= Polar & Trig Canvas

Specialized canvases for polar coordinates and trigonometry.

== Polar Canvas

#definition("polar-canvas")[
  Creates a polar coordinate system with radial and angular axes.
  ```typst
  canvas.polar-canvas(
    width: 8cm,
    r-max: 3,
    ..objects
  )
  ```
]

#canvas.polar-canvas(
  width: 8cm,
  graph.polar-func(t => 2, label: "r=2"),
)

== Polar Functions

Use `graph.polar-func` to plot $r = f(theta)$:

#canvas.polar-canvas(
  width: 8cm,
  graph.polar-func(t => 1 + calc.cos(t), domain: (0, 2 * calc.pi), label: "Cardioid"),
)

== Trig Canvas

#definition("trig-canvas")[
  A Cartesian canvas with ticks at multiples of pi.
  ```typst
  canvas.trig-canvas(
    width: 10cm,
    ..objects
  )
  ```
]

#canvas.trig-canvas(
  width: 10cm,
  graph.graph(x => calc.sin(x), domain: (-calc.pi, calc.pi), label: $sin(x)$),
  graph.graph(x => calc.cos(x), domain: (-calc.pi, calc.pi), label: $cos(x)$),
  graph.graph(x => calc.tan(x), domain: (-calc.pi, calc.pi), label: $tan(x)$),
)

== Rose Curves

#example("Polar Rose")[
  $r = cos(3 theta)$ creates a 3-petal rose:

  #canvas.polar-canvas(
    width: 8cm,
    graph.polar-func(t => calc.cos(3 * t), domain: (0, calc.pi), label: "Rose"),
  )
]
]
#page("3D Space Canvas")[
= 3D Space Canvas

Visualize 3D geometry and vectors.

== Space Canvas

#definition("space-canvas")[
  Creates a 3D coordinate system with perspective.
  ```typst
  space-canvas(
    width: 8cm,
    ..objects
  )
  ```
]

#canvas.space-canvas(
  width: 10cm,
  shape.point(2, 1, z: 3, label: "P"),
)

== 3D Points

Use `point()` with z coordinate for 3D points:

#canvas.space-canvas(
  width: 10cm,
  shape.point(0, 0, z: 0, label: "O"),
  shape.point(3, 0, z: 0, label: "A"),
  shape.point(0, 3, z: 0, label: "B"),
  shape.point(0, 0, z: 3, label: "C"),
)

== 3D Vectors

Use `vec()` with 3 components for 3D vectors:

#definition("vec (3D)")[
  Creates a 3D vector from origin.
  ```typst
  vec((x, y, z), label: $arrow(v)$)
  ```
]

#canvas.space-canvas(
  width: 10cm,
  graph.vec((2, 1, 2), label: $arrow(v)$),
  graph.vec((1, 3, 1), label: $arrow(w)$),
)

== Coordinate Axes

The space canvas follows the right-hand rule:
- x-axis points right
- y-axis points forward
- z-axis points up
]

#chapter("Data Module", summary: "Data visualization: tables, series, and curves.")
#page("Tables")[
= Tables

The Data module provides table rendering with theme-aware styling.

== Table Plot

#definition("table-plot")[
  Creates a styled data table.
  ```typst
  table-plot(
    headers: ("x", "y", "z"),
    data: ((1, 2, 3), (4, 5, 6)),
  )
  ```
]

#data.table-plot(
  headers: ("Variable", "Mean", "Std Dev"),
  data: (
    ("Height", "175 cm", "8.5"),
    ("Weight", "70 kg", "12.3"),
    ("Age", "25 yr", "4.2"),
  ),
)

== Value Table

#definition("value-table")[
  Creates a function value table with variable and result rows.
  ```typst
  value-table(
    variable: $x$,
    func: $f(x)$,
    values: (1, 2, 3, 4),
    results: (1, 4, 9, 16),
  )
  ```
]

#data.value-table(
  variable: $x$,
  func: $x^2$,
  values: (-2, -1, 0, 1, 2),
  results: (4, 1, 0, 1, 4),
)

== Grid Table

#definition("grid-table")[
  Creates a grid layout for 2D data visualization.
  ```typst
  grid-table(
    data: ((1, 2, 3), (4, 5, 6)),
    show-indices: true,
  )
  ```
]

#data.grid-table(
  data: (
    (1, 2, 3),
    (4, 5, 6),
    (7, 8, 9),
  ),
  show-indices: true,
)

== Compact Table

For inline or small tables:

#data.compact-table(
  headers: ("n", "n!"),
  data: ((0, 1), (1, 1), (2, 2), (3, 6), (4, 24)),
)
]
#page("Data Series & CSV")[
= Data Series & CSV

Plot data points from arrays or CSV files.

== Data Series

#definition("data-series")[
  Creates a plotable data series from coordinate pairs.
  ```typst
  data-series(
    ((x1, y1), (x2, y2), ...),
    label: "Series",
    style: auto,
  )
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  data.data-series(
    ((0, 0), (1, 2), (2, 3), (3, 2.5), (4, 4)),
    label: "Data",
  ),
)

== Multiple Series

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  data.data-series(
    ((0, 1), (1, 3), (2, 2), (3, 4)),
    label: "Series A",
  ),
  data.data-series(
    ((0, 2), (1, 1), (2, 3), (3, 2)),
    label: "Series B",
  ),
)

== CSV Import

#definition("csv-series")[
  Loads data from a CSV file.
  ```typst
  csv-series(
    "path/to/data.csv",
    x-col: 0,
    y-col: 1,
    label: "CSV Data",
  )
  ```
]

#note("CSV Format")[
  The CSV file should have numeric data. Header rows are automatically detected and skipped.
]

== Polar Data Series

#definition("polar-data-series")[
  Creates a data series in polar coordinates (r, θ).
  ```typst
  polar-data-series(
    ((r1, θ1), (r2, θ2), ...),
    label: "Polar",
  )
  ```
]

Use `polar-data-series` with `polar-canvas` for radial data visualization.
]
#page("Smooth Curves")[
= Smooth Curves

Draw smooth curves through data points using spline interpolation.

== Curve Through Points

#definition("curve-through")[
  Creates a smooth curve through a set of points.
  ```typst
  curve-through(
    (p1, p2, p3, ...),
    label: "Curve",
    tension: 0.5,
  )
  ```

  - `tension`: Controls curve tightness (0 = linear, 1 = tight)
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  data.curve-through(
    ((0, 1), (1, 3), (2, 2), (3, 4), (4, 3)),
    label: "Smooth",
  ),
)

== Tension Control

#example("Tension Comparison")[
  Lower tension creates smoother curves:

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *Tension: 0.3*
      #canvas.cartesian-canvas(
        width: 5cm,
        x-tick: 1,
        y-tick: 1,
        data.curve-through(
          ((0, 1), (1, 3), (2, 1), (3, 3)),
          tension: 0.3,
        ),
      )
    ],
    [
      *Tension: 0.8*
      #canvas.cartesian-canvas(
        width: 5cm,
        x-tick: 1,
        y-tick: 1,
        data.curve-through(
          ((0, 1), (1, 3), (2, 1), (3, 3)),
          tension: 0.8,
        ),
      )
    ],
  )
]

== Smooth Curve

#definition("smooth-curve")[
  Alternative curve function with automatic tension.
  ```typst
  smooth-curve(
    (p1, p2, p3, ...),
    label: "Curve",
  )
  ```
]

#canvas.cartesian-canvas(
  x-tick: 1,
  y-tick: 1,
  data.smooth-curve(
    ((0, 0), (1, 2), (2, 1), (3, 3), (4, 2)),
    label: "Auto-smooth",
  ),
)
]

#chapter("Cover Module", summary: "Document covers and title pages.")
#page("Cover Templates")[
= Cover Templates

The Cover module provides document covers and title pages.

== Main Cover

#definition("cover")[
  The main document cover, shown at the beginning. Write `#cover()` in
  `main.typ`; it uses the document configuration automatically.
]

#note("Configuration")[
  Cover content comes from the `noteworthy` show rule in `main.typ`:
  ```typst
  #show: noteworthy.with(
    title: "Your Document Title",
    subtitle: "Optional Subtitle",
    authors: ("Author 1", "Author 2"),
    affiliation: "Your Institution",
  )
  ```
]

== Chapter Cover

#definition("chapter")[
  Shown at the start of each chapter. Declared in `main.typ`:
  ```typst
  #chapter("Chapter Title", summary: "Brief chapter description.")
  ```
  Chapter numbers follow document order automatically.
]

== Preface

#definition("preface")[
  Introduction page shown after the cover. Pass the text as the body:
  ```typst
  #preface[Welcome to my notes...]
  ```
]

== Page Title

#definition("page")[
  Individual page headers. Each page declares its title in `main.typ`,
  with its body inline or included from a file:
  ```typst
  #page("Page Title")[
    Inline content...
  ]
  #page("Another Page")[#include "content/1/2.typ"]
  ```
]

== Display Controls

The front matter is explicit: write `#cover()`, `#preface[..]`, and
`#toc()` in `main.typ` — or leave any of them out. The theme is set by
the `theme` option of the `noteworthy` show rule (e.g., "noteworthy-dark").
]

#chapter("Layout Module", summary: "Page layouts, outlines, and configuration.")
#page("Layout & Config")[
= Layout & Config

The Layout module manages document structure, outlining, and global configuration.

== Document Structure

#definition("main.typ")[
  The document entry point declares the whole book explicitly:
  ```typst
  #show: noteworthy.with(title: "My Notes", theme: "aether")

  #cover()
  #preface[Welcome to my notes.]
  #toc()

  #chapter("Chapter Title", summary: "What this chapter covers.")
  #page("Page Title")[
    Inline content — or `#include "content/1/1.typ"` from a file.
  ]
  ```
  Write pages inline or split them into one file per page; chapter and
  page numbers (and the table of contents) follow document order
  automatically.
]

== Configuration

#definition("noteworthy")[
  The `#show: noteworthy.with(...)` rule configures the document:
  - `theme`: Set the active color scheme (e.g., "noteworthy-light").
  - `font` / `title-font`: Body and heading typefaces.
  - `pad-chapter-id` / `pad-page-id`: Zero-pad numbering (e.g., "01.02").
  - `chapter-name`: The word shown before numbers (e.g., "Chapter").
  Every option has a sensible default; pass only what you change.
]

== Usage

The table of contents is generated by `#toc()`: it finds every
`#chapter` and `#page` in the document and resolves their real page
numbers in a single compile — no separate structure file needed.
]

#chapter("Combi Module", summary: "Combinatorics visualizations: permutations, combinations, and counting.")
#page("Combinatorics Visualizations")[
= Combinatorics Visualizations

Visual representations for counting problems.

== Linear Permutations

Arrange items in a row:

#canvas.blank-canvas(
  combi.linear-perm(combi.permutation(("A", "B", "C", "D"), labels: ("1st", "2nd", "3rd", "4th"))),
)

Highlight specific positions:

#canvas.blank-canvas(
  combi.linear-perm(combi.permutation(("1", "2", "3", "4", "5")), highlight: (0, 2, 4)),
)

== Circular Permutations

Arrange items in a circle:

#canvas.blank-canvas(
  combi.circular-perm(combi.permutation(("A", "B", "C", "D", "E")), radius: 1.5),
)

== Balls and Boxes

Distribute balls into boxes:

#definition("balls-boxes")[
  Visualize distribution problems:
  - Distinguishable balls: numbered, colored differently
  - Identical balls: same color
]

#example("Distinguishable Balls")[
  #canvas.blank-canvas(
    combi.balls-boxes(5, 3, distribution: (2, 2, 1), balls-identical: false),
  )
]

#example("Identical Balls")[
  #canvas.blank-canvas(
    combi.balls-boxes(3, 3, distribution: (3, 2, 1), balls-identical: true),
  )
]

== Subset Selection (Combinations)

Highlight a subset of elements:

#canvas.blank-canvas(
  combi.subset-vis(("a", "b", "c", "d", "e", "f"), subset: (1, 3, 5)),
)

== Counting Trees

Visualize multiplication principle:

#canvas.blank-canvas(
  combi.counting-tree((("R", "B"), ("S", "M", "L"), ("L", "R"))),
)

== Partition Diagrams

Ferrers/Young diagram for partitions:

#definition("partition-vis")[
  Shows a partition of n as a Ferrers diagram.
  ```typst
  partition-vis((4, 3, 2, 1))  // 4 + 3 + 2 + 1 = 10
  ```
]

#canvas.blank-canvas(
  combi.partition-vis((4, 3, 2, 1)),
)

#canvas.blank-canvas(
  combi.partition-vis((5, 5, 3, 1)),
)

== Pigeonhole Principle

Visualize when items must share containers:

#canvas.blank-canvas(
  combi.pigeonhole(5, 3), // 5 pigeons, 3 holes - at least one has 2+
)
]

#chapter("Trees Module", summary: "Visualizations for hierarchical data structures.")
#page("Trees and Hierarchies")[
= Trees and Hierarchies

Visualizing hierarchical data structures.


#definition("Structuring Trees")[
  Use `trees.tree-node(value, children: (...))` to define the hierarchy recursively.
  ```typst
  let root = trees.tree-node("Root", children: (
    trees.tree-node("Child 1"),
    trees.tree-node("Child 2"),
  ))
  ```
]

== Vertical Trees

Standard top-down tree visualization, commonly used for binary trees or organizational charts.

#definition("Vertical Tree")[
  Set `direction: "vertical"` to arrange nodes from top to bottom.
  ```typst
  trees.tree(root, direction: "vertical")
  ```
]

#let my-tree-node = trees.tree-node("Root", children: (
  trees.tree-node("A", children: (
    trees.tree-node("A1"),
    trees.tree-node("A2"),
  )),
  trees.tree-node("B", children: (
    trees.tree-node("B1"),
  )),
  trees.tree-node("C"),
))

#canvas.blank-canvas(
  trees.tree(
    my-tree-node,
    direction: "vertical",
    highlight-items: ("A",),
    highlight-path: ("Root", "B", "B1"),
  ),
)

== Horizontal Trees

Left-to-right tree visualization, useful for file systems or taxonomies.

#definition("Horizontal Tree")[
  Set `direction: "horizontal"` to arrange nodes from left to right.
  ```typst
  trees.tree(root, direction: "horizontal")
  ```
]

#let fs-tree = trees.tree-node("/", children: (
  trees.tree-node("bin", children: (
    trees.tree-node("ls"),
    trees.tree-node("pwd"),
  )),
  trees.tree-node("usr", children: (
    trees.tree-node("local"),
    trees.tree-node("lib"),
  )),
  trees.tree-node("home"),
))

#canvas.blank-canvas(
  trees.tree(
    fs-tree,
    direction: "horizontal",
    highlight-path: ("/", "usr", "local"),
  ),
)

== Path Highlighting

You can highlight specific paths to emphasize a traversal or a lineage.

#definition("Path Highlighting")[
  Provide a list of node names to `highlight-path`. The visualizer will highlight the nodes and the edges connecting them.
  ```typst
  trees.tree(
    root,
    highlight-path: ("Root", "Child", "Grandchild")
  )
  ```
]

#let path-tree = trees.tree-node("Start", children: (
  trees.tree-node("Step 1", children: (
    trees.tree-node("Option A"),
    trees.tree-node("Option B", children: (
      trees.tree-node("Goal"),
    )),
  )),
  trees.tree-node("Step 2"),
))

#canvas.blank-canvas(
  trees.tree(
    path-tree,
    direction: "vertical",
    highlight-path: ("Start", "Step 1", "Option B", "Goal"),
  ),
)
]

#chapter("CS & Algorithms", summary: "Visualizations for data structures and algorithms.")
#page("CS Data Structures")[
= CS Data Structures

The CS module provides visualizations for fundamental data structures like Arrays, Stacks, Queues, and Linked Lists.

== Arrays

#definition("cs-array")[
  Visualizes a contiguous array of elements with support for highlighting, pointers, and separators.

  ```typst
  cs-array(
    items: (10, 20, 30),
    highlight: (1,),
    pointers: ("0": "head"),
    separators: (1,),
    show-index: true
  )
  ```
  *Parameters:*
  - `items`: Content to display.
  - `highlight`: Indices to highlight.
  - `pointers`: Dictionary of `{index: label}`.
  - `separators`: List of indices to insert a gap after.
  - `show-index`: Toggle index visibility (default: true).
]



#canvas.blank-canvas(length: 10cm, height: 4cm, dsa.cs-array(
  (38, 27, 43, 3),
  separators: (1,),
  label: "Split Step",
))

== Stacks

#definition("cs-stack")[
  Visualizes a LIFO stack with optional push/pop animations.

  ```typst
  cs-stack(
    items: (10, 20),
    incoming: 30, // Push animation
    outgoing: 5,  // Pop animation
    show-index: false
  )
  ```
  *Parameters:*
  - `items`: Stack content (bottom to top).
  - `incoming`: Item to visualize being pushed.
  - `outgoing`: Item to visualize being popped (with arc arrow).
  - `show-index`: Show indices on the left (default: false).
]

#canvas.blank-canvas(length: 10cm, height: 6cm, dsa.cs-stack(
  (10, 20),
  outgoing: 30,
  label: "Pop Operation",
))

== Queues

#definition("cs-queue")[
  Visualizes a FIFO queue with symmetric enqueue/dequeue indicators.

  ```typst
  cs-queue(
    items: (1, 2, 3),
    incoming: 4, // Enqueue
    outgoing: 0, // Dequeue
    show-index: false
  )
  ```
  *Parameters:*
  - `items`: Queue content (front to back).
  - `incoming`: Item being enqueued (right).
  - `outgoing`: Item being dequeued (left).
  - `show-index`: Show indices below items (default: false).
]

#canvas.blank-canvas(length: 10cm, height: 4cm, dsa.cs-queue(
  (1, 2, 3),
  incoming: 4,
  label: "Enqueue",
))

== Linked Lists

#definition("cs-linked-list")[
  Visualizes a singly linked list with nodes and pointers.

  ```typst
  cs-linked-list(
    items: (12, 99),
    pointers: ("0": "head"),
    show-index: false
  )
  ```
  *Parameters:*
  - `items`: List content.
  - `pointers`: External pointers pointing to nodes.
  - `show-index`: Show indices below nodes (default: false).
]

#canvas.blank-canvas(length: 10cm, height: 4cm, dsa.cs-linked-list(
  (12, 99, 37),
  pointers: ("0": "head"),
  label: "Singly Linked List",
))
]
#page("Algorithms")[
= Algorithms

The Algo module provides visualizations for graph algorithms, pathfinding, and matrix operations.

== Graphs

#definition("free-graph")[
  Visualizes a node-link diagram with support for weighted, directed, and curved edges.

  ```typst
  free-graph(
    nodes, edges,
    highlight-path: ("A", "B"),
    highlight-nodes: ("A",),
    style: (label: "My Graph")
  )
  ```
  *Parameters:*
  - `nodes`: List of `graph-node` objects.
  - `edges`: List of `graph-edge` objects.
  - `highlight-path`: List of node names (in order) to highlight edges between.
  - `highlight-nodes`: List of node names to highlight.
]

#canvas.blank-canvas(length: 10cm, height: 6cm, {
  // No positions specified - nodes will be auto-positioned on a triangle
  let nodes = (
    dsa.graph-node("A"),
    dsa.graph-node("B"),
    dsa.graph-node("C"),
  )
  let edges = (
    dsa.graph-edge("A", "B", weight: 5, directed: true),
    dsa.graph-edge("B", "C", weight: 3, directed: true),
    dsa.graph-edge("C", "A", weight: 2, directed: true),
  )
  dsa.free-graph(nodes, edges, style: (label: "Simple Graph"))
})

== Grid World

#definition("grid-world")[
  Visualizes a 2D grid for pathfinding algorithms (A\*, BFS, etc.).

  ```typst
  grid-world(
    rows, cols,
    walls: ((1,1),),
    start: (0,0),
    target: (4,4),
    path: ((0,0), (0,1)...)
  )
  ```
  *Parameters:*
  - `rows`, `cols`: Grid dimensions.
  - `walls`: List of `(c, r)` coordinates for obstacles.
  - `start`, `target`: Coordinates for start (green) and target (red).
  - `path`: List of coordinates to highlight as the path.
]

#canvas.blank-canvas(length: 6cm, height: 6cm, dsa.grid-world(
  5,
  5,
  start: (0, 0),
  target: (4, 4),
  walls: ((2, 2),),
  path: ((0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (4, 1), (4, 2), (4, 3), (4, 4)),
  label: "Pathfinding",
))

== Adjacency Matrix

#definition("adjacency-matrix")[
  Visualizes a matrix (2D array) representing graph weights or connections.

  ```typst
  adjacency-matrix(
    matrix,
    labels: ("A", "B"...),
    highlight-cells: ((0,1),)
  )
  ```
  *Parameters:*
  - `matrix`: 2D list of values. Use `none` for infinity/no connection.
  - `labels`: Row/Column headers.
  - `highlight-cells`: List of `(row, col)` tuples to highlight.
]

#canvas.blank-canvas(length: 6cm, height: 6cm, dsa.adjacency-matrix(
  ((0, 5), (none, 0)),
  labels: ("A", "B"),
  label: "Weights",
))
]

#chapter("Timeline Module", summary: "Chronological event timelines for notes.")
#page("Timeline Examples")[
= Timeline Module

The timeline module creates visual timelines for chronological events, processes, and milestones.

== Basic Usage

Create events with `timeline.event()` and display with `timeline.timeline-figure()`:

#timeline.timeline-figure((
  timeline.event("1969", "Moon Landing"),
  timeline.event("1989", "Fall of Berlin Wall"),
  timeline.event("2000", "Y2K"),
))

== With Descriptions

Add descriptions for more context:

#timeline.timeline-figure((
  timeline.event("1776", "Declaration of Independence", description: "13 colonies declare freedom"),
  timeline.event("1789", "Constitution Ratified", description: "Bill of Rights added 1791"),
  timeline.event("1861", "Civil War Begins", description: "Lasted until 1865"),
))

== Highlighting Events

Mark important events with `highlight: true`:

#timeline.timeline-figure((
  timeline.event("Phase 1", "Research"),
  timeline.event("Phase 2", "Development", highlight: true),
  timeline.event("Phase 3", "Testing"),
  timeline.event("Phase 4", "Launch"),
))

== Horizontal Layout

Use `direction: "horizontal"` for compact display:

#timeline.timeline-figure(
  (
    timeline.event("Jan", "Start"),
    timeline.event("Mar", "Milestone 1"),
    timeline.event("Jun", "Milestone 2"),
    timeline.event("Dec", "Complete"),
  ),
  direction: "horizontal",
)
]
