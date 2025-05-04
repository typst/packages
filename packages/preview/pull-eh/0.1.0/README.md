# Pull-eh

Visualize pulleys with Typst and CeTZ. This package provides a function `wind()` that makes it easy
to draw a taut rope/cable winding around a number of pulleys or pivot points.

## Getting Started

To add this package to your project, use this:

```typ
#import "@preview/cetz:0.3.4"
#import "@preview/pull-eh:0.1.0": *

...

#cetz.canvas(length: 2cm, {
  import cetz.draw: *
  import pull-eh: *

  rotate(-65deg)

  let point = (0, 9)
  circle(name: "a", (5, 15), radius: 1)
  circle(name: "b", (5, 12), radius: 0.8)
  circle(name: "c", (5, 9), radius: 1)

  wind(
    stroke: 2pt,
    point,
    (coord: "a", radius: 1) + cw,
    (coord: "c", radius: 1) + cw,
    (coord: "b", radius: 0.8) + cw,
    "c.north",
  )
})
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>

## Usage

See the [manual](docs/manual.pdf) for details.
