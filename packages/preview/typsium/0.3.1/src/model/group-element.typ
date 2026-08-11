#import "@preview/elembic:1.1.1" as e
#import "../utils.typ": (
  count-to-content,
  charge-to-content,
  get-bracket,
  customizable-attach,
)

#let group(
  kind: 1,
  count: 1,
  charge: 0,
  affect-layout: false,
  grow-brackets: false,
  ..children,
) = { }

#let draw-group(it) = {
  let result = customizable-attach(
    if it.grow-brackets {
      math.lr({
        get-bracket(it.kind, open: true)
        for child in it.children {
          child
        }
        get-bracket(it.kind, open: false)
      })
    } else {
      get-bracket(it.kind, open: true)
      for child in it.children {
        child
      }
      get-bracket(it.kind, open: false)
    },
    tr: charge-to-content(it.charge),
    br: count-to-content(it.count),
    affect-layout: it.affect-layout,
  )

  return result
}
}


#let group = e.element.declare(
  "group",
  prefix: "@preview/typsium:0.3.0",

  display: draw-group,

  fields: (
    e.field("children", e.types.array(content), required: true),
    e.field("kind", int, default: 0),
    e.field("count", e.types.union(int, content), default: 1),
    e.field("charge", e.types.union(int, content), default: 0),
    e.field("grow-brackets", bool, default: false),
    e.field("affect-layout", bool, default: false),
  ),
)

