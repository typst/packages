#import "style.typ": color-to-hex

/// Create a point object.
#let dgs-point(name, x, y, color: auto, size: auto) = {
  (
    type: "point",
    name: name,
    coords: (x * 1.0, y * 1.0),
    color: color-to-hex(color),
    size: if size != auto { size / 1pt } else { none },
  )
}

/// Create a line between two points.
#let dgs-line(from, to, stroke: auto, color: auto) = {
  (
    type: "line",
    from: from,
    to: to,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}

/// Create a circle.
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

/// Create a polygon from points.
#let dgs-polygon(..pts, stroke: auto, color: auto, fill: none) = {
  (
    type: "polygon",
    points: pts.pos(),
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
    fill: color-to-hex(fill),
  )
}

/// Create an ellipse.
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

/// Create an arc.
#let dgs-arc(center, radius, start-angle, end-angle, color: auto, stroke: auto) = {
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

/// Plot a function y=f(x) or x=g(y).
#let dgs-eq(expr, var: "x", color: auto, stroke: auto) = {
  (
    type: "curve",
    expr_str: expr,
    t_min: none,
    t_max: none,
    var_name: var,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}

/// Plot parametric curve (x(t), y(t)).
#let dgs-eq-param(x-expr, y-expr, t1: 0, t2: 6.283185, color: auto, stroke: auto) = {
  (
    type: "curve_param",
    x_expr: x-expr,
    y_expr: y-expr,
    t_min: t1 * 1.0,
    t_max: t2 * 1.0,
    color: color-to-hex(color),
    stroke: if stroke != auto { stroke / 1pt } else { none },
  )
}
