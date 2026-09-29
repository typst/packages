#import "@preview/elembic:1.1.1" as e

#import "../utils.typ": (
  get-arrow,
)

#let reaction-arrow(
  kind: 0,
  top: none,
  bottom: none,
  size: 100% +2em,
) = { }

#let draw-arrow(it) = {
  let base = if it.kind == 8 or it.kind == 9{
    it.size = 2em
    // 
    // there sadly is no symbol for unequal length harpoon arrows
    // so we have to make it ourselves...
    let is-right = it.kind == 8
    math.class("relation",
      box(
        place(
          bottom + center,
          math.stretch(
            sym.harpoon.lb,
            size: if is-right {it.size * 0.5} else {it.size}
          ),
          dy:0.1em,
        ) + place(
          bottom + center,
          math.stretch(
            sym.harpoon.rt,
            size: if is-right {it.size} else {it.size * 0.5}
          ),
          dy:-0.1em,
        ),
        width:it.size,
        height: 0.75em,
        // fill:blue
      )
    )
  } else{
    math.stretch(
      get-arrow(it.kind),
      size: it.size,
    )
  }

  math.attach(
    base,
    t: if it.top == []{none} else {
      show math.equation: set text(size:0.7em)
      it.top
      },
    b: if it.bottom == []{none} else {
      show math.equation: set text(size:0.7em)
      it.bottom
      },
  )
}

#let reaction-arrow = e.element.declare(
  "reaction-arrow",
  prefix: "typsium",
  
  display: draw-arrow,

  fields: (
    e.field("kind", int, default: 0),
    e.field("top", content, default: none),
    e.field("bottom", content, default: none),
    e.field("size", relative, default: 100% + 2em,),
  ),
)
