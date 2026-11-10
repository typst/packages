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
#import "kinds.typ": _format-string-kinds

#let _err(path, msg) = ((path: path, message: msg),)

#let _type-error(path, expected, value) = _err(
  path,
  "expected " + expected + ", got " + _type-name-of(value) + ".",
)

// Clusters, not bytes — JSON Schema talks "length" without pinning.
#let _string-length-errs(schema, value, path) = {
  let min = schema.at("min-length", default: none)
  let max = schema.at("max-length", default: none)
  if min == none and max == none { return () }
  let n = value.clusters().len()
  let errs = ()
  if min != none and n < min {
    errs += _err(
      path,
      "expected string length ≥ " + str(min) + ", got " + str(n) + ".",
    )
  }
  if max != none and n > max {
    errs += _err(
      path,
      "expected string length ≤ " + str(max) + ", got " + str(n) + ".",
    )
  }
  errs
}

#let _number-range-errs(schema, value, path) = {
  let errs = ()
  let mn = schema.at("minimum", default: none)
  if mn != none and value < mn {
    errs += _err(path, "expected ≥ " + str(mn) + ", got " + str(value) + ".")
  }
  let mx = schema.at("maximum", default: none)
  if mx != none and value > mx {
    errs += _err(path, "expected ≤ " + str(mx) + ", got " + str(value) + ".")
  }
  let emn = schema.at("exclusive-minimum", default: none)
  if emn != none and value <= emn {
    errs += _err(path, "expected > " + str(emn) + ", got " + str(value) + ".")
  }
  let emx = schema.at("exclusive-maximum", default: none)
  if emx != none and value >= emx {
    errs += _err(path, "expected < " + str(emx) + ", got " + str(value) + ".")
  }
  let mult = schema.at("multiple-of", default: none)
  if mult != none and calc.rem(value, mult) != 0 {
    errs += _err(
      path,
      "expected multiple of " + str(mult) + ", got " + str(value) + ".",
    )
  }
  errs
}

// Filter `none` first — coerce drops them, so raw counts would
// validate inputs whose rendered model violates min-items. Duplicate
// reports cite original positions so callers can find them.
#let _array-constraint-errs(schema, value, path) = {
  let errs = ()
  let present = value.enumerate().filter(((_, elem)) => elem != none)
  let n = present.len()
  let min = schema.at("min-items", default: none)
  if min != none and n < min {
    errs += _err(
      path,
      "expected array length ≥ " + str(min) + ", got " + str(n) + ".",
    )
  }
  let max = schema.at("max-items", default: none)
  if max != none and n > max {
    errs += _err(
      path,
      "expected array length ≤ " + str(max) + ", got " + str(n) + ".",
    )
  }
  if schema.at("unique-items", default: false) {
    for i in range(n) {
      for j in range(i + 1, n) {
        let (orig-i, left) = present.at(i)
        let (orig-j, right) = present.at(j)
        if left == right {
          errs += _err(
            path,
            "expected unique items, duplicate at indices "
              + str(orig-i)
              + " and "
              + str(orig-j)
              + ".",
          )
          return errs
        }
      }
    }
  }
  errs
}

