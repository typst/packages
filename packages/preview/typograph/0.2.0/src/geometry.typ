// The one place a diagram-unit coordinate (math convention: +x right, +y
// up) becomes a screen point (Typst convention: +x right, +y down). Every
// module that ends up calling `place(dx:, dy:)` or building `curve.*`
// points goes through this, so the y-flip only has to be correct once.
#let to-screen(p, unit) = (p.at(0) * unit, -p.at(1) * unit)

/// Resolves an `inset:` argument to `(left, right, top, bottom)` absolute
/// lengths, following Typst's own inset convention: a single value applies
/// to every side, or pass a dictionary with any of `left`/`right`/`top`/
/// `bottom`/`x`/`y`/`rest` (more specific keys win). A plain number means
/// diagram units — so it scales with the diagram — while a length (`4pt`,
/// `1mm`) is taken as-is.
#let inset-keys = ("left", "right", "top", "bottom", "x", "y", "rest")

// Validates the two inset dialects used by the package. Diagram/node insets
// additionally accept unitless diagram values; native content boxes accept
// relative lengths but not unitless numbers.
#let validate-inset(
  spec,
  source: "inset",
  allow-number: true,
  allow-relative: false,
) = {
  let valid(value) = (
    type(value) == length
      or (allow-number and type(value) in (int, float))
      or (allow-relative and type(value) in (ratio, relative))
  )
  if type(spec) == dictionary {
    let unknown = spec.keys().filter(key => key not in inset-keys)
    assert(
      unknown.len() == 0,
      message: source + " has unknown key(s): " + unknown.join(", ")
        + " — available: " + inset-keys.join(", "),
    )
    assert(
      spec.values().all(valid),
      message: source + " values must be "
        + if allow-number { "numbers or lengths" } else { "lengths or relative lengths" },
    )
  } else {
    assert(
      valid(spec),
      message: source + " must be "
        + if allow-number { "a number, length, or side dictionary" }
          else { "a length, relative length, or side dictionary" },
    )
  }
  spec
}

#let resolve-inset(spec, unit, source: "inset") = {
  let _ = validate-inset(spec, source: source)
  let to-length(v) = if type(v) == length { v } else { v * unit }
  if type(spec) != dictionary {
    let v = to-length(spec)
    return (left: v, right: v, top: v, bottom: v)
  }
  let rest = spec.at("rest", default: 0)
  let x = spec.at("x", default: rest)
  let y = spec.at("y", default: rest)
  (
    left: to-length(spec.at("left", default: x)),
    right: to-length(spec.at("right", default: x)),
    top: to-length(spec.at("top", default: y)),
    bottom: to-length(spec.at("bottom", default: y)),
  )
}

// The unit direction vector for an angle, used to build Bézier handles.
#let dir-vector(angle) = (calc.cos(angle), calc.sin(angle))

// Rotates a point about the origin by `angle`. Works on plain numbers and
// on lengths alike, so both diagram-unit and pt coordinates can use it.
#let rotate-point(p, angle) = {
  let ca = calc.cos(angle)
  let sa = calc.sin(angle)
  (p.at(0) * ca - p.at(1) * sa, p.at(0) * sa + p.at(1) * ca)
}

// Rotates a whole point array with one trigonometric evaluation. Polygon
// builders call this per node, where recomputing sin/cos at every vertex is a
// visible cost for high-sided custom shapes.
#let rotate-points(points, angle) = {
  if angle == 0deg { return points }
  let ca = calc.cos(angle)
  let sa = calc.sin(angle)
  points.map(point => (
    point.at(0) * ca - point.at(1) * sa,
    point.at(0) * sa + point.at(1) * ca,
  ))
}

// Mirrors a point across the local y-axis (negates x). The companion
// transform to `rotate-point` for directional shape builders' `flip` knob;
// applied before `rotate`, so mirroring stays defined in the shape's own
// unrotated frame regardless of `style.rotate`.
#let flip-point(p, flip) = if flip { (-p.at(0), p.at(1)) } else { p }

#let flip-points(points, flip) = {
  if not flip { return points }
  points.map(point => (-point.at(0), point.at(1)))
}

// Composes a directional shape builder's two orientation knobs in the one
// order every builder in `shape.typ` applies them: mirror, then rotate.
// Centralizing the order here means a new directional builder cannot
// accidentally apply them the other way around.
#let orient-point(p, style) = rotate-point(flip-point(p, style.flip), style.rotate)
#let orient-points(points, style) = rotate-points(flip-points(points, style.flip), style.rotate)

