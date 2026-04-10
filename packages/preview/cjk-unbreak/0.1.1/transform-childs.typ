#import "@preview/touying:0.6.1": utils

#let named-fields = (
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

#let reconstruct(body-name: "body", labeled: true, named: false, withouts: (), it, ..new-body) = {
  let fields = it.fields()
  let label = fields.remove("label", default: none)
  let _ = fields.remove(body-name, default: none)
  for k in withouts {
    let _ = fields.remove(k, default: none)
  }
  if named {
    if label != none and labeled {
      return utils.label-it((it.func())(..fields, ..new-body), label)
    } else {
      return (it.func())(..fields, ..new-body)
    }
  } else {
    if label != none and labeled {
      return utils.label-it((it.func())(..fields.values(), ..new-body), label)
    } else {
      return (it.func())(..fields.values(), ..new-body)
    }
  }
}
#let reconstruct-table-like(named: true, labeled: true, it, new-children) = {
  reconstruct(body-name: "children", named: named, labeled: labeled, it, ..new-children)
}

#let transform-childs(it, transform-func) = {
  if type(it) == content {
    if utils.is-sequence(it) {
      for item in it.children {
        transform-func(item)
      }
    } else if utils.is-styled(it) {
      let child = transform-func(it.child)
      utils.reconstruct-styled(it, child)
    } else if it.func() == place {
      let new-body = transform-func(it.body)
      let fields = it.fields()
      let alignment = fields.remove("alignment", default: auto)
      reconstruct(
        named: true,
        withouts: ("alignment",),
        it,
        alignment,
        new-body,
      )
    } else if it.func() in named-fields {
      let new-body = transform-func(it.at("body", default: none))
      reconstruct(it, new-body, named: true)
    } else if it.has("body") {
      let new-body = transform-func(it.body)
      reconstruct(it, new-body)
    } else if it.has("children") {
      let new-children = transform-func(it.children.map(i => transform-func(i)))
      reconstruct-table-like(it, new-children)
    } else {
      it
    }
  } else if type(it) == array {
    it.map(i => transform-func(i))
  } else {
    it
  }
}
