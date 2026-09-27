// Node-shape builders: pure geometry with no ZX meaning.
//
// A builder receives `(measured-label, resolved-inset, resolved-style)` and
// returns one outline dictionary. The renderer and edge clipper consume the
// same outline, so drawing, bounds, ports and wire attachment cannot drift
// apart. Styles store builders directly (`shape: shapes.circle`), so no
// secondary name-to-shape mapping has to stay synchronized with a theme.

#import "geometry.typ": (
  regular-polygon as _regular-points, rotate-point, rotate-points,
  orient-point, orient-points,
)

// ---------------------------------------------------------------------------
// Shared sizing and outline helpers
// ---------------------------------------------------------------------------

/// Fits a label plus resolved padding to a node style's minimum dimensions.
/// `clear-x`/`clear-y` add shape-specific breathing room around the label,
/// while `square` makes both axes use the larger fitted dimension.
#let fit-box(label, pad, style, clear-x: 1.0, clear-y: 1.0, square: false) = {
  let width = calc.max(
    style.min-width,
    label.width * clear-x + pad.left + pad.right,
  )
  let height = calc.max(
    style.min-height,
    label.height * clear-y + pad.top + pad.bottom,
  )
  if square {
    let side = calc.max(width, height)
    (side, side)
  } else {
    (width, height)
  }
}

// Area and even/odd containment for the fixed point (0, 0), derived in one
// edge walk. Normalize first so validity does not depend on whether a user
// describes the same template in units, millionths, or millions. Shape
// outlines require the
// node origin to be strictly inside so every clipping ray has a well-defined
// first exit. Polygon simplicity is part of the contract but deliberately not
// checked here: detecting self-intersections would add an O(n²) construction
// cost to every custom outline.
#let _polygon-properties(points) = {
  let magnitude = points.fold(0, (largest, point) => calc.max(
    largest,
    calc.abs(point.at(0)),
    calc.abs(point.at(1)),
  ))
  let scale = if magnitude == 0 { 1 } else { magnitude }
  let twice-area = 0
  let inside = false
  let on-boundary = false
  for index in range(points.len()) {
    let raw-a = points.at(index)
    let raw-b = points.at(calc.rem(index + 1, points.len()))
    let a = (raw-a.at(0) / scale, raw-a.at(1) / scale)
    let b = (raw-b.at(0) / scale, raw-b.at(1) / scale)
    let (ax, ay) = (a.at(0), a.at(1))
    let (bx, by) = (b.at(0), b.at(1))
    let cross = ax * by - ay * bx
    twice-area += cross
    // Collinear endpoint vectors that face in opposite directions put the
    // origin on this closed segment. Track this in the existing edge walk so
    // the promised strict-interior contract does not need another pass.
    if calc.abs(cross) <= 1e-9 and ax * bx + ay * by <= 1e-9 {
      on-boundary = true
    }
    if (ay > 0) != (by > 0) {
      let crossing = ax - ay * (bx - ax) / (by - ay)
      if crossing > 0 { inside = not inside }
    }
  }
  (twice-area: twice-area, contains-origin: inside and not on-boundary)
}

#let _polygon-outline(points, label-offset) = {
  assert(
    type(points) == array and points.len() >= 3
      and points.all(point => (
        type(point) == array and point.len() == 2
          and point.all(component => type(component) == length)
      )),
    message: "polygon-outline() needs at least three absolute-length point pairs",
  )
  assert(
    type(label-offset) == array and label-offset.len() == 2
      and label-offset.all(component => type(component) == length),
    message: "polygon-outline() label-offset must be an absolute-length pair",
  )
  let extents = points.fold(
    (half-width: 0pt, half-height: 0pt),
    (extents, point) => (
      half-width: calc.max(extents.half-width, calc.abs(point.at(0))),
      half-height: calc.max(extents.half-height, calc.abs(point.at(1))),
    ),
  )
  assert(
    extents.half-width > 0pt and extents.half-height > 0pt,
    message: "polygon-outline() points must span a non-zero area on both axes",
  )
  let numeric = points.map(point => (
    point.at(0) / 1pt,
    point.at(1) / 1pt,
  ))
  let properties = _polygon-properties(numeric)
  assert(
    calc.abs(properties.twice-area) > 1e-9,
    message: "polygon-outline() points must span a non-zero area on both axes",
  )
  assert(
    properties.contains-origin,
    message: "polygon-outline() requires the node origin strictly inside the polygon",
  )
  (
    kind: "polygon",
    points: points,
    half-width: extents.half-width,
    half-height: extents.half-height,
    label-offset: label-offset,
  )
}

