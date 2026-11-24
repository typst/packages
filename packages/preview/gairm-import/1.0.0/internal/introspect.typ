// Schema-shape inspection helpers. Debugging a schema otherwise means
// `repr(schema)` (noisy dict dump) or hand-walking `.shape` accessors.
// Introspection here stays read-only; edits live in edit.typ.
//
// Paths are schema paths — `"items"` for array descent,
// `"additionalProperties"` for the additional schema, an index for a
// union member, `"not"` for a `not` member, `"if"`, `"then"` and
// `"else"` for a conditional's condition and branches — so
// `find-paths` output round-trips through `schema-get`.
// The `[]` suffix and the `*` row in `describe-schema` are
// display-only (`*` is the conventional shorthand for "any key").

#import "core/error.typ": _a, _bail, _fail, _problem, _key-label, _num
#import "kinds/registry.typ": _kinds, _descriptor
#import "kinds/catalog.typ": _constructor, _constructors
#import "kinds/structure.typ": _require-schema, _is-object, _has-kind
#import "kinds/walk.typ": _kind-label
#import "kinds/traverse.typ": _children, _paths-where
#import "kinds/constraint.typ": _constraint-rows

// The kinds find-paths can look for: every kind but the plain
// containers. A union, `not` or conditional is found as a node, and
// its children are searched too.
#let _searchable-kinds = _kinds.keys().filter(k => _kinds.at(k).searchable)

#let _leaf(s) = _descriptor(s).with-child == none
// An object that takes only `{}`: no fields and no other keys. It has
// no rows to draw, so it is drawn on its label's row, as a leaf is.
#let _empty(s) = (
  _is-object(s) and s.shape == (:) and s.at("additional", default: none) == none
)
#let _suffix(s) = (_descriptor(s).suffix)(s)

// Widths count grapheme clusters, as a reader sees them: `seán` is four
// wide, not five bytes.
#let _width(s) = s.clusters().len()
#let _pad-right(s, width) = s + " " * (width - _width(s))

// What a node sets beyond its kind, in one shared list: every
// constraint row it sets, in row order, by the row's field name (as the
// node and the error's `expected` spell it). A flag row shows by name
// alone.
#let _extras(s) = {
  let out = ()
  for row in _constraint-rows {
    let v = s.at(row.field, default: none)
    if v == none or v == false { continue }
    out.push(if v == true { row.field } else { row.field + " " + _num(v) })
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
  if short == none { return (s, "") }
  // A shorthand of a shorthand (`nullable(nullable(X))`) draws as one:
  // `X?`, not a union header marked `?`.
  let (of, mark) = _shown(short.of)
  (of, if mark == "" { short.mark } else { mark })
}

// A leaf's text: its kind, its mark, then what it sets beyond it.
#let _text(s, mark) = (
  (if _empty(s) { "empty object" } else { _suffix(s) }) + mark + _paren(s)
)

// The tree layout is where an inline kind (an array) differs from the
// rest: its one child extends its parent's row with the child's label
// (`[]`, then the array's own constraints), and an inline child of that
// extends it again (`[][]`), while every other child gets a row of its
// own.
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
  let (label, after) = (label, "")
  while _inline(sub) {
    let (_, elem, elem-label) = _children(sub).first()
    label += mark + elem-label
    after += _paren(sub)
    (sub, mark) = _shown(elem)
  }
  if _leaf(sub) or _empty(sub) {
    return (label: label, text: _text(sub, mark) + after)
  }
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
  if alone or _leaf(schema) or _empty(schema) or _inline(schema) {
    let r = _row("", schema)
    let line = (
      r.label
        + if "text" in r { " " + r.text } else if r.head != none {
          " " + r.head
        }
    ).trim(at: start)
    // A root drawn by its mark alone (`nullable(object(..))`) is named by
    // its kind, `object?`, so the mark has something to follow.
    if line.starts-with("?") { line = _shown(schema).first().kind + line }
    if "text" in r { return indent + line }
    if line == "" { return _describe(r.block, indent) }
    return indent + line + ":\n" + _describe(r.block, indent + "  ")
  }
  // Each child under its label: a field name (`*` when required), `*`
  // for an object's additional schema, `[i]` for a union member, `not`
  // for a `not` member, `if`, `then` and `else` for a conditional's
  // condition and branches. `additional: true` shows as `* unknown`.
  let children = _children(schema)
  let rows = ()
  if _is-object(schema) {
    // A required key the shape doesn't declare is checked against the
    // additional schema, so it is drawn with that schema, among the
    // fields in key order; the additional schema's own row comes last.
    let additional = schema.at("additional", default: none)
    // A shadowed additional schema's segment is none, and is no field.
    let fields = children.filter(((k, ..)) => k != none and k in schema.shape)
    let undeclared = schema
      .at("required-keys", default: ())
      .filter(k => k not in schema.shape)
      .map(k => (k, additional, _key-label(k) + "*"))
    for (k, sub, label) in (fields + undeclared).sorted(key: c => c.at(0)) {
      rows.push(if sub == true { (label: label, text: "unknown") } else {
        _row(label, sub)
      })
    }
    for (_, sub, label) in children.filter(((k, ..)) => (
      k == none or k not in schema.shape
    )) {
      rows.push(_row(label, sub))
    }
    if additional == true { rows.push((label: "*", text: "unknown")) }
  } else {
    for (_, sub, label) in children { rows.push(_row(label, sub)) }
  }
  let aligned = rows.filter(r => "text" in r or r.head != none)
  let col = if aligned == () { 0 } else {
    calc.max(..aligned.map(r => _width(r.label))) + 2
  }
  // A loop, not a map: a closure would cost a call frame per level,
  // and a nested schema would overflow before validate does.
  let lines = ()
  for r in rows {
    lines.push(if "text" in r {
      indent + _pad-right(r.label, col) + r.text
    } else {
      let head = if r.head == none { r.label } else {
        _pad-right(r.label, col) + r.head
      }
      indent + head + ":\n" + _describe(r.block, indent + "  ")
    })
  }
  // An object's dependent-required, one trigger a line, after its
  // fields.
  for (trigger, deps) in schema
    .at("dependent-required", default: (:))
    .pairs()
    .sorted(key: p => p.at(0)) {
    lines.push(
      indent + _key-label(trigger) + " → " + deps.map(_key-label).join(", "),
    )
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
#let describe-schema(schema) = {
  _require-schema(schema, "describe-schema schema")
  _describe(schema, "", alone: true)
}

