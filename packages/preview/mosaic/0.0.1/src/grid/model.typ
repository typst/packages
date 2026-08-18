// Canonical grid values and node predicates.
#import "../shared.typ": tag

#let plane-ids = ("background", "foreground")

// Fitting is internal: the section layouts scale content they generate
// themselves, whose size no author can predict. Authors scale an oversized
// block of their own with native `scale(.., reflow: true)`.
#let fit-modes = (none, "width", "contain")

#let is-track-size(size) = (
  size == auto
    or type(size) in (
      type(1fr),
      type(1pt),
      type(1%),
      type(1% + 1pt),
    )
)

#let is-node(node) = (
  type(node) == dictionary
    and node.at("mosaic", default: none) == tag
    and node.at("kind", default: none) in ("cell", "split", "on")
)

#let is-track(value) = (
  type(value) == dictionary
    and value.keys().sorted() == ("child", "kind", "mosaic", "size")
    and value.mosaic == tag
    and value.kind == "track"
)

#let axis-name(axis) = if axis == "width" { "columns" } else { "rows" }

#let is-stroke(value) = (
  value == none
    or type(value) in (
      length,
      color,
      gradient,
      tiling,
      dictionary,
      stroke,
    )
)


