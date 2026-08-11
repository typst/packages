#import "@preview/cetz:0.5.0"
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font

#let _ss-render-label(label) = {
  if type(label) == str {
    ipa-to-unicode(label)
  } else {
    label
  }
}

#let _ss-node-id(node) = {
  if "id" in node {
    str(node.id)
  } else if "label" in node and type(node.label) == str {
    node.label
  } else {
    panic("Each sound-shift node must have either an id or a string label.")
  }
}

#let _ss-node-label(node) = {
  if "label" in node {
    node.label
  } else if "id" in node {
    node.id
  } else {
    panic("Each sound-shift node must have either a label or an id.")
  }
}

#let _ss-node-pos(node) = {
  if "at" in node {
    node.at
  } else if "pos" in node {
    node.pos
  } else {
    panic("Each sound-shift node must define a position with at: (x, y).")
  }
}

#let _ss-arrow-end(endpoint, nodes) = {
  if type(endpoint) == str {
    let key = str(endpoint)
    let node = nodes.find(n => n.id == key)
    assert(node != none, message: "Unknown sound-shift endpoint: " + key)
    (pos: node.at, radius: node.radius)
  } else if type(endpoint) == array and endpoint.len() >= 2 {
    let radius = endpoint.at(2, default: 0)
    (pos: (endpoint.at(0), endpoint.at(1)), radius: radius)
  } else {
    panic("Arrow endpoints must be node ids or coordinate pairs.")
  }
}

#let _ss-arrow-dict(arrow) = {
  if type(arrow) == dictionary {
    arrow
  } else if type(arrow) == array and arrow.len() >= 2 {
    (from: arrow.at(0), to: arrow.at(1))
  } else {
    panic("Each sound-shift arrow must be a dictionary or a (from, to) tuple.")
  }
}