// Vertices (relative to center, absolute lengths) of a regular n-gon with
// circumradius `r`, with its first vertex rotated by `rotate` from the
// positive x-axis (measured the Typst way: clockwise-positive on screen).
#let regular-polygon(n, r, rotate: 0deg) = {
  range(n).map(i => {
    let a = rotate + i * (360deg / n)
    (r * calc.cos(a), r * calc.sin(a))
  })
}

// ---------------------------------------------------------------------
// "Where does a ray from the origin, at this angle, exit the shape?" —
// used to attach edges to a node's true boundary instead of its center
// (which matters for asymmetric shapes like the multiplier's pointer).
// All take/return absolute lengths; `angle` is Typst's screen convention
// (0deg = +x, 90deg = +y-down) — the same one `regular-polygon`/
// `rotate-point` already use, so a shape's own `rotate:` style composes
// directly with these.
// ---------------------------------------------------------------------

// Strips the unit from a length so plain `calc` functions (sqrt, etc.)
// can operate on it; the inverse of `* 1pt`.
#let num(l) = l / 1pt

// Axis-aligned rectangle, half-extents (hw, hh), centered at the origin.
#let rect-radius(hw, hh, angle) = {
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  if calc.abs(c) < 1e-9 { calc.abs(hh / s) }
  else if calc.abs(s) < 1e-9 { calc.abs(hw / c) }
  else { calc.min(calc.abs(hw / c), calc.abs(hh / s)) }
}

// Axis-aligned rectangle with a uniform rounded-corner radius. The ray first
// tries the straight side portions; if it reaches a corner region, intersect
// it with that corner's quarter-circle. `radius` is clamped exactly as a
// renderer must clamp it when it exceeds the shorter half-axis.
#let rounded-rect-radius(hw, hh, radius, angle) = {
  let r = calc.min(calc.max(num(radius), 0), num(hw), num(hh))
  if r <= 1e-9 { return rect-radius(hw, hh, angle) }
  let x = calc.abs(calc.cos(angle))
  let y = calc.abs(calc.sin(angle))
  let w = num(hw)
  let h = num(hh)
  let a = w - r
  let b = h - r
  if x < 1e-9 { return hh }
  if y < 1e-9 { return hw }
  let tx = w / x
  if y * tx <= b + 1e-9 { return tx * 1pt }
  let ty = h / y
  if x * ty <= a + 1e-9 { return ty * 1pt }
  let projection = x * a + y * b
  let constant = a * a + b * b - r * r
  (projection + calc.sqrt(calc.max(projection * projection - constant, 0))) * 1pt
}

// Axis-aligned ellipse with semi-axes (hw, hh), centered at the origin.
// Solving (t·cos/hw)² + (t·sin/hh)² = 1 for t.
#let ellipse-radius(hw, hh, angle) = {
  // A generic unlabeled node can legitimately collapse one or both axes.
  // Treat those cases as a line/point instead of dividing by zero.
  if hw == 0pt and hh == 0pt { return 0pt }
  if hw == 0pt {
    return if calc.abs(calc.cos(angle)) < 1e-9 { calc.abs(hh / calc.sin(angle)) } else { 0pt }
  }
  if hh == 0pt {
    return if calc.abs(calc.sin(angle)) < 1e-9 { calc.abs(hw / calc.cos(angle)) } else { 0pt }
  }
  let c = calc.cos(angle) / num(hw)
  let s = calc.sin(angle) / num(hh)
  let d = calc.sqrt(c * c + s * s)
  if d < 1e-12 { 0pt } else { (1 / d) * 1pt }
}

// Generic convex-or-not simple polygon, `pts` (closed implicitly: last
// point connects back to the first) centered so the ray starts at the
// origin.
#let polygon-radius(pts, angle) = {
  let dx = calc.cos(angle)
  let dy = calc.sin(angle)
  let n = pts.len()
  let best = none
  for i in range(n) {
    let (x1, y1) = pts.at(i).map(num)
    let (x2, y2) = pts.at(calc.rem(i + 1, n)).map(num)
    let ex = x2 - x1
    let ey = y2 - y1
    let denom = ex * dy - ey * dx
    if calc.abs(denom) > 1e-9 {
      let t = (ex * y1 - ey * x1) / denom
      let u = (dx * y1 - dy * x1) / denom
      if t > 1e-6 and u >= -1e-6 and u <= 1 + 1e-6 {
        if best == none or t < best { best = t }
      }
    }
  }
  if best == none { 0pt } else { best * 1pt }
}
