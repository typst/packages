#import "@preview/cetz:0.5.0": draw, util

#let _state(ctx) = ctx.shared-state.at(
  "consketcher",
  default: (
    nodes: (:),
    defaults: (
      node-stroke: 1pt,
      mark-scale: 80%,
    ),
  ),
)

#let _defaults(ctx) = _state(ctx).defaults

#let _node-key(sym) = if type(sym) == str {
  sym
} else {
  repr(sym)
}

#let _register-node(sym, data) = draw.set-ctx(ctx => {
  let state = _state(ctx)
  state.nodes.insert(_node-key(sym), data)
  ctx.shared-state.insert("consketcher", state)
  ctx
})

#let _lookup-node(ctx, sym) = (
  _state(ctx).nodes.at(_node-key(sym), default: none)
)

#let _resolve(ctx, value) = util.resolve-number(ctx, value)

#let _measure(ctx, body) = if body == none {
  (0, 0)
} else {
  util.measure(ctx, body)
}

#let _with-label(sym, label) = if label == none {
  ()
} else {
  draw.content(sym, label)
}

#let _register-shape(sym, data, body, label: none) = (
  _register-node(sym, data) + body + _with-label(sym, label)
)

#let _is-right(value) = value == right or value == "right"

#let _is-up(value) = value == up or value == "up"

#let _is-down(value) = value == down or value == "down"

#let _rect-corners(center, width, height) = {
  let half-width = width / 2
  let half-height = height / 2
  (
    (center.at(0) - half-width, center.at(1) - half-height),
    (center.at(0) + half-width, center.at(1) + half-height),
  )
}

#let _triangle-points(center, width, height, dir) = {
  let half-width = width / 2
  let half-height = height / 2
  let left-x = center.at(0) - half-width
  let right-x = center.at(0) + half-width
  let top-y = center.at(1) - half-height
  let bottom-y = center.at(1) + half-height
  if _is-right(dir) {
    (
      (left-x, bottom-y),
      (left-x, top-y),
      (right-x, center.at(1)),
    )
  } else if _is-up(dir) {
    (
      (left-x, top-y),
      (right-x, top-y),
      (center.at(0), bottom-y),
    )
  } else if _is-down(dir) {
    (
      (left-x, bottom-y),
      (right-x, bottom-y),
      (center.at(0), top-y),
    )
  } else {
    (
      (right-x, bottom-y),
      (right-x, top-y),
      (left-x, center.at(1)),
    )
  }
}

#let _offset-point(point, offset) = _add(point, offset)

#let _as-offset(x, y) = if type(y) == array {
  y
} else {
  (x, y)
}

#let _sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))

#let _add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))

#let _scale(v, factor) = (v.at(0) * factor, v.at(1) * factor)

#let _cross(a, b) = a.at(0) * b.at(1) - a.at(1) * b.at(0)

#let _segment-length(a, b) = calc.sqrt(
  calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2),
)

#let _trim-rect(node, toward) = {
  let center = node.center
  let dx = toward.at(0) - center.at(0)
  let dy = toward.at(1) - center.at(1)
  if dx == 0 and dy == 0 {
    center
  } else {
    let half-width = node.width / 2
    let half-height = node.height / 2
    let scale-x = if dx == 0 { none } else { half-width / calc.abs(dx) }
    let scale-y = if dy == 0 { none } else { half-height / calc.abs(dy) }
    let scale = if scale-x == none {
      scale-y
    } else if scale-y == none {
      scale-x
    } else if scale-x < scale-y {
      scale-x
    } else {
      scale-y
    }
    (
      center.at(0) + dx * scale,
      center.at(1) + dy * scale,
    )
  }
}

#let _trim-circle(node, toward) = {
  let center = node.center
  let dx = toward.at(0) - center.at(0)
  let dy = toward.at(1) - center.at(1)
  if dx == 0 and dy == 0 {
    center
  } else {
    let scale = calc.sqrt(
      (dx * dx) / (node.rx * node.rx) + (dy * dy) / (node.ry * node.ry),
    )
    (
      center.at(0) + dx / scale,
      center.at(1) + dy / scale,
    )
  }
}

#let _trim-polygon(node, toward) = {
  let center = node.center
  let ray = _sub(toward, center)
  if ray.at(0) == 0 and ray.at(1) == 0 {
    center
  } else {
    let best = none
    let points = node.points
    for i in range(points.len()) {
      let a = points.at(i)
      let b = points.at(if i + 1 == points.len() { 0 } else { i + 1 })
      let edge = _sub(b, a)
      let denom = _cross(ray, edge)
      if calc.abs(denom) > 1e-6 {
        let delta = _sub(a, center)
        let ray-t = _cross(delta, edge) / denom
        let seg-t = _cross(delta, ray) / denom
        if ray-t >= 0 and seg-t >= 0 and seg-t <= 1 {
          let point = _add(center, _scale(ray, ray-t))
          if best == none or ray-t < best.t {
            best = (t: ray-t, point: point)
          }
        }
      }
    }
    if best == none { center } else { best.point }
  }
}

