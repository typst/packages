// One schema traversal, through the kind descriptors, shared by the
// edits and introspection. Paths are schema paths: a field name, "items" for an
// array's elements, "additionalProperties" for an object's additional
// schema, an int index for a union member, "not" for a `not` member,
// "if", "then" and "else" for a conditional's condition and branches.

#import "../core/error.typ": _fail, _array-problem
#import "registry.typ": _descriptor
#import "structure.typ": _rebuilt, _has-kind

#let _children(s) = (_descriptor(s).children)(s)

// `seg` as a node of kind `kind` reads it. An object's fields are named
// by strings, so a non-negative int names the field it spells, as a
// JSON Pointer reads `/2024` as an int; an object has no int children
// to confuse it with. A negative int is no pointer's, and stays a bad
// segment. Given the kind alone, not the node, which a call would hash.
#let _segment(kind, seg) = if (
  type(seg) == int and seg >= 0 and kind == "object"
) {
  str(seg)
} else { seg }

// Past that, segments match by type as well as value, so `1.0` or `"0"`
// names no union member. A bad segment panics naming `who`, the public
// function that followed the path.
#let _child(s, seg, who) = {
  let seg = _segment(s.kind, seg)
  // A child with no segment (a shadowed additional schema) is never hit,
  // not even by a `none` segment.
  let hit = _children(s).find(((k, ..)) => (
    k != none and type(k) == type(seg) and k == seg
  ))
  if hit == none { _fail(who, (_descriptor(s).bad-segment)(s, seg)) }
  hit.at(1)
}

#let _get-at(s, path, who) = path.fold(s, (n, seg) => _child(n, seg, who))

// _child runs on the way down, before the node's writer is looked at,
// so a bad segment panics the same way from a put as from a get, a leaf
// (which has no writer) included. Every object on the way back up is
// rebuilt through object(), so a write keeps its invariants, and a
// panic there names `who`. Two loops, not a recursion, so an edit
// reaches as deep as a walk does.
#let _set-at(s, path, sub, who) = {
  let trail = ()
  let node = s
  for seg in path {
    let seg = _segment(node.kind, seg)
    trail.push((node, seg))
    node = _child(node, seg, who)
  }
  let out = sub
  for (node, seg) in trail.rev() {
    out = _rebuilt((_descriptor(node).with-child)(node, seg, out), who)
  }
  out
}

// Every (path, node) pair, pre-order, of the nodes a path reaches: a
// child with no segment (a shadowed additional schema) is skipped.
#let _nodes(s, path: ()) = {
  let out = ((path, s),)
  for (seg, sub, _) in _children(s) {
    if seg != none { out += _nodes(sub, path: path + (seg,)) }
  }
  out
}

// The path of every node in `s` that `keep` holds for, pre-order.
#let _paths-where(s, keep) = (
  _nodes(s).filter(((_, n)) => keep(n)).map(((p, _)) => p)
)

// A schema path: where the edit and introspection functions point, as an
// array of segments. Never a schema node, which is a dictionary.
#let _is-path(x) = type(x) == array

// `at`, checked as a schema path. Panics, naming `who`, on anything
// else: a schema by what it is rather than its repr, which can run to
// pages, with the caller's `hint`, and a string with its one-key
// spelling.
#let _schema-path(at, who, hint: none) = {
  if _is-path(at) { return at }
  let p = _array-problem(at, "path", "an array of path segments", "key")
  if _has-kind(at) {
    p.got = "a schema"
    p.hint = hint
  }
  _fail(who, p)
}
