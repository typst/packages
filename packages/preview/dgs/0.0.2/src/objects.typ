#import "style.typ": color-to-hex

#let dgs-point(name, x, y, color: auto, size: auto) = {
  (
    type: "point",
    name: name,
    coords: (x * 1.0, y * 1.0),
    color: color-to-hex(color),
    size: if size != auto { size / 1pt } else { none },
  )
}

#let dgs-line(from, to, stroke: auto, color: auto) = {
  (
    type: "line",
    from: from,
    to: to,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}

#let dgs-circle(center, radius, color: auto, stroke: auto, fill: none) = {
  (
    type: "circle",
    center: center,
    radius: radius * 1.0,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
    fill: color-to-hex(fill),
  )
}

#let dgs-polygon(..pts, stroke: auto, color: auto, fill: none) = {
  (
    type: "polygon",
    points: pts.pos(),
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
    fill: color-to-hex(fill),
  )
}

#let dgs-ellipse(center, rx, ry, rotation: 0deg, color: auto, stroke: auto, fill: none) = {
  (
    type: "ellipse",
    center: center,
    rx: rx * 1.0,
    ry: ry * 1.0,
    rotation: rotation / 1deg,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
    fill: color-to-hex(fill),
  )
}

#let _dgs-arc-center(center, radius, start-angle, end-angle, color: auto, stroke: auto) = {
  (
    type: "arc",
    center: center,
    radius: radius * 1.0,
    start_angle: start-angle / 1deg,
    end_angle: end-angle / 1deg,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}

#let dgs-semicircle(from, to, dir: "CCW", center: auto, color: auto, stroke: auto, fill: none) = {
  let d = lower(str(dir))
  if d not in ("cw", "ccw", "clockwise", "counterclockwise", "counter-clockwise") {
    panic("dir must be CW or CCW, got " + str(dir))
  }
  let norm = if d in ("cw", "clockwise") { "CW" } else { "CCW" }
  (
    type: "semicircle",
    from: from,
    to: to,
    dir: norm,
    center: center,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
    fill: color-to-hex(fill),
  )
}

#let dgs-arc(..args, color: auto, stroke: auto, fill: none) = {
  let pos = args.pos()
  let named = args.named()
  if pos.len() == 4 {
    _dgs-arc-center(pos.at(0), pos.at(1), pos.at(2), pos.at(3), color: color, stroke: stroke)
  } else if pos.len() == 2 {
    let from = pos.at(0)
    let to = pos.at(1)
    let dir = if "dir" in named { named.at("dir") } else if "direction" in named { named.at("direction") } else { "CCW" }
    let center = if "center" in named { named.at("center") } else { auto }
    let fill_ = if "fill" in named { named.at("fill") } else { fill }
    dgs-semicircle(from, to, dir: dir, center: center, color: color, stroke: stroke, fill: fill_)
  } else if pos.len() == 3 {
    let from = pos.at(0)
    let to = pos.at(1)
    let dir = pos.at(2)
    let center = if "center" in named { named.at("center") } else { auto }
    let fill_ = if "fill" in named { named.at("fill") } else { fill }
    dgs-semicircle(from, to, dir: dir, center: center, color: color, stroke: stroke, fill: fill_)
  } else {
    panic("dgs-arc expects (center, radius, start-angle, end-angle) or (from, to, dir: CW/CCW, center: auto)")
  }
}

#let dgs-eq(expr, var: "x", color: auto, stroke: auto, samples: auto, tolerance: auto, precision: auto) = {
  (
    type: "curve",
    expr_str: expr,
    t_min: none,
    t_max: none,
    var_name: var,
    samples: if precision != auto { precision } else if samples != auto { samples } else { none },
    tolerance: if tolerance != auto { tolerance * 1.0 } else { none },
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}

#let dgs-eq-param(x-expr, y-expr, t1: 0, t2: 6.283185, color: auto, stroke: auto, samples: auto, tolerance: auto, precision: auto) = {
  (
    type: "curve_param",
    x_expr: x-expr,
    y_expr: y-expr,
    t_min: t1 * 1.0,
    t_max: t2 * 1.0,
    samples: if precision != auto { precision } else if samples != auto { samples } else { none },
    tolerance: if tolerance != auto { tolerance * 1.0 } else { none },
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}
