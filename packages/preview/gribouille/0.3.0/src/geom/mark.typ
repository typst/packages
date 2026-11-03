///! Annotation geom that encloses each group with a chosen shape.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/errors.typ": fail-enum, fail-type
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/radial.typ": project-point
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

#let _METHODS = ("rect", "circle", "ellipse", "hull")

#let _group-points(rows, mapping) = {
  let pts = ()
  for row in rows {
    let x = parse-number(row.at(mapping.x, default: none))
    let y = parse-number(row.at(mapping.y, default: none))
    if x == none or y == none { continue }
    pts.push((x, y))
  }
  pts
}

#let _bbox(pts) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  (
    x-min: calc.min(..xs),
    x-max: calc.max(..xs),
    y-min: calc.min(..ys),
    y-max: calc.max(..ys),
  )
}

// Andrew's monotone chain convex hull. Inputs of fewer than three points
// are returned unchanged.
#let _centroid(pts) = {
  let sx = 0.0
  let sy = 0.0
  for p in pts {
    sx += p.at(0)
    sy += p.at(1)
  }
  let n = pts.len()
  (sx / n, sy / n)
}

#let _convex-hull(pts) = {
  if pts.len() < 3 { return pts }
  let sorted = pts.sorted(key: p => (p.at(0), p.at(1)))
  let cross = (o, a, b) => (
    (a.at(0) - o.at(0)) * (b.at(1) - o.at(1))
      - (a.at(1) - o.at(1)) * (b.at(0) - o.at(0))
  )
  let lower = ()
  for p in sorted {
    while (
      lower.len() >= 2
        and cross(lower.at(lower.len() - 2), lower.last(), p) <= 0
    ) {
      lower = lower.slice(0, lower.len() - 1)
    }
    lower.push(p)
  }
  let upper = ()
  for p in sorted.rev() {
    while (
      upper.len() >= 2
        and cross(upper.at(upper.len() - 2), upper.last(), p) <= 0
    ) {
      upper = upper.slice(0, upper.len() - 1)
    }
    upper.push(p)
  }
  lower.slice(0, lower.len() - 1) + upper.slice(0, upper.len() - 1)
}

#let _rect-vertices(bb, expand) = {
  let xlo = bb.x-min - expand
  let xhi = bb.x-max + expand
  let ylo = bb.y-min - expand
  let yhi = bb.y-max + expand
  ((xlo, ylo), (xhi, ylo), (xhi, yhi), (xlo, yhi))
}

#let _circle-vertices(pts, expand, n) = {
  let (cx, cy) = _centroid(pts)
  let r-sq = 0.0
  for p in pts {
    let dx = p.at(0) - cx
    let dy = p.at(1) - cy
    let d-sq = dx * dx + dy * dy
    if d-sq > r-sq { r-sq = d-sq }
  }
  let r = calc.sqrt(r-sq) + expand
  range(0, n).map(i => {
    let t = 2 * calc.pi * i / n
    (cx + r * calc.cos(t), cy + r * calc.sin(t))
  })
}

#let _ellipse-vertices(bb, expand, n) = {
  let cx = (bb.x-min + bb.x-max) / 2
  let cy = (bb.y-min + bb.y-max) / 2
  let a = (bb.x-max - bb.x-min) / 2 + expand
  let b = (bb.y-max - bb.y-min) / 2 + expand
  range(0, n).map(i => {
    let t = 2 * calc.pi * i / n
    (cx + a * calc.cos(t), cy + b * calc.sin(t))
  })
}

#let _expand-hull(hull, expand) = {
  if expand == 0 or hull.len() == 0 { return hull }
  let (cx, cy) = _centroid(hull)
  hull.map(p => {
    let dx = p.at(0) - cx
    let dy = p.at(1) - cy
    let d = calc.sqrt(dx * dx + dy * dy)
    if d == 0 { return p }
    let s = (d + expand) / d
    (cx + dx * s, cy + dy * s)
  })
}

