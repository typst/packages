// Typed scene primitives and scene assembly for the scene core.
//
// A figure is a flat array of typed primitives — plain dictionaries tagged by a
// `kind` field, e.g. `(kind: "sphere", center: (0,0,0), r: 1)`. A later stage
// projects, depth-sorts and draws them; nothing here touches CeTZ. This mirrors
// the validated crystal-scene data model, generalised to carry raw
// 3D geometry (unprojected) plus two new kinds, `arrow` and `mesh`.
//
// Field-name map from the crystal-scene migration: `sphere` keeps `r`;
// `seg`/`edge` keep `a`/`b`; `face` keeps `pts`; `label` keeps `at`/`text`.
// `sphere` uses `center` (spelled out) rather than the former renderer's
// terse `c`. Extra named arguments to any constructor are styling hooks (colour,
// stroke, width, ...) and are stored verbatim on the primitive.

#import "coordinate.typ": normalize-coordinate, coordinate-is-concrete, transform-coordinate

/// Normalises a point to three components: a 2-vector `(x, y)` becomes
/// `(x, y, 0)`. Every primitive constructor runs its points through this so that
/// `camera-2d()` scenes can be written with flat `(x, y)` coordinates.
///
/// - p (vector): A 2- or 3-component point.
/// -> vector
#let _pt(p) = normalize-coordinate(p)

/// Fails if a `..sink` captured stray positional arguments.
#let _no-pos(sink, who) = assert(
  sink.pos().len() == 0,
  message: who + " takes no positional styling arguments, got " + repr(sink.pos()),
)

#let _with-name(p, name) = if name == none { p } else { (..p, name: name) }

// --- primitive constructors -------------------------------------------------

/// A shaded sphere at `center` with radius `r`.
///
/// - center (vector): Centre of the sphere (2- or 3-vector).
/// - r (float): Radius.
/// - ..style (any): Styling hooks (e.g. `color`) stored on the primitive.
/// -> dictionary
#let sphere(center, r, ..style, name: none) = {
  _no-pos(style, "sphere")
  assert(
    type(r) in (int, float) and r >= 0,
    message: "sphere radius must be a non-negative number, got " + repr(r),
  )
  _with-name((kind: "sphere", center: _pt(center), r: r, ..style.named()), name)
}

/// A drawn segment (e.g. a bond) from `a` to `b`.
///
/// - a (vector): Start point (2- or 3-vector).
/// - b (vector): End point (2- or 3-vector).
/// - ..style (any): Styling hooks (e.g. `color`, `w`).
/// -> dictionary
#let seg(a, b, ..style, name: none) = {
  _no-pos(style, "seg")
  _with-name((kind: "seg", a: _pt(a), b: _pt(b), ..style.named()), name)
}

/// A wireframe edge from `a` to `b` (e.g. a unit-cell edge).
///
/// - a (vector): Start point (2- or 3-vector).
/// - b (vector): End point (2- or 3-vector).
/// - ..style (any): Styling hooks.
/// -> dictionary
#let edge(a, b, ..style, name: none) = {
  _no-pos(style, "edge")
  _with-name((kind: "edge", a: _pt(a), b: _pt(b), ..style.named()), name)
}

/// An arrow from `from` to `to`.
///
/// - from (vector): Tail point (2- or 3-vector).
/// - to (vector): Head point (2- or 3-vector).
/// - ..style (any): Styling hooks (e.g. `color`, `w`, `head`).
/// -> dictionary
#let arrow(from, to, ..style, name: none) = {
  _no-pos(style, "arrow")
  _with-name((kind: "arrow", from: _pt(from), to: _pt(to), ..style.named()), name)
}

/// A filled planar polygon through the ordered points `pts`.
///
/// - pts (array): Ordered polygon vertices (each a 2- or 3-vector).
/// - ..style (any): Styling hooks (e.g. `color`).
/// -> dictionary
#let face(pts, ..style, name: none) = {
  _no-pos(style, "face")
  _with-name((kind: "face", pts: pts.map(_pt), ..style.named()), name)
}

/// An indexed triangle/quad mesh: `vertices` plus `faces` as arrays of vertex
/// indices into `vertices`. The shape generators (`uv-sphere`, `cylinder`, ...)
/// emit this kind.
///
/// - vertices (array): Mesh vertices (each a 2- or 3-vector).
/// - faces (array): Faces, each an array of 0-based indices into `vertices`.
/// - ..style (any): Styling hooks (e.g. `color`).
/// -> dictionary
#let mesh(vertices, faces, ..style, name: none) = {
  _no-pos(style, "mesh")
  _with-name((kind: "mesh", vertices: vertices.map(_pt), faces: faces, ..style.named()), name)
}

/// A text label anchored at `at`.
///
/// - at (vector): Anchor point (2- or 3-vector).
/// - text (any): The label content.
/// - ..style (any): Styling hooks.
/// -> dictionary
#let label(at, text, ..style, name: none) = {
  _no-pos(style, "label")
  _with-name((kind: "label", at: _pt(at), text: text, ..style.named()), name)
}

// --- affine transforms ------------------------------------------------------

/// Builds an affine transform `(matrix, offset)`: a point `p` maps to
/// `matrix * p + offset`.
///
/// - matrix (matrix): 3x3 linear part, as an array of three row 3-vectors.
/// - offset (vector): Translation applied after the linear part.
/// -> dictionary
#let affine(
  matrix: ((1, 0, 0), (0, 1, 0), (0, 0, 1)),
  offset: (0, 0, 0),
) = (matrix: matrix, offset: _pt(offset))

