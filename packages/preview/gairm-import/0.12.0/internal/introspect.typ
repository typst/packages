// Schema-shape inspection helpers. Debugging an extension schema
// otherwise means `repr(schema)` (noisy dict dump) or hand-walking
// `.shape` accessors. Introspection here stays read-only; edits live
// in lens.typ.
//
// Path tuples use lens-compatible segments — `"items"` for array
// descent, `"additionalProperties"` for the additional schema, an
// index for a union member, `"not"` for a `not` member, `"if"`,
// `"then"` and `"else"` for a conditional's condition and branches — so
// `paths-of-kind` output round-trips through `lens` and `lens-get`.
// The `[]` suffix and the `*` row in `describe-schema` are
// display-only (`*` is the conventional shorthand for "any key").

#import "core/error.typ": _bail
#import "kinds/registry.typ": _kinds, _descriptor, _node
#import "kinds/traverse.typ": _children, _get-at, _paths-where, _location-path
#import "kinds/constraint.typ": _constraint-rows
#import "kinds/format.typ": pattern-string

// The kinds paths-of-kind can look for: every kind but the plain
// containers. A union, `not` or conditional is found as a node, and
// its children are searched too.
#let _searchable-kinds = _kinds.keys().filter(k => _kinds.at(k).searchable)

#let _leaf(s) = _descriptor(s).with-child == none
#let _suffix(s) = (_descriptor(s).suffix)(s)

#let _pad-right(s, width) = s + " " * (width - s.len())

// What a node sets beyond its kind, in one shared list: the `integer`
// flag a hand-built number node may still carry, then every constraint row it sets, in row order, by the row's
// field name (as the node and the error's `expected` spell it). A
// flag row shows by name alone.
#let _extras(s) = {
  let out = if s.at("integer", default: false) == true { ("integer",) } else {
    ()
  }
  for row in _constraint-rows {
    let v = s.at(row.field, default: none)
    if v == none or v == false { continue }
    out.push(if v == true { row.field } else { row.field + " " + str(v) })
  }
  out
}
#let _paren(s) = {
  let extras = _extras(s)
  if extras == () { "" } else { " (" + extras.join(", ") + ")" }
}

// A node its descriptor draws as another node plus a mark
// (`nullable(X)` as `X?`), as (node, mark); any other node as itself
// with no mark.
#let _shown(s) = {
  let short = (_descriptor(s).shorthand)(s)
  if short == none { (s, "") } else { (short.of, short.mark) }
}

// A leaf's text: its kind, its mark, then what it sets beyond it.
#let _text(s, mark) = _suffix(s) + mark + _paren(s)

// The tree layout is where an inline kind (an array) differs from the
// rest: its one child extends its parent's row with the child's label
// (`[]`, then the array's own constraints), while every other child
// gets a row of its own.
#let _inline(s) = _descriptor(s).inline

// One child row. A leaf, or an array of leaves, is inline after its
// label, padded to the kind column; anything else gets a header line,
// with its own header text (`any of`) when it has one, and its own
// block below it. An array's constraints follow its element's text
// inline, and its label otherwise, so they don't widen the column.
// A mark follows a leaf's kind or a block's header, and the label of
// a node drawn by its label alone (an object, an array, a `not`).
#let _row(label, sub) = {
  let (sub, mark) = _shown(sub)
  let (label, sub, mark, after) = if _inline(sub) {
    let (_, elem, elem-label) = _children(sub).first()
    let (elem, elem-mark) = _shown(elem)
    (label + mark + elem-label, elem, elem-mark, _paren(sub))
  } else { (label, sub, mark, "") }
  if _leaf(sub) { return (label: label, text: _text(sub, mark) + after) }
  let head = _suffix(sub)
  if head == none {
    (label: label + mark + after, head: none, block: sub)
  } else { (label: label + after, head: head + mark, block: sub) }
}

// Recursive pretty-printer. `indent` prefixes every line at this
// depth; nested blocks add two more spaces. A node's header text is
// drawn by its parent's row; a node `alone` (the root), a leaf or an
// inline node draws its own, as a row with no label and no column.
#let _describe(schema, indent, alone: false) = {
  if alone or _leaf(schema) or _inline(schema) {
    let r = _row("", schema)
    let line = (
      r.label
        + if "text" in r { " " + r.text } else if r.head != none {
          " " + r.head
        }
    ).trim(at: start)
    if "text" in r { return indent + line }
    if line == "" { return _describe(r.block, indent) }
    return indent + line + ":\n" + _describe(r.block, indent + "  ")
  }
  // Each child under its label: a field name (`*` when required), `*`
  // for an object's additional schema, `[i]` for a union member, `not`
  // for a `not` member, `if`, `then` and `else` for a conditional's
  // condition and branches. `additional: true` shows as `* any`.
  let rows = _children(schema).map(((_, sub, label)) => _row(label, sub))
  if schema.at("additional", default: none) == true {
    rows.push((label: "*", text: "any"))
  }
  let aligned = rows.filter(r => "text" in r or r.head != none)
  let col = if aligned == () { 0 } else {
    calc.max(..aligned.map(r => r.label.len())) + 2
  }
  let lines = rows.map(r => if "text" in r {
    indent + _pad-right(r.label, col) + r.text
  } else {
    let head = if r.head == none { r.label } else {
      _pad-right(r.label, col) + r.head
    }
    indent + head + ":\n" + _describe(r.block, indent + "  ")
  })
  // An object's dependent-required, one trigger a line, after its
  // fields.
  for (trigger, deps) in schema
    .at("dependent-required", default: (:))
    .pairs()
    .sorted(key: p => p.at(0)) {
    lines.push(indent + trigger + " → " + deps.join(", "))
  }
  lines.join("\n", default: "")
}