// Tightened over the upstream JSON Resume regexes, which accept
// impossible months / days because they use [0-1][0-9] / [0-3][0-9].
// Deliberately permissive (no full RFC compliance). Message omits the
// offending value — the path already names the field, the canonical
// example in `expected` is the actionable hint.
#let _format-specs = (
  "date-string": (
    pattern: regex(
      "^([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])|[0-9]{4}-(0[1-9]|1[0-2])|[0-9]{4})$",
    ),
    expected: "an ISO-8601 date (e.g. \"2024-01-15\")",
  ),
  "datetime-string": (
    pattern: regex(
      "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|[+-]([01][0-9]|2[0-3]):[0-5][0-9])?$",
    ),
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

// Load-time drift guard: a format kind added to kinds.typ but not here
// (or vice versa) fails at import, not at validate time on unlucky input.
#assert(
  _format-specs.keys().sorted() == _format-string-kinds.sorted(),
  message: "gairm-import: internal — _format-specs is out of sync with kinds._format-string-kinds.",
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
    return _string-length-errs(schema, value, path)
  }
  if kind == "enum" {
    if value in schema.values { return () }
    return _err(
      path,
      "expected one of "
        + schema.values.map(repr).join(", ")
        + ", got "
        + repr(value)
        + ".",
    )
  }
  if kind in _format-specs {
    if type(value) != str { return _type-error(path, "string", value) }
    let spec = _format-specs.at(kind)
    if value.match(spec.pattern) == none {
      return _err(path, "expected " + spec.expected + ".")
    }
    return _string-length-errs(schema, value, path)
  }
  // pattern + hint travel on the schema node rather than via the
  // _format-specs table above, since each instance is unique.
  if kind == "pattern-string" {
    if type(value) != str { return _type-error(path, "string", value) }
    if value.match(schema.pattern) == none {
      return _err(path, "expected " + schema.expected + ".")
    }
    return _string-length-errs(schema, value, path)
  }
  if kind == "number" {
    if type(value) not in (int, float) {
      return _type-error(path, "number", value)
    }
    // `integer: true` (kinds.typ's integer-type / JSON Schema `integer`):
    // draft-7 semantics, so a float with zero fractional part passes.
    let errs = if (
      schema.at("integer", default: false) and calc.fract(value) != 0
    ) {
      _err(path, "expected an integer, got " + str(value) + ".")
    } else { () }
    return errs + _number-range-errs(schema, value, path)
  }
  if kind == "bool" {
    if type(value) != bool { return _type-error(path, "boolean", value) }
    return ()
  }
  // `none` succeeds via the top early return; non-none can only fail.
  if kind == "null" { return _type-error(path, "null", value) }
  if kind == "array" {
    if type(value) != array { return _type-error(path, "array", value) }
    let elem-errs = value
      .enumerate()
      .map(((i, elem)) => _validate(schema.elem, elem, path + (i,)))
      .flatten()
    return elem-errs + _array-constraint-errs(schema, value, path)
  }
  if kind == "object" {
    if type(value) != dictionary { return _type-error(path, "object", value) }
    let additional = schema.at("additional", default: none)
    let per-key-errs = value
      .pairs()
      .map(((key, sub-value)) => {
        if key in schema.shape {
          _validate(schema.shape.at(key), sub-value, path + (key,))
        } else if additional == true {
          // `additionalProperties: true` — no validation. coerce.typ
          // mirrors this by passing the value through verbatim.
          ()
        } else if additional != none {
          _validate(additional, sub-value, path + (key,))
        } else {
          // Strict branch: fuzzy suggestion if the typo is within edit
          // distance 2 of a valid key, otherwise the full key list.
          // Unknown key with null value still flagged — silently
          // swallowing typos defeats the point of strict validation.
          let suggestion = _closest-match(key, schema.shape.keys(), 2)
          let tail = if suggestion != none {
            "Did you mean " + repr(suggestion) + "?"
          } else {
            "Valid keys: " + schema.shape.keys().join(", ") + "."
          }
          _err(path + (key,), "unknown key " + repr(key) + ". " + tail)
        }
      })
      .flatten()
    // A required key whose value is explicit null counts as missing —
    // null-as-absent applies uniformly.
    let required = schema.at("required-keys", default: ())
    let missing-errs = required
      .filter(k => k not in value or value.at(k) == none)
      .map(k => _err(path + (k,), "missing required key " + repr(k) + "."))
      .flatten()
    return per-key-errs + missing-errs
  }
  // anyOf / oneOf. One summary error at the union's own path rather
  // than every member's failure list — member errors describe branches
  // the value never claimed to match, so replaying them all is noise.
  if kind == "union" {
    // Exclusivity needs the full match count; any-of only needs "at
    // least one", so it short-circuits on the first matching member.
    if schema.exclusive {
      let matches = schema
        .members
        .filter(m => _validate(m, value, path).len() == 0)
        .len()
      if matches == 1 { return () }
      if matches > 1 {
        return _err(
          path,
          "expected exactly one alternative to match, but "
            + str(matches)
            + " matched.",
        )
      }
    } else if schema.members.any(m => _validate(m, value, path).len() == 0) {
      return ()
    }
    let alternatives = schema.members.map(m => m.kind).join(" | ")
    let quantifier = if schema.exclusive { "exactly one" } else { "one" }
    return _err(
      path,
      "expected a value matching "
        + quantifier
        + " of: "
        + alternatives
        + "; none matched.",
    )
  }
  // `not` inverts the member verdict; the member's own errors are
  // discarded (they describe why the value is ACCEPTABLE here).
  if kind == "not" {
    if _validate(schema.member, value, path).len() == 0 {
      return _err(
        path,
        "expected a value not matching the negated "
          + schema.member.kind
          + " schema.",
      )
    }
    return ()
  }
  panic("gairm-import: internal — unknown schema kind " + repr(kind))
}
