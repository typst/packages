# Linkst

## Status 🚧  

This package is in early development (`v0.2.x`) and may change frequently.

## Introduction  

**Linkst** is a Typst package for drawing knots in knot theory.  
Since the package is new, formal documentation is limited.  
For examples of all available features, check the test files:  
📄 `tests/node.typ`, `tests/edge.typ` and `tests/knot.typ`

```typst
#import "@preview/linkst:0.2.1": *

// Example of drawing a trefoil knot:

#let trefoil = knot(
  node(0, 0, connect: ((0, 3), (1, 2, true))),
  node(2, 0, connect: ((0, 3, true), (1, 2))),
  node(1, calc.sqrt(3), connect: ((0, 3, true), (1, 2))),
  
  edge(0, 1, bend: -30deg, stroke: red),
  edge(1, 2, bend: -30deg, stroke: green),
  edge(2, 0, bend: -30deg, stroke: blue),
  edge(0, 1, bend: -100deg, stroke: green),
  edge(1, 2, bend: -100deg, stroke: blue),
  edge(2, 0, bend: -100deg, stroke: red),
)

#draw(
  trefoil,
)

#draw(
  trefoil,
  style: (debug: true),
)
```

## Gallery 🖼️

| [![Random Knot](gallery/random.png)](gallery/random.png) | [![Trefoil Knot](gallery/trefoil.png)](gallery/trefoil.png) | [![Layer Function](gallery/layers.png)](gallery/layers.png) |
|:---:|:---:|:---:|
| Random Knot | Trefoil Knot | Layer Function |

| [![Wild Trefoils](gallery/wild-trefoils.png)](gallery/wild-trefoils.png) | [![Bridge Types](gallery/bridges.png)](gallery/bridges.png) | [![Avocado](gallery/avocado.png)](gallery/avocado.png) |
|:---:|:---:|:---:|
| Wild Trefoils | Bridge Types | Avocado |
