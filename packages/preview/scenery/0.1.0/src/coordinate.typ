// Coordinate expressions shared by scene construction and named-anchor
// resolution. Concrete points stay plain 3-vectors; references and deferred
// affine transforms are small tagged dictionaries.

#import "linalg.typ": vadd, mvec

/// A reference to an anchor on a named scene object.
///
/// String references such as `"atom.east"` are the compact form. Use this
/// constructor when the anchor is not a string, notably a sphere screen-plane
/// angle or a world-space 3D direction vector.
///
/// - name (str): Named object.
/// - anchor (str, angle, array): Anchor name, camera-relative border angle, or
///   numeric 3D surface direction.
/// -> dictionary
#let anchor-ref(name, anchor: "default") = {
  assert(type(name) == str, message: "anchor reference name must be a string, got " + repr(name))
  assert(name != "", message: "anchor reference name must not be empty")
  assert(not name.contains("."), message: "anchor reference name " + repr(name) + " must not contain `.`")
  let vector-anchor = type(anchor) == array and anchor.len() == 3 and anchor.all(
    x => type(x) in (int, float)
  )
  assert(type(anchor) in (str, angle) or vector-anchor,
    message: "anchor must be a string, angle, or numeric 3-vector, got " + repr(anchor))
  assert(type(anchor) != str or anchor != "", message: "anchor name must not be empty")
  (kind: "anchor-ref", name: name, anchor: anchor)
}

#let _is-ref(c) = type(c) == dictionary and c.at("kind", default: none) == "anchor-ref"
#let _is-transformed(c) = type(c) == dictionary and c.at("kind", default: none) == "transformed-coordinate"

/// Normalises a public coordinate to a concrete 3-vector or tagged expression.
#let normalize-coordinate(c) = {
  if type(c) == array {
    assert(
      c.len() in (2, 3),
      message: "point must be a 2- or 3-component array, got " + repr(c),
    )
    if c.len() == 2 { (c.at(0), c.at(1), 0) } else { c }
  } else if type(c) == str {
    let parts = c.split(".")
    anchor-ref(
      parts.first(),
      anchor: if parts.len() == 1 { "default" } else { parts.slice(1).join(".") },
    )
  } else if _is-ref(c) {
    assert("name" in c, message: "anchor reference needs a `name` field")
    anchor-ref(c.name, anchor: c.at("anchor", default: "default"))
  } else if _is-transformed(c) {
    c
  } else {
    panic("coordinate must be a point or named anchor reference, got " + repr(c))
  }
}

#let coordinate-is-concrete(c) = type(c) == array

#let _apply-transform(t, p) = vadd(mvec(t.matrix, p), t.offset)

/// Applies affine `t` immediately to points and defers it for references.
#let transform-coordinate(t, c) = {
  c = normalize-coordinate(c)
  if coordinate-is-concrete(c) {
    _apply-transform(t, c)
  } else if _is-transformed(c) {
    (..c, transforms: c.transforms + (t,))
  } else {
    (kind: "transformed-coordinate", base: c, transforms: (t,))
  }
}

/// Applies the deferred transforms on an internal coordinate expression.
#let apply-deferred(c, resolve-base) = {
  c = normalize-coordinate(c)
  if coordinate-is-concrete(c) { c }
  else if _is-transformed(c) {
    c.transforms.fold(resolve-base(c.base), (p, t) => _apply-transform(t, p))
  } else {
    resolve-base(c)
  }
}

#let is-anchor-ref(c) = _is-ref(normalize-coordinate(c))

/// Names of objects a coordinate expression depends on.
#let coordinate-dependencies(c) = {
  c = normalize-coordinate(c)
  if coordinate-is-concrete(c) { () }
  else if _is-transformed(c) { coordinate-dependencies(c.base) }
  else { (c.name,) }
}

/// Name of an untransformed default-anchor reference, or `none`.
#let direct-default-reference(c) = {
  c = normalize-coordinate(c)
  if _is-ref(c) and c.anchor == "default" { c.name } else { none }
}
