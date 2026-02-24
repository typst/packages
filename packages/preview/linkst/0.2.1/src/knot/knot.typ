#import "../draw/compute-items.typ": compute-items

#let knot(
  ..items,
  style: (:),
  layer: 0,
  bake: false,
) = (
  type: "knot",
  index: none,
  items: items,
  style: style,
  layer: layer,
  bake: bake,
)
