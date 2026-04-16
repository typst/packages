#import "@preview/elembic:1.1.1" as e

#import "../utils.typ": (
  get-arrow,
)

#let reaction-arrow(
  kind: 0,
  top: none,
  bottom: none,
) = { }

#let draw-arrow(it) = {
  math.attach(
    math.stretch(
      get-arrow(it.kind),
      size: 100% + 2em,
    ),
    t: if it.top == []{none} else {it.top},
    b: if it.bottom == []{none} else {it.bottom},
  )
}

#let reaction-arrow = e.element.declare(
  "reaction-arrow",
  prefix: "@preview/typsium:0.3.2",
  
  display: draw-arrow,

  fields: (
    e.field("kind", int, default: 0),
    e.field("top", content, default: none),
    e.field("bottom", content, default: none),
  ),
)
