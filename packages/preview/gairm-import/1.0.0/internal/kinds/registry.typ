// One descriptor per schema kind, so the engine, edits and
// introspection ask the registry instead of keeping their own `kind ==`
// ladders. A descriptor holds:
//
//   walk          (schema, value, ctx, recur) => (errors, value, fatal),
//                 or (tail: sub-schema) to hand the value on: what the
//                 engine runs (walk.typ; a leaf's is built from its check
//                 by _leaf-walk, leaf.typ)
//   searchable    find-paths finds it, rather than only walking
//                 through it
//   children      schema => ((segment, sub-schema, label), ..): segments
//                 as schema paths spell them, labels as describe-schema
//                 draws them
//   with-child    (schema, segment, sub) => the node with that child
//                 replaced; none for a leaf, which has no children. An
//                 object comes back as it is; a schema edit rebuilds
//                 it through object() (traverse.typ)
//   suffix        schema => what describe-schema prints on the node's own
//                 row: by default a leaf's kind, and no header (none)
//                 for a node with children
//   inline        describe-schema draws the node's one child on its
//                 parent's row, extended by the child's label (an
//                 array's elements as `name[]`)
//   shorthand     schema => none, or (of, mark): describe-schema draws
//                 the node as `of` with `mark` (a nullable as `X?`)
//   bad-segment   (schema, segment) => the problem (error.typ) a schema path
//                 reports when the segment names no child
//   fields        ((field, required, ok, must), ..): the node's own
//                 fields the walk reads. `ok` judges a present value, or
//                 is none for a sub-schema, which is checked as a schema
//                 of its own; `must` says what the value must be
//   rows          the constraint rows (constraint.typ) its fields may set
//   own           every field the kind reads: `fields`, the rows', and
//                 the others its walk reads (`reads`), so a field only
//                 another kind reads is refused (_foreign-fields)
//   problem       none, or schema => the problem (error.typ) with the
//                 node's fields that `fields` can't state, or none.
//                 structure.typ's _schema-problem reads all three
//
// The constructors that build each kind are listed in catalog.typ: they
// sit above this registry, since their schema check reads its kinds.

#import "leaf.typ": (
  _leaf-walk, _string-check, _number-check, _integer-check, _bool-check,
  _null-check, _any-check, _enum-check,
)
#import "../core/error.typ": (
  _a, _not-in, _problem, _key-names-problem, _key-label,
)
#import "constraint.typ": _constraint-rows
#import "format.typ": _string-kind-check, _string-problem
#import "walk.typ": (
  _array-walk, _object-walk, _union-walk, _not-walk, _if-walk, _kind-label,
  _reported-kind,
)

// Whether object `s` has a schema for the keys it doesn't declare, as a
// map does: the one a schema path enters as "additionalProperties".
#let _is-map(s) = type(s.at("additional", default: none)) == dictionary

// X when `s` is an any-of of exactly X and a null, in either order,
// else none. The null is known by its kind, so an annotated one counts
// too. Any node may be asked.
#let _nullable-member(s) = if (
  s.kind == "union" and not s.exclusive and s.members.len() == 2
) {
  let (a, b) = s.members
  if b.kind == "null" { a } else if a.kind == "null" { b }
}

// `nullable(X)`'s shape: X then the null, read off the node, since
// nullable() sits above this registry.
#let _is-nullable(s) = (
  _nullable-member(s) != none and s.members.last().kind == "null"
)

// The hint for a path that missed a nullable's one step: its schema is
// member 0, named as union messages name it (a union by its members).
#let _nullable-hint(s) = if _is-nullable(s) {
  let m = s.members.first()
  let label = _reported-kind(m)
  if m.kind == "union" { label = label.slice(1, -1) }
  " Insert 0 to step into nullable(" + label + ")."
}

// A conditional's children, as (segment, field): the path segments are
// the JSON Schema keywords, the fields if-of()'s arguments (`else` is a
// Typst keyword).
#let _if-parts = (("if", "cond"), ("then", "then"), ("else", "otherwise"))
// The (segment, field) pairs of the parts `s` has.
#let _if-present(s) = _if-parts.filter(((_, field)) => field in s)