/// Draws a schema as an indented tree, one line per field with its kind
/// and constraints. Keys are sorted, required fields are marked `*`,
/// arrays are suffixed `[]`, `*` stands for any other key, union
/// members are listed as `[0]`, `[1]`, …, a `not` member as `not`, a
/// conditional's condition and branches as `if`, `then` and `else`, and
/// a dependent-required entry shows as `trigger → dependents`.
///
/// - schema (dictionary): The schema to draw.
/// -> str
#let describe-schema(schema) = _describe(schema, "", alone: true)

// What paths-of-kind looks for, as a node: a schema node as given, a
// constructor as the bare node of the kind it builds, a kind name as
// the bare node it names. Each is read through _node, so an old kind
// name (_kind-aliases) stands for its current node: "date-string" for
// `(kind: "string", format: "date")`. A kind name string is
// deprecated, for removal in the next major.
#let _query(kind) = _node(
  if type(kind) == dictionary and "kind" in kind { kind } else if (
    type(kind) == function
  ) {
    let hit = _kinds.pairs().find(((_, d)) => d.constructors.contains(kind))
    (kind: if hit != none { hit.at(0) } else { kind })
  } else { (kind: kind) },
)

// A node matches a query when it is of the query's kind and has every
// other field the query sets, with the same value. So `string()` finds
// every string, `string(format: "date")` the date strings, with a
// pattern or without, and `number(minimum: 0)` the numbers whose
// minimum is 0.
#let _matches(query, node) = {
  let node = _node(node)
  (
    node.kind == query.kind
      and query
        .pairs()
        .all(((k, v)) => k == "kind" or (k in node and node.at(k) == v))
  )
}

// Deprecated, for removal at 1.0: pattern-string, the constructor or
// its old kind name (as a string or a node's kind), finds every string
// with a pattern, whatever the pattern.
#let _any-patterned(kind) = (
  kind == pattern-string
    or kind == "pattern-string"
    or type(kind) == dictionary
      and kind.at("kind", default: none) == "pattern-string"
)

// Container kinds (`object`, `array`) are deliberately rejected — the
// walker descends through them, and a search for one is more likely a
// typo for a leaf than a question.
/// Lists the lens path of every node in `schema` that has the given
/// kind, including inside union and `not` members and a conditional's
/// condition and branches. The paths work wherever a location does.
/// Panics for `object` and `array`, which the search walks through, and
/// for kinds it does not know.
///
/// - schema (dictionary): The schema to search.
/// - kind (dictionary, function, str): The kind to find: a schema node
///   such as `string(format: "date")`, or a constructor such as
///   `string`, `enum-of`, `const-of`, `any-of`, `one-of`, `not-of` or
///   `if-of`. A node finds the nodes of its kind that also have every
///   field it sets, with the same value: `string()` finds every string,
///   `string(format: "date")` only the date strings, `number()` numbers
///   but not integers, and `number(minimum: 0)` only the numbers with
///   minimum 0. A constructor finds every node of the kind it builds. A
///   kind name as a `str` still works but is deprecated.
/// -> array
#let paths-of-kind(schema, kind) = {
  let q = _query(kind)
  if q.kind not in _searchable-kinds {
    _bail(
      "paths-of-kind",
      "kind "
        + repr(kind)
        + " is not a recognised leaf kind. Pass a leaf schema "
        + "(e.g. string(format: \"date\")), a constructor (e.g. enum-of), "
        + "or one of: "
        + _searchable-kinds.join(", ")
        + ".",
    )
  }
  if _any-patterned(kind) {
    return _paths-where(schema, n => (
      _node(n).kind == "string" and "pattern" in n // kind-check: deprecated, #186
    ))
  }
  _paths-where(schema, n => _matches(q, n))
}

// Same as `lens-get(schema, at).kind` — keeps the common
// "what kind is at X" debugging step a single call.
/// Deprecated: use `lens-get(schema, at).kind` instead. Kept until 1.0.
///
/// The kind name of the schema node at `at`, such as `"string"` or
/// `"object"`. Panics if the path does not exist.
///
/// - schema (dictionary): The schema to look in.
/// - at (dictionary, array): Where: a lens or a path array.
/// -> str
#let kind-at(schema, at) = {
  _get-at(
    schema,
    _location-path(at, "kind-at"),
  ).kind
}