#let sound-shift(
  nodes: (),
  arrows: (),
  highlights: (),
  node-size: 2.2em,
  text-fill: black,
  highlight-fill: luma(230),
  highlight-radius: 0.42,
  arrow-color: black,
  arrow-style: "solid",
  arrow-width: 0.8pt,
  arrow-size: 1.0,
  curved: false,
  curve: 0.45,
  scale: 1.0,
) = {
  assert(type(nodes) == array, message: "nodes must be an array")
  assert(nodes.len() > 0, message: "nodes array cannot be empty")

  let scale-factor = scale
  let normalized-nodes = nodes.map(node => {
    assert(type(node) == dictionary, message: "Each sound-shift node must be a dictionary.")
    let id = _ss-node-id(node)
    let label = _ss-node-label(node)
    let pos = _ss-node-pos(node)
    let normalized = (
      id: id,
      label: label,
      at: pos,
      fill: node.at("fill", default: none),
      size: node.at("size", default: node-size),
      text-fill: node.at("text-fill", default: text-fill),
      radius: node.at("radius", default: highlight-radius),
    )
    normalized
  })

  let all-points = normalized-nodes.map(n => n.at)
  let arrow-points = arrows.map(arrow => {
    let spec = _ss-arrow-dict(arrow)
    let from = _ss-arrow-end(spec.from, normalized-nodes)
    let to = _ss-arrow-end(spec.to, normalized-nodes)
    (from.pos, to.pos)
  })

  let pad = 0.6
  let xs = all-points.map(p => p.at(0)) + arrow-points.map(pair => pair.at(0).at(0)) + arrow-points.map(pair => pair.at(1).at(0))
  let ys = all-points.map(p => p.at(1)) + arrow-points.map(pair => pair.at(0).at(1)) + arrow-points.map(pair => pair.at(1).at(1))
  let min-x = calc.min(..xs) - pad
  let max-x = calc.max(..xs) + pad
  let min-y = calc.min(..ys) - pad
  let max-y = calc.max(..ys) + pad

  box(inset: 1.2em, baseline: 40%, cetz.canvas(length: scale-factor * 1cm, {
    import cetz.draw: *

    for item in highlights {
      let pos = _ss-arrow-end(item, normalized-nodes).pos
      circle(
        pos,
        radius: highlight-radius,
        fill: highlight-fill,
        stroke: none,
      )
    }

    for node in normalized-nodes {
      if node.fill != none {
        circle(
          node.at,
          radius: node.radius,
          fill: node.fill,
          stroke: none,
        )
      }
    }

    for arrow in arrows {
      let spec = _ss-arrow-dict(arrow)
      let from-end = _ss-arrow-end(spec.from, normalized-nodes)
      let to-end = _ss-arrow-end(spec.to, normalized-nodes)
      let from-pos = from-end.pos
      let to-pos = to-end.pos
      let dx = to-pos.at(0) - from-pos.at(0)
      let dy = to-pos.at(1) - from-pos.at(1)
      let dist = calc.sqrt(dx * dx + dy * dy)
      let safe-dist = if dist == 0 { 1 } else { dist }
      let ux = dx / safe-dist
      let uy = dy / safe-dist
      let start-gap = spec.at("start-gap", default: from-end.radius)
      let end-gap = spec.at("end-gap", default: to-end.radius)
      let drawn-from = (
        from-pos.at(0) + ux * start-gap,
        from-pos.at(1) + uy * start-gap,
      )
      let drawn-to = (
        to-pos.at(0) - ux * end-gap,
        to-pos.at(1) - uy * end-gap,
      )
      let px = -dy / safe-dist
      let py = dx / safe-dist
      let amount = spec.at("curve", default: curve)
      let ctrl = spec.at("ctrl", default: (
        (from-pos.at(0) + to-pos.at(0)) / 2 + px * safe-dist * amount,
        (from-pos.at(1) + to-pos.at(1)) / 2 + py * safe-dist * amount,
      ))
      let local-curved = spec.at("curved", default: curved)
      let local-color = spec.at("color", default: arrow-color)
      let local-width = spec.at("width", default: arrow-width) * scale-factor
      let local-style = spec.at("style", default: arrow-style)
      let start-tangent = if local-curved {
        let sx = ctrl.at(0) - from-pos.at(0)
        let sy = ctrl.at(1) - from-pos.at(1)
        let sd = calc.sqrt(sx * sx + sy * sy)
        if sd == 0 { (ux, uy) } else { (sx / sd, sy / sd) }
      } else {
        (ux, uy)
      }
      let end-tangent = if local-curved {
        let ex = to-pos.at(0) - ctrl.at(0)
        let ey = to-pos.at(1) - ctrl.at(1)
        let ed = calc.sqrt(ex * ex + ey * ey)
        if ed == 0 { (ux, uy) } else { (ex / ed, ey / ed) }
      } else {
        (ux, uy)
      }
      let drawn-from = (
        from-pos.at(0) + start-tangent.at(0) * start-gap,
        from-pos.at(1) + start-tangent.at(1) * start-gap,
      )
      let drawn-to = (
        to-pos.at(0) - end-tangent.at(0) * end-gap,
        to-pos.at(1) - end-tangent.at(1) * end-gap,
      )
      let drawn-ctrl = if local-curved {
        let from-shift = (
          drawn-from.at(0) - from-pos.at(0),
          drawn-from.at(1) - from-pos.at(1),
        )
        let to-shift = (
          drawn-to.at(0) - to-pos.at(0),
          drawn-to.at(1) - to-pos.at(1),
        )
        (
          ctrl.at(0) + (from-shift.at(0) + to-shift.at(0)) / 2,
          ctrl.at(1) + (from-shift.at(1) + to-shift.at(1)) / 2,
        )
      } else {
        ctrl
      }
      let shaft-stroke = if local-style == "dashed" {
        (paint: local-color, thickness: local-width, dash: "dashed")
      } else if local-style == "dotted" {
        (paint: local-color, thickness: local-width, dash: "dotted")
      } else {
        (paint: local-color, thickness: local-width)
      }
      let head-stroke = (paint: local-color, thickness: local-width)
      let mark-style = (end: ">", fill: local-color, scale: spec.at("arrow-size", default: arrow-size) * scale-factor)

      if local-style == "dashed" or local-style == "dotted" {
        if local-curved {
          bezier(drawn-from, drawn-to, drawn-ctrl, stroke: shaft-stroke)
        } else {
          line(drawn-from, drawn-to, stroke: shaft-stroke)
        }
        let tiny = 0.01
        let head-anchor = (
          drawn-to.at(0) - end-tangent.at(0) * tiny,
          drawn-to.at(1) - end-tangent.at(1) * tiny,
        )
        line(head-anchor, drawn-to, stroke: head-stroke, mark: mark-style)
      } else if local-curved {
        bezier(drawn-from, drawn-to, drawn-ctrl, stroke: shaft-stroke, mark: mark-style)
      } else {
        line(drawn-from, drawn-to, stroke: shaft-stroke, mark: mark-style)
      }
    }

    for node in normalized-nodes {
      content(
        node.at,
        anchor: "center",
        context text(
          font: phonokit-font.get(),
          size: node.size * scale-factor,
          fill: node.text-fill,
          top-edge: "x-height",
          bottom-edge: "baseline",
          _ss-render-label(node.label),
        ),
      )
    }
  }))
}