// The problem (error.typ) with a conditional that has neither branch,
// or none: its condition would check nothing. if-of() words it too.
#let _if-problem(s) = if "then" not in s and "otherwise" not in s {
  (
    message: "needs a then or an otherwise branch; got neither. With no branch the condition checks nothing.",
  )
}

// `p` with its argument named as a node's field (`field "format"`), for
// a problem a constructor's check words for its argument.
#let _as-field(p) = if p != none and p.at("arg", default: none) != none {
  (..p, arg: "field " + repr(p.arg))
} else { p }

// The problem (error.typ) with object()'s `required-keys`,
// `dependent-required` and `additional` arguments, or none, which
// object() and the translator word in their own terms. Given the
// declared field names `keys`, a closed object's names must be among
// them: with `additional`, an undeclared name is covered by it. Whether
// a dictionary `additional` is a schema is the schema check's.
#let _object-problem(
  required-keys,
  dependent-required,
  additional,
  keys: none,
) = {
  if not (additional in (none, false, true) or type(additional) == dictionary) {
    return _problem(
      "additional",
      "none, false, true, or a schema dict (built with the constructors)",
      repr(additional),
    )
  }
  // Checked whatever `additional` is: an open object reads the names as
  // keys too, so a non-string one would pass here and fail at validation.
  let p = _key-names-problem(required-keys, "required-keys")
  if p != none { return p }
  if type(dependent-required) != dictionary {
    return _problem(
      "dependent-required",
      "a dictionary of key to array of keys",
      repr(dependent-required),
    )
  }
  for (trigger, dependents) in dependent-required {
    let p = _key-names-problem(
      dependents,
      "dependent-required",
      entry: trigger,
    )
    if p != none { return p }
  }
  if keys == none or additional not in (none, false) { return }
  for (arg, names) in (
    ("required-keys", required-keys),
    (
      "dependent-required",
      dependent-required.pairs().map(((t, ds)) => (t,) + ds).flatten(),
    ),
  ) {
    let unknown = names.filter(k => k not in keys).dedup()
    if unknown != () {
      return _problem(
        arg,
        "only declared fields (the object takes no other keys)",
        unknown.map(repr).join(", "),
      )
    }
  }
}

// A leaf passes its `check`, constraint `family` and `model` (leaf.typ)
// instead of a walk. A walked kind passes its `family` too, when it
// takes constraint rows.
#let _kind(
  searchable: true,
  children: s => (),
  with-child: none,
  suffix: auto,
  inline: false,
  shorthand: s => none,
  bad-segment: (s, seg) => (
    message: "path segment "
      + repr(seg)
      + " cannot enter "
      + _a(s.kind)
      + " schema, which has no children.",
  ),
  walk: none,
  check: none,
  family: none,
  model: v => v,
  fields: (),
  reads: (),
  problem: none,
) = {
  let rows = _constraint-rows.filter(row => row.family == family)
  (
    walk: if check != none { _leaf-walk(check, family, model) } else { walk },
    fields: fields,
    rows: rows,
    own: ("kind",)
      + fields.map(f => f.first())
      + rows.map(row => row.field)
      + reads,
    problem: problem,
    searchable: searchable,
    children: children,
    with-child: with-child,
    suffix: if suffix != auto { suffix } else if with-child == none {
      s => s.kind
    } else { s => none },
    inline: inline,
    shorthand: shorthand,
    bad-segment: bad-segment,
  )
}

