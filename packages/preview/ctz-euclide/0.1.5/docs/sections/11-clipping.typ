// Clipping
#import "../helpers.typ": *

= Clipping

Lines that extend infinitely need to be clipped to the visible region.

== Clip to Canvas — `ctz-canvas(clip-canvas: ...)`

You can have the canvas set the clip region automatically by providing a clip
rectangle to `ctz-canvas`. This also fixes the canvas bounds to that rectangle:

```typst
#ctz-canvas(clip-canvas: (-1, -1, 4, 5), {
  import cetz.draw: *
  ctz-init()

  ctz-def-points(A: (0, 0), B: (2, 3))
  ctz-draw-line-add("A", "B", add: (5, 5), stroke: blue)
  ctz-show-clip(stroke: gray + 0.5pt)
})
```

Use `clip-canvas: false` to disable this per-canvas. You can also set a global
default with `ctz-default-clip-canvas`.

```typst
#let ctz-default-clip-canvas = (-1, -1, 4, 5)
#ctz-canvas({
  import cetz.draw: *
  ctz-init()
  // ... drawing code ...
})
```

// Clipped to canvas
#example(
  [```typst
  #ctz-canvas(length: 0.7cm, clip-canvas: (-1, -1, 4, 5), {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 3))
    ctz-draw-line-add("A", "B", add: (5, 5), stroke: blue)
    ctz-show-clip(stroke: gray + 0.5pt)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(A: (0, 0), B: (2, 3))
    ctz-draw-line-add("A", "B", add: (5, 5), stroke: blue)
    ctz-show-clip(stroke: gray + 0.5pt)
  },
  length: 0.7cm,
  clip-canvas: (-1, -1, 4, 5),
)

When `clip-canvas` is set, *only line-based elements* are clipped to the
canvas bounds (extended lines and segments). Circles, arcs, and other shapes are
not clipped yet. You can use the standard drawing helpers for lines:

```typst
ctz-draw-line-add("A", "B", add: (2, 2), stroke: blue)
ctz-draw-segment("A", "B", stroke: red)
```