/// A pure translation by `v`.
///
/// - v (vector): Translation (2- or 3-vector).
/// -> dictionary
#let translate(v) = affine(offset: _pt(v))

/// A uniform scale by `s` about the origin. Note: scaling changes point
/// positions only; scalar sizes such as a sphere's `r` or a segment's width are
/// left untouched.
///
/// - s (float): Scale factor.
/// -> dictionary
#let scale(s) = affine(matrix: ((s, 0, 0), (0, s, 0), (0, 0, s)))

/// Applies affine `t` to a single point.
#let _apply(t, p) = transform-coordinate(t, p)

/// Applies affine `t` to every point carried by primitive `p`, returning a new
/// primitive of the same kind. Non-positional fields (radius, colour, ...) are
/// preserved unchanged.
#let _transform-prim(t, p) = {
  let k = p.kind
  if k == "sphere" { (..p, center: _apply(t, p.center)) }
  else if k == "seg" or k == "edge" { (..p, a: _apply(t, p.a), b: _apply(t, p.b)) }
  else if k == "arrow" { (..p, from: _apply(t, p.from), to: _apply(t, p.to)) }
  else if k == "face" { (..p, pts: p.pts.map(q => _apply(t, q))) }
  else if k == "mesh" { (..p, vertices: p.vertices.map(q => _apply(t, q))) }
  else if k == "label" { (..p, at: _apply(t, p.at)) }
  else { panic("unknown primitive kind: " + k) }
}

/// Flattens a sequence of primitives and nested groups (arrays of primitives)
/// into one array.
#let _flatten(items) = {
  let out = ()
  for it in items {
    if type(it) == array { out += it } else { out.push(it) }
  }
  out
}

/// Applies an affine transform to a bag of primitives and flattens the result.
///
/// `prims` may mix bare primitives and nested groups (which are themselves
/// arrays of primitives); everything is flattened into one array with `transform`
/// applied to every coordinate. Groups nest and compose left-to-right. Concrete
/// points transform immediately; named-anchor references retain the same ordered
/// transforms and apply them after resolution.
///
/// - transform (dictionary): An affine transform (see `affine`, `translate`).
/// - ..prims (dictionary, array): Primitives and/or nested groups.
/// -> array
#let group(transform, ..prims) = {
  assert(
    prims.named().len() == 0,
    message: "group takes no named arguments; put styling on the primitives themselves",
  )
  _flatten(prims.pos()).map(p => _transform-prim(transform, p))
}

// --- scene assembly ---------------------------------------------------------

#let _prim-coordinates(p) = {
  let k = p.kind
  if k == "sphere" { (p.center,) }
  else if k == "seg" or k == "edge" { (p.a, p.b) }
  else if k == "arrow" { (p.from, p.to) }
  else if k == "face" { p.pts }
  else if k == "mesh" { p.vertices }
  else if k == "label" { (p.at,) }
  else { panic("unknown primitive kind: " + k) }
}

/// The min/max corners a primitive contributes to the axis-aligned bbox.
#let _prim-points(p) = {
  let k = p.kind
  if k == "sphere" {
    let (c, r) = (p.center, p.r)
    (
      (c.at(0) - r, c.at(1) - r, c.at(2) - r),
      (c.at(0) + r, c.at(1) + r, c.at(2) + r),
    )
  } else if k == "seg" or k == "edge" { (p.a, p.b) }
  else if k == "arrow" { (p.from, p.to) }
  else if k == "face" { p.pts }
  else if k == "mesh" { p.vertices }
  else if k == "label" { (p.at,) }
  else { panic("unknown primitive kind: " + k) }
}

/// Axis-aligned bounding box `(min, max)` over concrete `prims`. An empty scene
/// yields a degenerate box at the origin; unresolved references yield `none`.
#let _bbox(prims) = {
  if not prims.all(p => _prim-coordinates(p).all(coordinate-is-concrete)) { return none }
  let pts = ()
  for p in prims { pts += _prim-points(p) }
  if pts.len() == 0 { return (min: (0, 0, 0), max: (0, 0, 0)) }
  let axis(i, f) = f(..pts.map(q => q.at(i)))
  (
    min: (axis(0, calc.min), axis(1, calc.min), axis(2, calc.min)),
    max: (axis(0, calc.max), axis(1, calc.max), axis(2, calc.max)),
  )
}

#let _object-registry(prims) = {
  let objects = (:)
  for p in prims {
    let name = p.at("name", default: none)
    if name != none {
      assert(type(name) == str, message: "object name must be a string, got " + repr(name))
      assert(name != "", message: "object name must not be empty")
      assert(not name.contains("."), message: "object name " + repr(name) + " must not contain `.`")
      assert(name not in objects, message: "duplicate object name " + repr(name))
      objects.insert(name, p)
    }
  }
  objects
}

/// Assembles primitives into a pure-data scene.
///
/// Positional arguments may be bare primitives or nested groups (arrays of
/// primitives); they are flattened into one array. The result is plain data:
/// `(prims:, bbox:, objects:)`, where `bbox` is `none` until named references are
/// resolved. No CeTZ dependency is involved.
///
/// - ..prims (dictionary, array): Primitives and/or groups.
/// -> dictionary
#let build-scene(..prims) = {
  assert(
    prims.named().len() == 0,
    message: "build-scene takes no named arguments, got " + repr(prims.named()),
  )
  let flat = _flatten(prims.pos())
  let objects = _object-registry(flat)
  (prims: flat, bbox: _bbox(flat), objects: objects)
}