#let _trim-point(node, toward) = if node == none {
  none
} else if node.kind == "rect" {
  _trim-rect(node, toward)
} else if node.kind == "circle" {
  _trim-circle(node, toward)
} else if node.kind == "polygon" {
  _trim-polygon(node, toward)
} else {
  none
}

#let _path-points(n1, n2, corner: none) = {
  let x1 = n1.at(0)
  let y1 = n1.at(1)
  let x2 = n2.at(0)
  let y2 = n2.at(1)
  if x1 == x2 or y1 == y2 or corner == none {
    (n1, n2)
  } else if _is-right(corner) {
    (n1, (x1, y2), n2)
  } else {
    (n1, (x2, y1), n2)
  }
}

#let _trim-path(ctx, points) = {
  let points = points
  if points.len() >= 2 {
    let start = _trim-point(_lookup-node(ctx, points.first()), points.at(1))
    let stop = _trim-point(_lookup-node(ctx, points.last()), points.at(
      points.len() - 2,
    ))
    if start != none {
      points.at(0) = start
    }
    if stop != none {
      points.at(points.len() - 1) = stop
    }
  }
  points
}

#let _point-on-path(points, ratio) = {
  if points.len() <= 1 {
    (point: points.first(), dir: (1, 0))
  } else {
    let lengths = ()
    let total = 0.0
    for i in range(points.len() - 1) {
      let length = _segment-length(points.at(i), points.at(i + 1))
      lengths.push(length)
      total += length
    }

    if total == 0 {
      (point: points.first(), dir: (1, 0))
    } else {
      let target = calc.clamp(ratio, 0, 1) * total
      let walked = 0.0
      for i in range(lengths.len()) {
        let length = lengths.at(i)
        let next = walked + length
        if target <= next or i == lengths.len() - 1 {
          let start = points.at(i)
          let stop = points.at(i + 1)
          let local = if length == 0 { 0 } else { (target - walked) / length }
          return (
            point: (
              start.at(0) + (stop.at(0) - start.at(0)) * local,
              start.at(1) + (stop.at(1) - start.at(1)) * local,
            ),
            dir: _sub(stop, start),
          )
        }
        walked = next
      }
      (
        point: points.last(),
        dir: _sub(points.last(), points.at(points.len() - 2)),
      )
    }
  }
}

#let _label-anchor(point, dir, side, offset) = {
  let length = _segment-length((0, 0), dir)
  if length == 0 {
    point
  } else {
    let normal = (-dir.at(1) / length, dir.at(0) / length)
    let signed-offset = if _is-right(side) {
      -offset
    } else {
      offset
    }
    (
      point.at(0) + normal.at(0) * signed-offset,
      point.at(1) + normal.at(1) * signed-offset,
    )
  }
}

#let _stroke(stroke, dashed: false) = if not dashed {
  stroke
} else if type(stroke) == dictionary {
  let stroke = stroke
  stroke.insert("dash", "dashed")
  stroke
} else if type(stroke) == length {
  (thickness: stroke, dash: "dashed")
} else {
  (paint: stroke, thickness: 1pt, dash: "dashed")
}

#let _mark(marks, scale) = if type(marks) == str and marks.contains(">") {
  (
    end: "stealth",
    scale: if type(scale) == ratio { scale / 100% } else { scale },
  )
} else {
  none
}

#let _edge-body(
  ctx,
  points,
  label,
  label-pos,
  label-side,
  marks,
  stroke,
  dashed,
  name,
) = {
  let trimmed = _trim-path(ctx, points)
  let defaults = _defaults(ctx)
  let stroke = if stroke == auto { defaults.node-stroke } else { stroke }
  let body = draw.line(
    ..trimmed,
    name: name,
    stroke: _stroke(
      stroke,
      dashed: dashed
        or (
          type(marks) == str and marks.starts-with("--")
        ),
    ),
    mark: _mark(marks, defaults.mark-scale),
  )

  if label != none {
    let marker = _point-on-path(trimmed, label-pos)
    let label-size = _measure(ctx, label)
    let offset = calc.max(label-size.at(1) / 2 + 0.15, 0.25)
    body += draw.content(
      _label-anchor(marker.point, marker.dir, label-side, offset),
      label,
    )
  }

  body
}

#let _uturn-points(
  n1,
  n2,
  height,
  offset: none,
  vertical: false,
) = {
  let x1 = n1.at(0)
  let y1 = n1.at(1)
  let x2 = n2.at(0)
  let y2 = n2.at(1)
  if vertical {
    let turn-x = x1 + height
    if offset == none {
      (n1, (turn-x, y1), (x2 + height, y2), n2)
    } else {
      let turn-y = y1 - offset
      (n1, (turn-x, turn-y), (x2, y2 - offset), n2)
    }
  } else {
    let turn-y = y1 + height
    if offset == none {
      (n1, (x1, turn-y), (x2, y2 + height), n2)
    } else {
      let turn-x = x2 - offset
      (n1, (x1, turn-y), (turn-x, turn-y), (turn-x, y2), n2)
    }
  }
}