/// Builds a polygon outline from absolute-length points relative to the node
/// origin. Points must describe a non-degenerate simple polygon containing the
/// origin; self-intersecting polygons are unsupported. This is the low-level
/// escape hatch; `shapes.polygon` below is the fitted, normalized public
/// factory for ordinary custom polygons.
#let polygon-outline(points, label-offset: (0pt, 0pt)) = {
  _polygon-outline(points, label-offset)
}

// Built-in polygon builders defer validation and extent derivation to the
// single `build-outline` boundary. Public `polygon-outline` remains the
// convenient fully-derived low-level constructor for custom builders.
#let _polygon(points, label-offset: (0pt, 0pt)) = {
  (
    kind: "polygon",
    points: points,
    label-offset: label-offset,
  )
}

#let _require-unrotated(name, style) = {
  assert(
    style.rotate == 0deg,
    message: "rotate is not supported by shapes." + name
      + "; use a polygonal shape or a custom builder",
  )
}

#let _resolve-rect-radius(spec, width, height) = {
  assert(
    type(spec) in (length, ratio, relative),
    message: "rect/square radius must be a uniform length or percentage",
  )
  // Match Typst's rect(): percentages are relative to half the shorter side,
  // so 100% means maximum rounding.
  let base = calc.min(width, height) / 2
  let radius = if type(spec) == length { spec }
    else if type(spec) == ratio { spec * base }
    else { spec.length + spec.ratio * base }
  assert(radius >= 0pt, message: "rect/square radius must be non-negative")
  calc.min(radius, base)
}

// ---------------------------------------------------------------------------
// Basic builders
// ---------------------------------------------------------------------------

/// Draws nothing. Useful for routing waypoints and unstyled semantic nodes.
#let empty(label, pad, style) = (kind: "empty")

/// Draws only the label, without a surrounding outline.
#let bare(label, pad, style) = {
  let _ = _require-unrotated("bare", style)
  (kind: "bare")
}

/// A circle fitted to the larger label axis.
#let circle(label, pad, style) = {
  let (width, _) = fit-box(
    label,
    pad,
    style,
    clear-x: 1.2,
    clear-y: 1.2,
    square: true,
  )
  (kind: "circle", radius: width / 2)
}

/// An axis-aligned ellipse fitted independently on both axes.
#let ellipse(label, pad, style) = {
  let _ = _require-unrotated("ellipse", style)
  let (width, height) = fit-box(
    label,
    pad,
    style,
    clear-x: 1.25,
    clear-y: 1.25,
  )
  (
    kind: "ellipse",
    half-width: width / 2,
    half-height: height / 2,
  )
}

/// A fully rounded rectangle (pill/stadium).
#let stadium(label, pad, style) = {
  let _ = _require-unrotated("stadium", style)
  let (width, height) = fit-box(label, pad, style)
  let half-width = width / 2
  let half-height = height / 2
  (
    kind: "rect",
    half-width: half-width,
    half-height: half-height,
    radius: calc.min(half-width, half-height),
  )
}

