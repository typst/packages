// One schema traversal, through the kind descriptors, shared by lens,
// introspection and the strict-schema walkers. Paths are lens paths: a
// field name, "items" for an array's elements, "additionalProperties"
// for an object's additional schema, an int index for a union member,
// "not" for a `not` member, "if", "then" and "else" for a conditional's
// condition and branches.

#import "../core/error.typ": _bail
#import "registry.typ": _descriptor

#let _children(s) = (_descriptor(s).children)(s)

// Segments match by type as well as value, so `1.0` or `"0"` names no
// union member.
#let _child(s, seg) = {
  let hit = _children(s).find(((k, ..)) => type(k) == type(seg) and k == seg)
  if hit == none {
    _bail(none, (_descriptor(s).bad-segment)(s, seg))
  }
  hit.at(1)
}

#let _get-at(s, path) = path.fold(s, _child)

// _child runs on the way down, so a bad segment panics the same way
// from a put as from a get.
#let _set-at(s, path, sub) = if path == () { sub } else {
  let (head, ..rest) = path
  (_descriptor(s).with-child)(s, head, _set-at(_child(s, head), rest, sub))
}

// Every (path, node) pair, pre-order.
#let _nodes(s, path: ()) = {
  let out = ((path, s),)
  for (seg, sub, _) in _children(s) {
    out += _nodes(sub, path: path + (seg,))
  }
  out
}

// The path of every node in `s` that `keep` holds for, pre-order.
#let _paths-where(s, keep) = (
  _nodes(s).filter(((_, n)) => keep(n)).map(((p, _)) => p)
)

// `s` with `f` applied to each child. As in lens paths, an object
// field literally named "additionalProperties" shadows the additional
// schema, so in that collision both writes land on the field.
#let _map-children(s, f) = _children(s).fold(s, (acc, (seg, sub, _)) => (
  (_descriptor(acc).with-child)(acc, seg, f(sub))
))

// A location: where lens and introspection functions point. A lens
// `(lens: path)`, or a bare path array. The old lens shape
// `(kind: "lens", path: …)` is accepted too, deprecated, until 1.0.
// None of the three is a schema node: an array is not a dictionary, a
// lens has no `kind`, and "lens" is no registered kind.
#let _is-lens(x) = (
  type(x) == dictionary and x.keys() == ("lens",) and type(x.lens) == array
)
#let _is-old-lens(x) = (
  type(x) == dictionary
    and x.at("kind", default: none) == "lens"
    and type(x.at("path", default: none)) == array
)
#let _is-location(x) = type(x) == array or _is-lens(x) or _is-old-lens(x)

// The path a location names. Panics, naming `who`, on anything else.
#let _location-path(at, who) = {
  if type(at) == array { return at }
  if _is-lens(at) { return at.lens }
  if _is-old-lens(at) { return at.path }
  _bail(
    who,
    "location must be a lens or a path array; got: " + repr(at) + ".",
  )
}
