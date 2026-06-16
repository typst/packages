// Subtrees under unknown keys are not walked — their expected shape
// is undefined.
//
// JSON `null` (Typst's `none`) at a value position is treated as if
// the key were absent: no type error, no recursion. Per-key null
// values in objects, null array elements, and entire-section nulls
// are all absorbed by the top-of-function early return — recursion
// handles them uniformly. The required-keys check below is the only
// place that still needs an explicit null check (a present-but-null
// required key must still count as missing). See README "Errors"
// section for the user-facing rationale.

#import "errors.typ": _type-name-of, _closest-match

#let _type-error(path, expected, value) = ((
  path: path,
  message: "expected " + expected + ", got " + _type-name-of(value) + ".",
),)

// Tightened over the upstream JSON Resume regexes, which accept
// impossible months / days because they use [0-1][0-9] / [0-3][0-9].
// Deliberately permissive (no full RFC compliance). Message omits the
// offending value — the path already names the field, the canonical
// example in `expected` is the actionable hint.
#let _format-specs = (
  "date-string": (
    pattern: regex("^([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])|[0-9]{4}-(0[1-9]|1[0-2])|[0-9]{4})$"),
    expected: "an ISO-8601 date (e.g. \"2024-01-15\")",
  ),
  "datetime-string": (
    pattern: regex("^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|[+-]([01][0-9]|2[0-3]):[0-5][0-9])?$"),
    expected: "an ISO-8601 datetime (e.g. \"2024-01-15T10:00:00Z\")",
  ),
  "uri-string": (
    pattern: regex("^[A-Za-z][A-Za-z0-9+.\-]*://\S+$"),
    expected: "a URI (e.g. \"https://example.com\")",
  ),
  "email-string": (
    pattern: regex("^[^@\s]+@[^@\s.]+(?:\.[^@\s.]+)+$"),
    expected: "an email (e.g. \"name@example.com\")",
  ),
)

#let _validate(schema, value, path) = {
  // Null at any value position is "key absent" — no error, no
  // recursion. Single early return handles every shape uniformly:
  // standalone scalars, array elements (via the per-element call),
  // and per-key sub-values inside objects (via the per-key call).
  if value == none { return () }
  let kind = schema.kind
  if kind in ("str", "content") {
    if type(value) != str { return _type-error(path, "string", value) }
    return ()
  }
  if kind == "enum" {
    if value in schema.values { return () }
    return ((
      path: path,
      message: "expected one of " + schema.values.map(repr).join(", ") +
        ", got " + repr(value) + ".",
    ),)
  }
  if kind in _format-specs {
    if type(value) != str { return _type-error(path, "string", value) }
    let spec = _format-specs.at(kind)
    if value.match(spec.pattern) == none {
      return ((path: path, message: "expected " + spec.expected + "."),)
    }
    return ()
  }
  // pattern + hint travel on the schema node rather than via the
  // _format-specs table above, since each instance is unique.
  if kind == "pattern-string" {
    if type(value) != str { return _type-error(path, "string", value) }
    if value.match(schema.pattern) == none {
      return ((path: path, message: "expected " + schema.expected + "."),)
    }
    return ()
  }
  if kind == "number" {
    if type(value) not in (int, float) { return _type-error(path, "number", value) }
    return ()
  }
  if kind == "array" {
    if type(value) != array { return _type-error(path, "array", value) }
    return value.enumerate()
      .map(((i, elem)) => _validate(schema.elem, elem, path + (i,)))
      .flatten()
  }
  if kind == "object" {
    if type(value) != dictionary { return _type-error(path, "object", value) }
    let per-key-errs = value.pairs().map(((key, sub-value)) => {
      if key in schema.shape {
        _validate(schema.shape.at(key), sub-value, path + (key,))
      } else {
        // On the unknown-key branch, try a fuzzy suggestion first: a
        // short "Did you mean …?" beats a 9–14-key dump when the typo
        // is within edit distance 2 of a valid key. Otherwise fall
        // back to the full list. Either way the per-branch work is
        // skipped on the happy path.
        //
        // An unknown key with a null value is still flagged — silently
        // swallowing typos would defeat the point of strict validation.
        let suggestion = _closest-match(key, schema.shape.keys(), 2)
        let tail = if suggestion != none {
          "Did you mean " + repr(suggestion) + "?"
        } else {
          "Valid keys: " + schema.shape.keys().join(", ") + "."
        }
        ((
          path: path + (key,),
          message: "unknown key " + repr(key) + ". " + tail,
        ),)
      }
    }).flatten()
    // A required key whose value is explicit null counts as missing —
    // null-as-absent applies uniformly.
    let required = schema.at("required-keys", default: ())
    let missing-errs = required
      .filter(k => k not in value or value.at(k) == none)
      .map(k => (
        path: path + (k,),
        message: "missing required key " + repr(k) + ".",
      ))
    return per-key-errs + missing-errs
  }
  panic("gairm-import: internal — unknown schema kind " + repr(kind))
}
