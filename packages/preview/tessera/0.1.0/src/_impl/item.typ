#import "@preview/elembic:1.1.1" as e
#import "typing.typ" as t

#let scalable = e.element.declare(
  "scalable",
  prefix: "tesselate",
  fields: (
    e.field(
      "body",
      content,
      named: false,
      required: true,
    ),
    e.field(
      "aspect-ratio",
      e.types.smart(float),
      default: auto,
      named: true,
    ),
    e.field(
      "fit",
      t.rescale-fit,
      default: "cover",
      named: true,
    ),
    e.field(
      "alignment",
      alignment,
      default: center + horizon,
      named: true,
    ),
    e.field(
      "rescale",
      e.types.smart(bool),
      default: auto,
      named: true,
    )
  ),
  allow-unknown-fields: true,
  display: el => el.body,
)

#let resolve-item(body) = {
  if e.eid(body) == e.eid(scalable) { body }
    else { scalable(body) }
}