/// An axis-aligned rectangle. `style.radius` follows Typst's rect semantics.
#let rect(label, pad, style) = {
  let _ = _require-unrotated("rect", style)
  let (width, height) = fit-box(label, pad, style)
  (
    kind: "rect",
    half-width: width / 2,
    half-height: height / 2,
    radius: _resolve-rect-radius(style.radius, width, height),
  )
}

/// A square, represented internally by the same rectangular outline.
#let square(label, pad, style) = {
  let _ = _require-unrotated("square", style)
  let (width, _) = fit-box(label, pad, style, square: true)
  (
    kind: "rect",
    half-width: width / 2,
    half-height: width / 2,
    radius: _resolve-rect-radius(style.radius, width, width),
  )
}

// ---------------------------------------------------------------------------
// Polygon factories and directional builders
// ---------------------------------------------------------------------------

#let _numeric-point(point) = (
  type(point) == array and point.len() == 2
    and point.all(component => type(component) in (int, float))
)

#let _clearance(spec) = {
  let pair = if type(spec) in (int, float) { (spec, spec) } else { spec }
  assert(
    type(pair) == array and pair.len() == 2
      and pair.all(value => type(value) in (int, float) and value > 0),
    message: "polygon clearance must be a positive number or pair",
  )
  pair
}

/// Returns a regular-polygon shape builder.
///
/// `vertices` is the number of corners (and therefore edges), `rotate` is the
/// factory orientation, and `clearance` controls label breathing room. The
/// automatic clearance is the circumradius/apothem ratio, which naturally
/// gives triangles more room than high-sided polygons.
#let regular(vertices: 3, rotate: 0deg, clearance: auto) = {
  assert(
    type(vertices) == int and vertices >= 3,
    message: "shapes.regular() vertices must be an integer of at least 3",
  )
  assert(type(rotate) == angle, message: "shapes.regular() rotate must be an angle")
  let breathing-room = if clearance == auto {
    1 / calc.cos(180deg / vertices)
  } else {
    assert(
      type(clearance) in (int, float) and clearance > 0,
      message: "shapes.regular() clearance must be auto or a positive number",
    )
    clearance
  }
  // Trigonometry that depends only on the factory arguments is evaluated
  // once. Per node we only scale and, if requested, rotate these unit points.
  let unit-points = _regular-points(vertices, 1, rotate: rotate)
  (label, pad, style) => {
    let (width, _) = fit-box(
      label,
      pad,
      style,
      clear-x: breathing-room,
      clear-y: breathing-room,
      square: true,
    )
    let radius = width / 2
    let points = unit-points.map(point => (
      point.at(0) * radius,
      point.at(1) * radius,
    ))
    _polygon(rotate-points(points, style.rotate))
  }
}

