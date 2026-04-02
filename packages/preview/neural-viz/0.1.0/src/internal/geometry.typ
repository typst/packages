#let chars-cap(width, min: 8, scale: 4.2) = {
  calc.max(min, calc.floor(width * scale))
}

#let node-size(node, outer: false) = {
  if node.kind == "stack" {
    let add = if outer { (node.n - 1) * node.shift } else { 0 }
    (node.w + add, node.h + add)
  } else if node.kind == "trapezoid" {
    (node.w, 2 * calc.max(node.h-left, node.h-right))
  } else {
    (node.w, node.h)
  }
}

#let node-edge(node, side: "right", outer: false, outer-value: none) = {
  if node.kind == "stack" {
    let auto-add = (node.n - 1) * node.shift
    let ov = if outer-value == none { auto-add } else { outer-value }
    if side == "left" {
      node.cx - node.w / 2 - if outer { ov } else { 0 }
    } else if side == "right" {
      node.cx + node.w / 2 + if outer { ov } else { 0 }
    } else if side == "top" {
      node.cy + node.h / 2 + if outer { ov } else { 0 }
    } else {
      node.cy - node.h / 2 - if outer { ov } else { 0 }
    }
  } else {
    let (w, h) = node-size(node, outer: false)
    let ov = if outer and outer-value != none { outer-value } else { 0 }
    if side == "left" {
      node.cx - w / 2 - ov
    } else if side == "right" {
      node.cx + w / 2 + ov
    } else if side == "top" {
      node.cy + h / 2 + ov
    } else {
      node.cy - h / 2 - ov
    }
  }
}

#let node-anchor(node, side: "right", outer: false, outer-value: none) = {
  if side == "left" {
    (node-edge(node, side: "left", outer: outer, outer-value: outer-value), node.cy)
  } else if side == "right" {
    (node-edge(node, side: "right", outer: outer, outer-value: outer-value), node.cy)
  } else if side == "top" {
    (node.cx, node-edge(node, side: "top", outer: outer, outer-value: outer-value))
  } else if side == "bottom" {
    (node.cx, node-edge(node, side: "bottom", outer: outer, outer-value: outer-value))
  } else {
    (node.cx, node.cy)
  }
}

#let auto-pos-right(after, width, gap: 1.0, y: none, outer-after: true) = {
  let cx = node-edge(after, side: "right", outer: outer-after) + gap + width / 2
  let cy = if y == none { after.cy } else { y }
  (cx, cy)
}

#let resolve-node-center(
  pos,
  after,
  width,
  gap: 1.0,
  y: none,
  default-x: 1.0,
  outer-after: true,
) = {
  if pos != none {
    pos
  } else if after != none {
    auto-pos-right(after, width, gap: gap, y: y, outer-after: outer-after)
  } else {
    (default-x, if y == none { 0.0 } else { y })
  }
}

#let side-dir(side) = {
  if side == "left" {
    (-1.0, 0.0)
  } else if side == "right" {
    (1.0, 0.0)
  } else if side == "top" {
    (0.0, 1.0)
  } else {
    (0.0, -1.0)
  }
}
