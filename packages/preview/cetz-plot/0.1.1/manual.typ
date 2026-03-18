#import "/src/cetz.typ"
#import "/doc/util.typ": *
#import "/doc/example.typ": example
#import "/doc/style.typ" as doc-style
#import "/src/lib.typ": *
#import "@preview/tidy:0.3.0"


// Usage:
//   ```example
//   /* canvas drawing code */
//   ```
#show raw.where(lang: "example"): example
#show raw.where(lang: "example-vertical"): example.with(vertical: true)

#make-title()

#set terms(indent: 1em)
#set par(justify: true)
#set heading(numbering: (..num) => if num.pos().len() < 4 {
    numbering("1.1", ..num)
  })
#show link: set text(blue)

// Outline
#{
  show heading: none
  columns(2, outline(indent: auto, depth: 3))
  pagebreak(weak: true)
}

#set page(numbering: "1/1", header: align(right)[CeTZ-Plot])

= Introduction

CeTZ-Plot is a simple plotting library for use with CeTZ.

= Usage

This is the minimal starting point:
#pad(left: 1em)[```typ
#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1"
#cetz.canvas({
  import cetz.draw: *
  import cetz-plot: *
  ...
})
```]
Note that plot functions are imported inside the scope of the `canvas` block.
All following example code is expected to be inside a `canvas` block, with the `plot`
module imported into the namespace.

= Plot

#doc-style.parse-show-module("/src/plot.typ")

#for m in ("line", "bar", "boxwhisker", "contour", "errorbar", "annotation", "formats", "violin", "legend") {
  doc-style.parse-show-module("/src/plot/" + m + ".typ")
}

== Styling
You can use style root `axes` with the following keys:
#doc-style.parse-show-module("/src/axes.typ")

=== Example
```example
import cetz.draw: *
import cetz-plot: *

set-style(axes: (
  stroke: (dash: "dotted", paint: gray),
  x: (mark: (start: ">", end: ">"), padding: 1),
  y: (mark: none),
  tick: (stroke: gray + .5pt),
))

plot.plot(size: (5, 4), axis-style: "school-book", y-tick-step: none, {
  plot.add(calc.sin, domain: (0, calc.pi * 2))
})

```

= Chart

#doc-style.parse-show-module("/src/chart.typ")
#for m in ("barchart", "boxwhisker", "columnchart", "piechart", "pyramid") {
  doc-style.parse-show-module("/src/chart/" + m + ".typ")
}

