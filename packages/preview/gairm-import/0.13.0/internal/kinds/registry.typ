// One descriptor per schema kind, so the engine, lens, introspection
// and the strict-schema walkers ask the registry instead of keeping
// their own `kind ==` ladders. A descriptor holds:
//
//   walk          (schema, value, ctx, recur) => (errors, value, fatal):
//                 what the engine runs (structure.typ; a leaf's is built
//                 from its check by _leaf-walk, leaf.typ)
//   searchable    paths-of-kind finds it, rather than only walking
//                 through it
//   children      schema => ((segment, sub-schema, label), ..): segments
//                 as lens paths spell them, labels as describe-schema
//                 draws them
//   with-child    (schema, segment, sub) => the node with that child
//                 replaced; none for a leaf, which has no children
//   suffix        schema => what describe-schema prints on the node's own
//                 row: by default a leaf's kind, and no header (none)
//                 for a node with children
//   inline        describe-schema draws the node's one child on its
//                 parent's row, extended by the child's label (an
//                 array's elements as `name[]`)
//   shorthand     schema => none, or (of, mark): describe-schema draws
//                 the node as `of` with `mark` (a nullable as `X?`)
//   bad-segment   (schema, segment) => what a lens says when the segment
//                 names no child
//   constructors  the public functions that build this kind

#import "leaf.typ" as _leaf-mod
#import "leaf.typ": (
  number, integer, enum-of, const-of, _leaf-walk, _string-check, _number-check,
  _integer-check, _bool-check, _null-check, _any-check, _enum-check,
)
#import "../core/error.typ": _internal, _not-in
#import "format.typ" as _format-mod
#import "format.typ": string, pattern-string, _string-kind-check
#import "structure.typ" as _structure-mod
#import "structure.typ": (
  array-of, object, map, any-of, one-of, not-of, if-of, nullable, _array-walk,
  _object-walk, _union-walk, _not-walk, _if-walk, _object-with, _schema-kinds,
  _node, _kind-label,
)

// A conditional's children, as (segment, field): the lens segments are
// the JSON Schema keywords, the fields if-of()'s arguments (`else` is a
// Typst keyword).
#let _if-parts = (("if", "cond"), ("then", "then"), ("else", "otherwise"))
// The (segment, field) pairs of the parts `s` has.
#let _if-present(s) = _if-parts.filter(((_, field)) => field in s)

// A leaf passes its `check`, constraint `family` and `model` (leaf.typ)
// instead of a walk.
#let _kind(
  searchable: true,
  children: s => (),
  with-child: none,
  suffix: auto,
  inline: false,
  shorthand: s => none,
  bad-segment: (s, seg) => (
    "lens cannot descend into a leaf schema (kind="
      + repr(s.kind)
      + ") with segment "
      + repr(seg)
      + "."
  ),
  constructors: (),
  walk: none,
  check: none,
  family: none,
  model: v => v,
) = (
  walk: if check != none { _leaf-walk(check, family, model) } else { walk },
  searchable: searchable,
  children: children,
  with-child: with-child,
  suffix: if suffix != auto { suffix } else if with-child == none {
    s => s.kind
  } else { s => none },
  inline: inline,
  shorthand: shorthand,
  bad-segment: bad-segment,
  constructors: constructors,
)

