#import "@preview/elembic:1.1.1" as e
#import "../utils.typ": (
  count-to-content,
  charge-to-content,
  is-default,
  customizable-attach,
)

#let molecule(
  count: 1,
  aggregation: none,
  //TODO: add up and down arrows
  transition: 0,
  ..children,
) = { }

#let draw-molecule(it) = {
  let result = count-to-content(it.count)
  for child in it.children {
    result += child
  }
  if not is-default(it.aggregation) {
    result += context {
      text(it.aggregation, size: text.size * 0.75)
    }
  }
  // return box(result, fill:red, outset: -0.05em)
  return result
}

#let molecule = e.element.declare(
  "molecule",
  prefix: "@preview/typsium:0.3.0",

  display: draw-molecule,
  fields: (
    e.field("children", e.types.array(content), required: true),
    e.field("count", e.types.union(int, content), default: 1),
    e.field("aggregation", e.types.union(str, content), default: none),
    e.field("transition", e.types.union(int, content), default: none),
  ),
)