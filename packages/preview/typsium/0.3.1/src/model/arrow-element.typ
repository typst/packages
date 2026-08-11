#import "@preview/elembic:1.1.1" as e

#import "../utils.typ": (
  get-arrow,
)

#let arrow(
  kind: 0,
  top: (),
  bottom: (),
) = { }

#let draw-arrow(it) = {
  math.attach(
    math.stretch(
      get-arrow(it.kind),
      size: 100% + 2em,
    ),
    t: for top-child in it.top {
      top-child
    },
    b: for bottom-child in it.bottom {
      bottom-child
    },
  )
}

#let arrow = e.element.declare(
  "arrow",
  prefix: "@preview/typsium:0.3.0",

  display: draw-arrow,

  fields: (
    e.field("kind", int, default: 0),
    e.field("top", e.types.array(e.types.any), default: ()),
    e.field("bottom", e.types.array(e.types.any), default: ()),
  ),
)
