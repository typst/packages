#import "@preview/cetz:0.5.2"

#let class(name, center: (0, 0), type: none, attributes: (), methods: ()) = {
  return (
    name: name,
    type: type,
    attributes: attributes,
    methods: methods,
    center: center,
  )
}

#let row(center, gap, ..classes) = {
  let class_list = classes.pos()
  let n = class_list.len()
  let middle = (n - 1) / 2

  return class_list
    .enumerate()
    .map(((i, c)) => {
      let offset = (i - middle) * gap
      let (cx, cy) = center
      c.insert("center", (cx + offset, cy))
      c
    })
}

#let column(center, gap, ..classes) = {
  let class_list = classes.pos()
  let n = class_list.len()
  let middle = (n - 1) / 2

  return class_list
    .enumerate()
    .map(((i, c)) => {
      let offset = (i - middle) * gap
      let (cx, cy) = center
      c.insert("center", (cx, cy + offset))
      c
    })
}

#let group(center, ..classes) = {
  return classes
    .pos()
    .map(c => {
      c.insert("center", (c.center.at(0) + center.at(0), c.center.at(1) + center.at(1)))
      c
    })
}