/// Annotation layer enclosing each group with a chosen shape.
///
/// Splits rows by group (via `colour`/`fill`/`group` aesthetic), then draws one shape per group around its `(x, y)` points. Use to highlight clusters, regions, or category groupings.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`. Use `colour`, `fill`, or `group` to split rows into separate marks.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - method: Shape to draw: `"rect"` (bounding box), `"circle"` (smallest enclosing circle), `"ellipse"` (axis-aligned ellipse over the bounding box), or `"hull"` (convex hull). Named `method` to avoid clash with the `shape` aesthetic on `geom-point`.
/// - expand: Canvas-space padding around each shape, as a Typst length (e.g., `5pt`, `0.5cm`). `0pt` draws the shape flush with the cluster.
/// - n: Polygon resolution for `"circle"` and `"ellipse"`.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale.
/// - fill: Fixed fill colour. `auto` resolves via the fill scale.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Fill opacity in `[0, 1]`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-ellipse`, `geom-polygon`, `annotate`.
///
/// Hull-marking three clusters with translucent fill.
///
/// ```typst
/// #let pts = ()
/// #for (cx, cy, k) in ((1, 1, "a"), (4, 1, "b"), (2.5, 4, "c")) {
///   for i in range(0, 8) {
///     pts.push((
///       x: cx + 0.6 * calc.cos(i * 0.7),
///       y: cy + 0.6 * calc.sin(i * 0.7),
///       k: k,
///     ))
///   }
/// }
/// #plot(
///   data: pts,
///   mapping: aes(x: "x", y: "y", fill: "k"),
///   layers: (
///     geom-mark(method: "hull", expand: 5pt, alpha: 0.3),
///     geom-point(size: 3pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-mark(
  mapping: none,
  data: none,
  method: "circle",
  expand: 0pt,
  n: 64,
  colour: auto,
  fill: auto,
  stroke: 0.5pt,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = {
  if method not in _METHODS {
    fail-enum("geom-mark", "method", method, _METHODS)
  }
  if type(expand) != length {
    fail-type(
      "geom-mark",
      "expand",
      expand,
      "a Typst length (e.g., 5pt, 0.5cm)",
    )
  }
  make-layer(
    "mark",
    mapping: mapping,
    data: data,
    params: (
      method: method,
      expand: expand,
      n: n,
      colour: colour,
      fill: fill,
      stroke: stroke,
      alpha: alpha,
    ),
    stat: stat,
    position: position,
    inherit-aes: inherit-aes,
  )
}

#let _shape-vertices(method, pts, expand, n) = {
  if method == "rect" {
    return _rect-vertices(_bbox(pts), expand)
  }
  if method == "circle" {
    return _circle-vertices(pts, expand, n)
  }
  if method == "ellipse" {
    return _ellipse-vertices(_bbox(pts), expand, n)
  }
  if method == "hull" {
    return _expand-hull(_convex-hull(pts), expand)
  }
  ()
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let method = layer.params.method
  let expand = layer.params.expand
  let n = layer.params.n

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  let expand-cm = expand / 1cm

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let pts = _group-points(g.data, mapping)
    if pts.len() < 2 { continue }
    let projected-pts = ()
    for p in pts {
      let projected = project-point(ctx, p.at(0), p.at(1))
      if projected == none { continue }
      projected-pts.push(projected)
    }
    if projected-pts.len() < 2 { continue }
    let projected = _shape-vertices(method, projected-pts, expand-cm, n)
    if projected.len() < 3 { continue }

    let leader = g.data.first()
    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      leader,
      default-fill,
      colour-fallback: false,
      default-alpha: 0.4,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      leader,
      default-colour,
      default-thickness: default-thickness,
    )

    cetz.draw.line(
      ..projected,
      close: true,
      fill: final-fill,
      stroke: stroke-spec,
    )
  }
}
