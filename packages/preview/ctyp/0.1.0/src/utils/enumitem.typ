#let mod(x, y) = {
  if x < y {
    x
  } else {
    int(calc.round(calc.fract(x / y) * y))
  }
}

#let is-elem-item(elem) = elem.func() == enum.item or elem.func() == list.item

#let default-block-args = (
  above: 1em,
  below: 1em,
  inset: (left: 0em)
)

#let enumitem(
  marker: (sym.circle.filled, sym.triangle.r.filled, sym.dash),
  numberer: ("1)", "a)", "i)"),
  tight: true,
  indent: 0em,
  body-indent: 0.5em,
  spacing: auto,
  label-sep: 0em,
  marker-width: 0.5em,
  number-width: 1.5em,
  debug: false,
  ..block-args,
  children
) = context {
  let block-args = (:..default-block-args, ..block-args.named())
  show: block.with(..block-args)
  let spacing = if spacing == auto {
    if tight {
      par.leading
    } else {
      par.spacing
    }
  }
  let item-template(
    label-width: 1em,
    label-sep: label-sep,
    alignment: left,
    label: [],
    body: []
  ) = block(
    inset: (left: indent + label-width + body-indent),
    stroke: if (debug) { green + 1pt } else { none },
    above: spacing,
    below: spacing,
    {
      set par(first-line-indent: (amount: 0em, all: true), hanging-indent: 0em)
      box(
        width: 0em,
        move(box(
          width: label-width,
          inset: (right: label-sep),
          stroke: if (debug) { red } else { none },
          align(alignment, label)
        ), dx: - label-width - body-indent)
      ) + body
    }
  )
  let queue = ((
    marker: none,
    body: []
  ),)
  let cur = (0,)
  let cur-max = (children.len(),)
  let cur-number = ()
  let cur-type = ()
  let cur-marker = 0
  let cur-numberer = 0
  let depth = 0
  let elem = children
  let elem-last = none
  while cur.at(0) < cur-max.at(0) {
    if cur.at(depth) >= cur-max.at(depth) {
      let qe = queue.pop()
      queue.last().body += item-template(..qe)
      let _ = cur.pop()
      let _ = cur-max.pop()
      if cur-type.len() > 0 {
        let _ = cur-type.pop()
      }
      depth -= 1
      cur.last() += 1
      continue
    }
    // Deep-first search current element
    let c = 0
    elem = children
    while c <= depth {
      elem = if type(elem) == array {
        elem.at(cur.at(c))
      } else if elem.func() == list.item {
        elem.body.children.at(cur.at(c))
      } else if elem.func() == enum.item {
        elem.body.children.at(cur.at(c))
      } else {
        elem
      }
      c += 1
    }
    if elem.func() == list.item {
      if cur-number.len() <= depth {
        cur-number.push(none)
      }
      // Find marker
      if cur-type.len() == 0 {
        cur-type.push("list")
      } 
      if depth == 0 {
        cur-marker = 0
      } else if cur-type.len() <= depth {
        cur-type.push("list")
        if cur-type.at(depth - 1) == "enum" {
          cur-marker = 0
        } else {
          cur-marker = mod(cur-marker + 1, marker.len())
        }
      }
      let label = marker.at(cur-marker)
      if "children" in elem.body.fields() and elem.body.children.any(is-elem-item) {
        queue.push((
          label: label,
          label-width: marker-width,
          body: []
        ))
        depth += 1
        cur.push(0)
        cur-max.push(elem.body.children.len())
      } else {
        queue.push((
          label: label,
          label-width: marker-width,
          body: elem.body
        ))
        cur.at(depth) += 1
        let qe = queue.pop()
        queue.last().body += item-template(..qe)
      }
    } else if elem.func() == enum.item {
      if cur-type.len() == 0 {
        cur-type.push("enum")
      }
      if depth == 0 {
        cur-numberer = 0
      } else if cur-type.len() <= depth {
        cur-type.push("enum")
        if cur-type.at(depth - 1) == "list" {
          cur-numberer = 0
        } else {
          cur-numberer = mod(cur-numberer + 1, numberer.len())
        }
      }
      if cur-number.len() <= depth {
        cur-number.push(1)
      } else if cur-number.at(depth) == none {
        cur-number.at(depth) = 1
      }
      let number = cur-number.at(depth)
      cur-number.at(depth) += 1
      let label = numbering(numberer.at(cur-numberer), number)
      if "children" in elem.body.fields() and elem.body.children.any(is-elem-item) {
        queue.push((
          label: label,
          label-width: number-width,
          alignment: right,
          body: []
        ))
        depth += 1
        cur.push(0)
        cur-max.push(elem.body.children.len())
      } else {
        queue.push((
          label: label,
          label-width: number-width,
          alignment: right,
          body: elem.body
        ))
        cur.at(depth) += 1
        let qe = queue.pop()
        queue.last().body += item-template(..qe)
      }
    } else {
      queue.last().body += elem
      cur.at(depth) += 1
    }
    elem-last = elem
  }
  queue.pop().body
}