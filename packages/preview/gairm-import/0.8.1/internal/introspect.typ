// Schema-shape inspection helpers. Debugging an extension schema
// otherwise means `repr(schema)` (noisy dict dump) or hand-walking
// `.shape` accessors. Introspection here stays read-only; edits live
// in lens.typ.
//
// Path tuples use lens-compatible segments — `"items"` for array
// descent, `"additionalProperties"` for the additional schema — so
// `paths-of-kind` output round-trips through `lens` and `lens-get`.
// The `[]` suffix and the `*` row in `describe-schema` are
// display-only (`*` is the conventional shorthand for "any key").

#import "lens.typ": lens, lens-get

#let _leaf-kinds = (
  "str", "content", "number", "bool", "null",
  "date-string", "datetime-string", "uri-string", "email-string", "pattern-string",
  "enum",
)

// Alphabetical pair ordering — diff-stable output regardless of
// dictionary insertion order in the source.
#let _sorted-pairs(d) = d.pairs().sorted(key: p => p.at(0))

// enum nodes carry their values inline for at-a-glance debugging;
// every other kind name speaks for itself.
#let _leaf-suffix(sub) = if sub.kind == "enum" {
  "enum (" + sub.values.map(repr).join(", ") + ")"
} else {
  sub.kind
}

#let _pad-right(s, width) = s + " " * (width - s.len())

// Returns the column-key (with `[]` suffix for array-of-leaf) for an
// inline-rendered child, or `none` for children that emit their own
// header line and don't contribute to the kind-column width.
#let _column-key(key, sub) = {
  if sub.kind == "object" { none }
  else if sub.kind == "array" and sub.elem.kind in ("object", "array") { none }
  else if sub.kind == "array" { key + "[]" }
  else { key }
}

// One line for (key, sub) when sub is a leaf or array-of-leaf;
// `none` for object / array-of-object/array since those emit their
// own header line. Pulled out so the additional-key `"*"` path can
// share the same rendering.
#let _render-leaf-line(key, sub, indent, col) = {
  if sub.kind == "array" and sub.elem.kind not in ("object", "array") {
    indent + _pad-right(key + "[]", col) + _leaf-suffix(sub.elem)
  } else if sub.kind not in ("object", "array") {
    indent + _pad-right(key, col) + _leaf-suffix(sub)
  } else {
    none
  }
}

// Recursive pretty-printer. `indent` prefixes every line at this
// depth; nested children add two more spaces. `additional` is
// rendered after the shape pairs, with key "*" (lens-compatible).
#let _describe(schema, indent) = {
  if schema.kind == "object" {
    let pairs = _sorted-pairs(schema.shape)
    let additional = schema.at("additional", default: none)
    // `*` is the display-only key shown for the additional-schema row
    // (lens-addressing uses "additionalProperties"). `(kind: "any")`
    // is a display-only sentinel for `additional: true` — not a real
    // engine kind, recognised by the leaf branch below and nowhere
    // else.
    let additional-pair = if additional == true {
      ("*", (kind: "any"))
    } else if type(additional) == dictionary {
      ("*", additional)
    } else {
      none
    }
    let all-pairs = if additional-pair != none { pairs + (additional-pair,) } else { pairs }
    let column-keys = all-pairs.map(((k, s)) => _column-key(k, s)).filter(k => k != none)
    let col = if column-keys.len() == 0 { 0 } else {
      calc.max(..column-keys.map(k => k.len())) + 2
    }
    let lines = all-pairs.map(((key, sub)) => {
      if sub.kind == "object" {
        indent + key + ":\n" + _describe(sub, indent + "  ")
      } else if sub.kind == "array" and sub.elem.kind in ("object", "array") {
        indent + key + "[]:\n" + _describe(sub.elem, indent + "  ")
      } else if sub.kind == "any" {
        // `additional: true` — print as a synthetic "any" leaf.
        indent + _pad-right(key, col) + "any"
      } else {
        _render-leaf-line(key, sub, indent, col)
      }
    })
    if lines.len() == 0 { "" } else { lines.join("\n") }
  } else if schema.kind == "array" {
    if schema.elem.kind in ("object", "array") {
      indent + "[]:\n" + _describe(schema.elem, indent + "  ")
    } else {
      indent + "[] " + _leaf-suffix(schema.elem)
    }
  } else {
    indent + _leaf-suffix(schema)
  }
}

#let describe-schema(schema) = _describe(schema, "")

// Collect every path whose terminal kind matches `kind-name`.
// Walks `additional` when it's a schema dict (typed extras), using
// the `"*"` segment so the path round-trips through lens.
#let _walk-paths(schema, path, kind-name) = {
  if schema.kind == "object" {
    let shape-paths = _sorted-pairs(schema.shape)
      .map(((key, sub)) => _walk-paths(sub, path + (key,), kind-name))
      .fold((), (acc, ps) => acc + ps)
    let additional = schema.at("additional", default: none)
    let additional-paths = if type(additional) == dictionary {
      _walk-paths(additional, path + ("additionalProperties",), kind-name)
    } else { () }
    shape-paths + additional-paths
  } else if schema.kind == "array" {
    _walk-paths(schema.elem, path + ("items",), kind-name)
  } else if schema.kind == kind-name {
    (path,)
  } else {
    ()
  }
}

// Container kinds (`object`, `array`) are deliberately rejected — the
// walker descends through them, so accepting them would silently
// return () for every call and mask the typo.
#let paths-of-kind(schema, kind-name) = {
  assert(
    kind-name in _leaf-kinds,
    message: "gairm-import: paths-of-kind kind-name " + repr(kind-name) +
      " is not a recognised leaf kind. Expected one of: " +
      _leaf-kinds.join(", ") + ".",
  )
  _walk-paths(schema, (), kind-name)
}

// Thin wrapper over `lens-get(lens(path), schema).kind` — keeps the
// common "what kind is at X" debugging step a single call.
#let kind-at(schema, path) = lens-get(lens(path), schema).kind