#let _kinds = (
  // A format and a pattern are fields on the node. The suffix names
  // the node as messages do (_kind-label), and a pattern gate of its
  // own (JSON Schema format + pattern) says so.
  string: _kind(
    check: _string-kind-check,
    family: "string",
    // Stored, a pattern must be a regex, as string() stores it: `match`
    // with a string is a substring test, so a hand-built or hand-edited
    // string pattern would silently match as literal text. Its message
    // must be a value: a null one would reach the error.
    fields: (
      (
        "pattern",
        false,
        v => type(v) == regex,
        "a regex (string() compiles a string pattern)",
      ),
      ("expected", false, v => type(v) == str, "a string"),
      // A format name is judged by `problem`; this only refuses none.
      ("format", false, v => v != none, "a format name"),
    ),
    problem: s => _as-field(_string-problem(
      format: s.at("format", default: none),
      pattern: s.at("pattern", default: none),
      expected: s.at("expected", default: none),
    )),
    suffix: s => (
      _kind-label(s) + if "pattern" in s { " + pattern" } else { "" }
    ),
  ),
  // The model wraps the string so it splices into markup. Its check
  // reads no pattern or format, so a hand-built one is refused, as any
  // field another kind reads is (_foreign-fields).
  markup: _kind(
    check: _string-check,
    family: "string",
    model: v => [#v],
  ),
  number: _kind(check: _number-check, family: "number"),
  // A number with the integral gate; the number rows apply.
  integer: _kind(
    check: _integer-check,
    family: "number",
  ),
  boolean: _kind(check: _bool-check),
  null: _kind(check: _null-check),
  unknown: _kind(check: _any-check),
  // The values inline, for at-a-glance debugging.
  enum: _kind(
    check: _enum-check,
    fields: (
      (
        "values",
        true,
        v => type(v) == array and v != (),
        "a non-empty array of values",
      ),
    ),
    suffix: _kind-label,
  ),
  // find-paths only walks through the two plain containers: every
  // schema is full of them, so asking for one is more likely a slip
  // than a question.
  array: _kind(
    walk: _array-walk,
    family: "array",
    fields: (("elem", true, none, "a schema"),),
    searchable: false,
    inline: true,
    children: s => (("items", s.elem, "[]"),),
    with-child: (s, _, sub) => (..s, elem: sub),
    // An int is likely an error record's path: a data path, which
    // indexes the elements a schema path enters as "items".
    bad-segment: (s, seg) => _problem(
      "path segment",
      "\"items\" for an array schema",
      repr(seg),
      hint: if type(seg) == int {
        " A data path (an error record's) indexes elements; a schema path enters them all as \"items\"."
      },
    ),
  ),
  // Fields in key order, so every walk is diff-stable whatever order
  // the source declared them in; then the additional schema when it
  // is one. A field literally named "additionalProperties" shadows the
  // additional schema, as in schema paths: reach that through the parent.
  // A required field is labelled `name*`; the additional schema `*`,
  // the display-only key for "any other key".
  object: _kind(
    walk: _object-walk,
    fields: (
      (
        "shape",
        true,
        v => type(v) == dictionary,
        "a dictionary of field name to schema",
      ),
      // Judged by `problem`; these only refuse none.
      ("required-keys", false, v => v != none, "an array of key names"),
      (
        "dependent-required",
        false,
        v => v != none,
        "a dictionary of key to array of keys",
      ),
    ),
    reads: ("additional",),
    // object() reads `additional: false` as none and stores neither, so
    // a node never holds false, which the walk would take for a schema.
    // Any other bad value is worded the same way, not as object()'s
    // argument, which takes false.
    problem: s => if (
      s.at("additional", default: none) not in (none, true)
        and type(s.additional) != dictionary
    ) {
      _problem(
        "field \"additional\"",
        "true or a schema (leave it out to reject other keys)",
        repr(s.additional),
      )
    } else {
      _as-field(_object-problem(
        s.at("required-keys", default: ()),
        s.at("dependent-required", default: (:)),
        s.at("additional", default: none),
        keys: s.shape.keys(),
      ))
    },
    searchable: false,
    children: s => {
      let required = s.at("required-keys", default: ())
      let fields = s
        .shape
        .pairs()
        .sorted(key: p => p.at(0))
        .map(((k, sub)) => (
          k,
          sub,
          _key-label(k) + if k in required { "*" } else { "" },
        ))
      let additional = s.at("additional", default: none)
      // Shadowed by a literal "additionalProperties" field, the
      // additional schema has no path segment (none): describe-schema
      // still draws it, but no path leads to it.
      let seg = if "additionalProperties" in s.shape { none } else {
        "additionalProperties"
      }
      if type(additional) == dictionary {
        fields + ((seg, additional, "*"),)
      } else { fields }
    },
    // As given: a schema edit rebuilds it through object()
    // (traverse.typ), which sits above this registry.
    with-child: (s, seg, sub) => if seg in s.shape {
      // Typst dicts are values: this copy leaves `s` untouched.
      let shape = s.shape
      shape.insert(seg, sub)
      (..s, shape: shape)
    } else { (..s, additional: sub) },
    bad-segment: (s, seg) => if seg == "additionalProperties" {
      (
        message: "path segment \"additionalProperties\" needs the "
          + "object's `additional` to be a schema, got: "
          + repr(s.at("additional", default: none))
          + ".",
        hint: " To set one, schema-update the object: o => (..o, additional: value).",
      )
    } else {
      (
        message: _not-in(
          "path segment " + repr(seg),
          "object shape",
          "Valid keys",
          s.shape.keys(),
        )
          // The steps a JSON Schema user, or a map's, is likely missing.
          + if seg == "properties" {
            " A schema path enters a field by its bare name, with no \"properties\" segment."
          } else if _is-map(s) {
            " \"additionalProperties\" enters the schema for other keys."
          } else { "" },
      )
    },
  ),
  // A member's segment is its index, so a path doesn't say whether it
  // went through any-of or one-of.
  union: _kind(
    walk: _union-walk,
    fields: (
      (
        "members",
        true,
        v => type(v) == array and v != (),
        "a non-empty array of schemas",
      ),
      ("exclusive", true, v => type(v) == bool, "true or false"),
    ),
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
    bad-segment: (s, seg) => _problem(
      "path segment",
      "a member index, 0 to "
        + str(s.members.len() - 1)
        + ", for a union schema",
      repr(seg),
      // A nullable's schema is member 0, a step a path can easily miss.
      hint: if type(seg) == str { _nullable-hint(s) },
    ),
    // The header says which union; the members are listed below it.
    suffix: s => if s.exclusive { "one of" } else { "any of" },
    // `nullable(X)`, an any-of of exactly X then null, draws as `X?`.
    shorthand: s => if _is-nullable(s) { (of: s.members.first(), mark: "?") },
  ),
  "not": _kind(
    walk: _not-walk,
    fields: (("member", true, none, "a schema"),),
    // No header: the member's label, its path segment, says it.
    children: s => (("not", s.member, "not"),),
    with-child: (s, _, sub) => (..s, member: sub),
    bad-segment: (s, seg) => _problem(
      "path segment",
      "\"not\" for a not schema",
      repr(seg),
    ),
  ),
  // The condition, then the branches it has. No header, as for `not`:
  // the labels, the path segments, say what each child is.
  "if": _kind(
    walk: _if-walk,
    // if-of() reads a none branch as no branch, and stores none.
    fields: (
      ("cond", true, none, "a schema"),
      ("then", false, v => v != none, "a schema"),
      ("otherwise", false, v => v != none, "a schema"),
    ),
    problem: _if-problem,
    children: s => _if-present(s).map(((seg, field)) => (
      seg,
      s.at(field),
      seg,
    )),
    with-child: (s, seg, sub) => {
      let (_, field) = _if-parts.find(((k, _)) => k == seg)
      (..s, (field): sub)
    },
    bad-segment: (s, seg) => _problem(
      "path segment",
      "one of "
        + _if-present(s).map(((k, _)) => repr(k)).join(", ")
        + " for an if schema",
      repr(seg),
      hint: {
        let part = _if-parts.find(((k, _)) => k == seg)
        if part != none {
          (
            " To set it, schema-update the if-of: n => (..n, "
              + part.last()
              + ": value)."
          )
        }
      },
    ),
  ),
)

// Per kind, the fields it would ignore, as a set (field → true): those
// another kind reads (an array's `min-length`, a number's `format`), and
// two no kind reads, 0.x's `integer: true` flag and `else`, which
// if-of() stores as `otherwise`. The schema check refuses them; any
// other field is an annotation and rides along.
#let _foreign-fields = {
  let read = ("integer", "else")
  for d in _kinds.values() { read += d.own }
  let read = read.dedup()
  _kinds
    .pairs()
    .map(((kind, d)) => (
      kind,
      read.filter(f => f not in d.own).map(f => (f, true)).to-dict(),
    ))
    .to-dict()
}

// The descriptor of schema node `s`, which the entry points have checked
// (structure.typ's _require-schema), so its kind is registered.
#let _descriptor(s) = _kinds.at(s.kind)
