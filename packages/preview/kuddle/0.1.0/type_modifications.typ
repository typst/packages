#let apply-to-entry(e) = {
  if e.type == none {
    (
      name: e.name,
      value: e.value
    )
  } else if e.type == "typst" or e.type == "typ" {
    (
      name: e.name,
      value: eval(e.value)
    )
  } else {
    (
      name: e.name,
      type: e.type,
      value: e.value
    )
  }
}

#let apply-to-node(n) = {
  if n.type == none {
    (
      name: n.name,
      entries: n.entries.map(apply-to-entry),
      children: n.children.map(apply-to-node),
    )
  } else {
    (
      name: n.name,
      type: n.type,
      entries: n.entries.map(apply-to-entry),
      children: n.children.map(apply-to-node),
    )
  }
}

#let apply-typst(doc) = {
  doc.map(apply-to-node)
}