// A node matches a schema-node query when it is of the query's kind and
// has every other field the query sets, with the same value. So
// `string()` finds every string, `string(format: "date")` the date
// strings, with a pattern or without, and `number(minimum: 0)` the
// numbers whose minimum is 0. string() stores an `expected` only when
// given, so `string(pattern: p)` finds every string with pattern `p`,
// whatever its message says.
#let _matches(query, node) = (
  query.pairs().all(((k, v)) => k == "kind" or (k in node and node.at(k) == v))
)

// What find-paths looks for, as (kind, test, name): a schema node,
// checked as a schema before it gets here, finds the nodes of its kind
// it _matches, a constructor the nodes its test holds for (catalog.typ),
// and anything else is of no kind, which no search takes. `name` says
// what the query was, for the panic: a whole node's repr can run to
// pages.
#let _query(query) = if type(query) == dictionary {
  (
    kind: query.kind,
    test: n => _matches(query, n),
    name: _a(_kind-label(query)) + " schema",
  )
} else if type(query) == function {
  let c = _constructor(query)
  if c == none { (kind: none, name: repr(query)) } else {
    (kind: c.kind, test: c.test, name: repr(query))
  }
} else { (kind: none, name: repr(query)) }

/// Lists the schema path of every node in `schema` that matches `query`,
/// including inside union and `not` members and a conditional's
/// condition and branches. The paths work wherever a schema path does.
/// Panics for `object`, `map` and `array-of`, which the search walks
/// through, and for anything that is not a schema or a constructor.
///
/// - schema (dictionary): The schema to search.
/// - query (dictionary, function): What to find: a schema node such as
///   `string(format: "date")`, or a constructor such as `string`,
///   `enum-of`, `any-of` or `if-of`. A node finds the nodes of its kind
///   that also have every field it sets, with the same value:
///   `string()` finds every string, `string(format: "date")` only the
///   date strings, and `number()` numbers but not integers. A
///   constructor finds the nodes it builds: `const-of` the single-value
///   enums, `any-of` the inclusive unions (a nullable is one), `one-of`
///   the exclusive ones, `nullable` the nullable ones, and the rest every
///   node of their kind.
/// -> array
#let find-paths(schema, query) = {
  if not _has-kind(schema) and _has-kind(query) {
    _bail(
      "find-paths",
      "takes the schema first, then the query: find-paths(schema, query).",
    )
  }
  _require-schema(schema, "find-paths schema")
  // A node query is a schema like any other: a malformed one fails here,
  // in the package's words.
  if type(query) == dictionary {
    _require-schema(query, "find-paths query")
  }
  let q = _query(query)
  // Container kinds (`object`, `array`) are rejected: the search
  // descends through them, and a search for one is more likely a slip
  // than a question.
  if q.kind not in _searchable-kinds {
    _fail("find-paths", _problem(
      "query",
      "a schema node or a constructor of a kind it can find ("
        + _searchable-kinds
          .map(k => _constructors.at(k).map(((c, _)) => repr(c)))
          .flatten()
          .join(", ")
        + "); object, map and array-of are walked through, not searched for",
      q.name,
    ))
  }
  _paths-where(schema, n => n.kind == q.kind and (q.test)(n))
}