#let _kinds = (
  // A format and a pattern are fields on the node. The suffix names
  // the node as messages do (_kind-label), so a hand-built node of an
  // old name (_kind-aliases) draws as the string it is, and a pattern
  // gate of its own (JSON Schema format + pattern) says so.
  string: _kind(
    check: _string-kind-check,
    family: "string",
    suffix: s => (
      _kind-label(s) + if "pattern" in s { " + pattern" } else { "" }
    ),
    constructors: (string, pattern-string),
  ),
  // The model wraps the string so it splices into markup.
  content: _kind(check: _string-check, family: "string", model: v => [#v]),
  number: _kind(check: _number-check, family: "number", constructors: (
    number,
  )),
  // A number with the integral gate; the number rows apply.
  integer: _kind(
    check: _integer-check,
    family: "number",
    constructors: (integer,),
  ),
  bool: _kind(check: _bool-check),
  null: _kind(check: _null-check),
  any: _kind(check: _any-check),
  // The values inline, for at-a-glance debugging.
  enum: _kind(
    check: _enum-check,
    suffix: s => "enum (" + s.values.map(repr).join(", ") + ")",
    constructors: (enum-of, const-of),
  ),
  // paths-of-kind only walks through the two plain containers: every
  // schema is full of them, so asking for one is more likely a slip
  // than a question.
  array: _kind(
    walk: _array-walk,
    searchable: false,
    inline: true,
    children: s => (("items", s.elem, "[]"),),
    with-child: (s, _, sub) => (..s, elem: sub),
    bad-segment: (s, seg) => (
      "lens segment for an array schema must be \"items\", got "
        + repr(seg)
        + "."
    ),
    constructors: (array-of,),
  ),
  // Fields in key order, so every walk is diff-stable whatever order
  // the source declared them in; then the additional schema when it
  // is one. A field literally named "additionalProperties" shadows the
  // additional schema, as in lens paths: reach that through the parent.
  // A required field is labelled `name*`; the additional schema `*`,
  // the display-only key for "any other key".
  object: _kind(
    walk: _object-walk,
    searchable: false,
    children: s => {
      let required = s.at("required-keys", default: ())
      let fields = s
        .shape
        .pairs()
        .sorted(key: p => p.at(0))
        .map(((k, sub)) => (k, sub, if k in required { k + "*" } else { k }))
      let additional = s.at("additional", default: none)
      if type(additional) == dictionary {
        fields + (("additionalProperties", additional, "*"),)
      } else { fields }
    },
    // Through object(), so a lens write keeps its invariants.
    with-child: (s, seg, sub) => if seg in s.shape {
      // Typst dicts are values: this copy leaves `s` untouched.
      let shape = s.shape
      shape.insert(seg, sub)
      _object-with(s, shape: shape)
    } else { _object-with(s, additional: sub) },
    bad-segment: (s, seg) => if seg == "additionalProperties" {
      (
        "lens segment \"additionalProperties\" requires the object's "
          + "`additional` field to be a schema dict, got: "
          + repr(s.at("additional", default: none))
          + "."
      )
    } else {
      _not-in(
        "lens path segment " + repr(seg),
        "object shape",
        "Valid keys",
        s.shape.keys(),
      )
    },
    constructors: (object, map),
  ),
  // A member's segment is its index, so a path doesn't say whether it
  // went through any-of or one-of.
  union: _kind(
    walk: _union-walk,
    children: s => s
      .members
      .enumerate()
      .map(((i, m)) => (i, m, "[" + str(i) + "]")),
    with-child: (s, i, sub) => {
      // Typst arrays are values: this copy leaves `s` untouched.
      let members = s.members
      members.at(i) = sub
      (..s, members: members)
    },
    bad-segment: (s, seg) => (
      "lens segment for a union schema must be a member index, 0 to "
        + str(s.members.len() - 1)
        + ", got "
        + repr(seg)
        + "."
    ),
    // The header says which union; the members are listed below it.
    suffix: s => if s.exclusive { "one of" } else { "any of" },
    // `nullable(X)`, an any-of of exactly X then null, draws as `X?`.
    shorthand: s => if s == nullable(s.members.first()) {
      (of: s.members.first(), mark: "?")
    },
    constructors: (any-of, one-of, nullable),
  ),
  "not": _kind(
    walk: _not-walk,
    // No header: the member's label, its lens segment, says it.
    children: s => (("not", s.member, "not"),),
    with-child: (s, _, sub) => (..s, member: sub),
    bad-segment: (s, seg) => (
      "lens segment for a not schema must be \"not\", got " + repr(seg) + "."
    ),
    constructors: (not-of,),
  ),
  // The condition, then the branches it has. No header, as for `not`:
  // the labels, the lens segments, say what each child is.
  "if": _kind(
    walk: _if-walk,
    children: s => _if-present(s).map(((seg, field)) => (
      seg,
      s.at(field),
      seg,
    )),
    with-child: (s, seg, sub) => {
      let (_, field) = _if-parts.find(((k, _)) => k == seg)
      (..s, (field): sub)
    },
    bad-segment: (s, seg) => (
      "lens segment for an if schema must be one of "
        + _if-present(s).map(((k, _)) => repr(k)).join(", ")
        + ", got "
        + repr(seg)
        + "."
    ),
    constructors: (if-of,),
  ),
)

// Every exported constant names a registered kind, and every exported
// constructor is listed by some descriptor, so a new kind can't miss
// its descriptor. `dictionary(module)` lists a module's names.
#let _check-coverage(kinds, modules) = {
  for mod in modules {
    for (name, v) in dictionary(mod) {
      if name.starts-with("_") { continue }
      if type(v) == dictionary {
        _internal(
          v.at("kind", default: none) in kinds,
          name
            + " has kind "
            + repr(v.at("kind", default: none))
            + ", which has no descriptor.",
        )
      } else if type(v) == function {
        _internal(
          kinds.values().any(d => v in d.constructors),
          "constructor " + name + " is in no descriptor's constructors.",
        )
      }
    }
  }
}

#_check-coverage(_kinds, (_leaf-mod, _format-mod, _structure-mod))

// The constructors' schema check (_require-schema) knows the kinds by
// name, since it sits below this registry: the two lists must agree.
#let _check-kind-names(kinds, names) = {
  _internal(
    kinds.keys().sorted() == names.sorted(),
    "the registered kinds "
      + repr(kinds.keys().sorted())
      + " differ from structure.typ's _schema-kinds "
      + repr(names.sorted())
      + ".",
  )
}

#_check-kind-names(_kinds, _schema-kinds)

// A node of a kind the registry doesn't know (hand-built) behaves as a
// leaf, as it did before the registry. An old kind name finds its
// current descriptor.
#let _descriptor(s) = _kinds.at(_node(s).kind, default: _kind())
