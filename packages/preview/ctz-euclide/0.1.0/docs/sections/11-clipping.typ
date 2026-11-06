// Clipping
#import "../helpers.typ": *

= Clipping

Lines that extend infinitely need to be clipped to the visible region.

== Set Clip Region — `ctz-set-clip`

Define a rectangular clip boundary:

```typst
ctz-set-clip(xmin, ymin, xmax, ymax)
```

== Draw Clipped Line — `ctz-draw-line-global-clip`

Draw a line that is automatically clipped:

```typst
ctz-draw-line-global-clip("A", "B", add: (2, 2), stroke: blue)
```

The `add` parameter extends the line beyond the two points before clipping.

== Draw Clipped Segment — `ctz-draw-seg-global-clip`

Draw a segment with clipping:

```typst
ctz-draw-seg-global-clip("A", "B", stroke: red)
```

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(A: (0, 0), B: (2, 3))

    // Set clip boundary
    ctz-set-clip(-1, -1, 4, 5)

    // Draw extended line (clipped)
    ctz-draw-line-global-clip("A", "B", add: (5, 5), stroke: blue)

    // Show clip boundary
    ctz-show-clip(stroke: gray + 0.5pt)

    ctz-draw(points: ("A", "B"), labels: (
      A: "below",
      B: "above left"
    ))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 3))
    ctz-set-clip(-1, -1, 4, 5)
    ctz-draw-line-global-clip("A", "B", add: (5, 5), stroke: blue)
    ctz-show-clip(stroke: gray + 0.5pt)
    ctz-draw(points: ("A", "B"), labels: (
      A: "below",
      B: "above left"
    ))
  },
  length: 0.7cm,
)