/// Returns a fitted arbitrary-polygon shape builder.
///
/// `vertices` are unitless node-local points around the origin. The template
/// is uniformly scaled so its outer bounds cover the fitted label box while
/// preserving its aspect ratio. It must be non-degenerate, simple, and
/// contain the origin. Concave
/// polygons are supported; self-intersecting polygons are unsupported and are
/// not detected during construction.
#let polygon(
  vertices,
  anchor: auto,
  rotate: 0deg,
  clearance: 1,
  label-offset: (0, 0),
) = {
  assert(
    type(vertices) == array and vertices.len() >= 3
      and vertices.all(_numeric-point),
    message: "shapes.polygon() needs at least three numeric point pairs",
  )
  assert(type(rotate) == angle, message: "shapes.polygon() rotate must be an angle")
  assert(
    _numeric-point(label-offset),
    message: "shapes.polygon() label-offset must be a numeric point pair",
  )
  assert(
    anchor == auto or _numeric-point(anchor),
    message: "shapes.polygon() anchor must be auto or a numeric point pair",
  )
  let clear = _clearance(clearance)
  let first = vertices.first()
  let bounds = vertices.slice(1).fold(
    (min-x: first.at(0), max-x: first.at(0), min-y: first.at(1), max-y: first.at(1)),
    (bounds, point) => (
      min-x: calc.min(bounds.min-x, point.at(0)),
      max-x: calc.max(bounds.max-x, point.at(0)),
      min-y: calc.min(bounds.min-y, point.at(1)),
      max-y: calc.max(bounds.max-y, point.at(1)),
    ),
  )
  let origin = if anchor == auto {
    (
      (bounds.min-x + bounds.max-x) / 2,
      (bounds.min-y + bounds.max-y) / 2,
    )
  } else {
    anchor
  }
  // Factory rotation is static, so include it before deriving the fitting
  // extents. Per-node style.rotate intentionally rotates after fitting.
  let template = rotate-points(vertices.map(point => (
    point.at(0) - origin.at(0),
    point.at(1) - origin.at(1),
  )), rotate)
  let template-label-offset = rotate-point(label-offset, rotate)
  let extents = template.fold(
    (half-width: 0, half-height: 0),
    (extents, point) => (
      half-width: calc.max(extents.half-width, calc.abs(point.at(0))),
      half-height: calc.max(extents.half-height, calc.abs(point.at(1))),
    ),
  )
  let (template-half-width, template-half-height) = (
    extents.half-width,
    extents.half-height,
  )
  let properties = _polygon-properties(template)
  assert(
    template-half-width > 0 and template-half-height > 0
      and calc.abs(properties.twice-area) > 1e-9,
    message: "shapes.polygon() vertices must span a non-zero area on both axes",
  )
  assert(
    properties.contains-origin,
    message: "shapes.polygon() requires its anchor inside the polygon"
      + if anchor == auto { "; pass anchor: (...) when the bounding-box center is outside" } else { "" },
  )
  (label, pad, style) => {
    let (width, height) = fit-box(
      label,
      pad,
      style,
      clear-x: clear.at(0),
      clear-y: clear.at(1),
    )
    let scale = calc.max(
      width / (2 * template-half-width),
      height / (2 * template-half-height),
    )
    let scaled = template.map(point => (
      point.at(0) * scale,
      point.at(1) * scale,
    ))
    let scaled-offset = (
      template-label-offset.at(0) * scale,
      template-label-offset.at(1) * scale,
    )
    _polygon(
      orient-points(scaled, style),
      label-offset: orient-point(scaled-offset, style),
    )
  }
}

/// An equilateral directional triangle. Its label is nudged toward the broad
/// side, where a triangle has the most usable interior; `shapes.regular(3)`
/// is the centered-label alternative. Honors `style.flip` like the other
/// directional builders below.
#let triangle(label, pad, style) = {
  let (width, _) = fit-box(
    label,
    pad,
    style,
    clear-x: 2.1,
    clear-y: 2.1,
    square: true,
  )
  let radius = width / 2
  _polygon(
    orient-points(_regular-points(3, radius), style),
    label-offset: orient-point((-radius * 0.16, 0pt), style),
  )
}

/// A wide directional triangle whose label sits in its broad body. Honors
/// `style.flip`.
#let flat-triangle(label, pad, style) = {
  let (width, height) = fit-box(
    label,
    pad,
    style,
    clear-x: 2.0,
    clear-y: 1.6,
  )
  let (half-width, half-height) = (width / 2, height / 2)
  let raw = (
    (-half-width, -half-height),
    (half-width, 0pt),
    (-half-width, half-height),
  )
  _polygon(
    orient-points(raw, style),
    label-offset: orient-point((-half-width * 0.42, 0pt), style),
  )
}

/// A trapezoid whose top edge is controlled by `style.slant`. Honors
/// `style.flip`, mirrored before rotation.
#let trapezoid(label, pad, style) = {
  let (width, height) = fit-box(
    label,
    pad,
    style,
    clear-x: 1.15,
    clear-y: 1.0,
  )
  let (half-width, half-height) = (width / 2, height / 2)
  let slant = half-height * style.slant
  let points = (
    (-half-width, -half-height + slant),
    (half-width, -half-height),
    (half-width, half-height),
    (-half-width, half-height),
  )
  _polygon(orient-points(points, style))
}

