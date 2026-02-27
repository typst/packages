#import "@preview/cetz:0.3.4"
#import "helpers.typ": neg, arrowtip

#let neg-axis-color = luma(140)

#let draw-axis(r) = {
  import cetz.draw: *

  let axis(name, to: none) = {
    line(name: name, (0, 0, 0), to, mark: arrowtip())
    line(
      name: "-" + name,
      (0, 0, 0),
      neg(to),
      mark: arrowtip(color: neg-axis-color),
      stroke: neg-axis-color,
    )
  }

  let label(axis, c, anchors, paddings) = {
    content(
      axis + ".end",
      anchor: anchors.first(),
      padding: paddings.first(),
      c,
    )

    content(
      "-" + axis + ".end",
      anchor: anchors.last(),
      padding: paddings.last(),
      text(fill: neg-axis-color, $-#c$),
    )
  }

  // Tweaking the axis' lengths makes the diagram look better
  let c = 0.8 * r
  axis("x", to: (0, 0, 1))
  axis("z", to: (0, c, 0))
  axis("y", to: (c, 0, 0))

  label("z", $z$, ("south", "north"), (0.03, 0))
  label("x", $x$, ("north-east", "south"), (0, 0.03))
  label("y", $y$, ("west", "east"), (0.03, 0.03))
}
