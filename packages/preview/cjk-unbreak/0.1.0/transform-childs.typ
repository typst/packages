#import "@preview/touying:0.6.1": utils

#let named-body = (
  pad,
  figure,
  quote,
  strong,
  emph,
  footnote,
  highlight,
  overline,
  underline,
  strike,
  smallcaps,
  sub,
  super,
  box,
  block,
  hide,
  move,
  scale,
  circle,
  ellipse,
  rect,
  square,
  table.cell,
  grid.cell,
  math.equation,
  heading,
  par,
)

#let transform-childs(it, transform-func) = {
  if type(it) == content {
    if utils.is-sequence(it) {
      for item in it.children {
        transform-func(item)
      }
    } else if utils.is-styled(it) {
      let child = transform-func(it.child)
      utils.reconstruct-styled(it, child)
    } else if it.func() in named-body {
      let new-body = transform-func(it.at("body", default: none))
      utils.reconstruct(it, new-body, named: true)
    } else if it.has("body") {
      let new-body = transform-func(it.body)
      utils.reconstruct(it, new-body)
    } else if it.has("children") {
      let new-children = transform-func(it.children.map(i => transform-func(i)))
      utils.reconstruct-table-like(it, new-children)
    } else {
      it
    }
  } else if type(it) == array {
    it.map(i => transform-func(i))
  } else {
    it
  }
}