/// A flat-sided pointer whose tip starts at `style.tip` of its half-width.
/// Honors `style.flip`.
#let arrow(label, pad, style) = {
  let tip = style.tip
  assert(
    type(tip) in (int, float) and tip > -1 and tip <= 1,
    message: "arrow tip must be in (-1, 1]",
  )
  let (width, height) = fit-box(label, pad, style)
  let half-width = width / (1 + tip)
  let half-height = height / 2
  let points = (
    (-half-width, -half-height),
    (tip * half-width, -half-height),
    (half-width, 0pt),
    (tip * half-width, half-height),
    (-half-width, half-height),
  )
  _polygon(
    orient-points(points, style),
    label-offset: orient-point((-(1 - tip) / 2 * half-width, 0pt), style),
  )
}

/// A rhombus on its points, fitted independently on both axes.
#let diamond(label, pad, style) = {
  let (width, height) = fit-box(
    label,
    pad,
    style,
    clear-x: 1.45,
    clear-y: 1.45,
  )
  let (half-width, half-height) = (width / 2, height / 2)
  let points = (
    (-half-width, 0pt),
    (0pt, -half-height),
    (half-width, 0pt),
    (0pt, half-height),
  )
  _polygon(rotate-points(points, style.rotate))
}

/// A regular hexagon with the package's established label clearance.
#let hexagon = regular(vertices: 6, clearance: 1.18)

// ---------------------------------------------------------------------------
// Builder result validation
// ---------------------------------------------------------------------------

#let _validate-outline(outline) = {
  assert(type(outline) == dictionary, message: "node shape builder must return an outline dictionary")
  let kind = outline.at("kind", default: none)
  let supported = ("empty", "bare", "circle", "ellipse", "rect", "polygon")
  assert(
    kind in supported,
    message: "node shape builder returned unsupported outline kind " + repr(kind),
  )
  let required = if kind in ("empty", "bare") { () }
    else if kind == "circle" { ("radius",) }
    else if kind == "ellipse" { ("half-width", "half-height") }
    else if kind == "rect" { ("half-width", "half-height", "radius") }
    else { ("points", "label-offset") }
  let missing = required.filter(field => field not in outline)
  assert(
    missing.len() == 0,
    message: "node shape builder returned " + repr(kind)
      + " without required field(s): " + missing.join(", "),
  )
  if "label-offset" in outline {
    assert(
      type(outline.label-offset) == array and outline.label-offset.len() == 2
        and outline.label-offset.all(component => type(component) == length),
      message: "outline label-offset must be an absolute-length pair",
    )
    assert(
      kind not in ("empty", "bare"),
      message: kind + " outlines cannot use label-offset",
    )
  }
  if kind == "circle" {
    assert(
      type(outline.radius) == length and outline.radius >= 0pt,
      message: "circle outline radius must be a non-negative length",
    )
  } else if kind in ("ellipse", "rect") {
    assert(
      type(outline.half-width) == length and outline.half-width >= 0pt
        and type(outline.half-height) == length and outline.half-height >= 0pt,
      message: kind + " outline half-width/half-height must be non-negative lengths",
    )
    if kind == "rect" {
      assert(
        type(outline.radius) == length and outline.radius >= 0pt,
        message: "rect outline radius must be a non-negative length",
      )
    }
  }
  if kind == "polygon" {
    return _polygon-outline(outline.points, outline.label-offset)
  }
  outline
}

/// Invokes and validates a node-shape builder.
#let build-outline(builder, label, pad, style) = {
  assert(
    type(builder) == function,
    message: "node shape must be a builder function such as shapes.circle",
  )
  _validate-outline(builder(label, pad, style))
}
