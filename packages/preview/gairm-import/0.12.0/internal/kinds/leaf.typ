// The leaf kinds' constants and constructors: the scalars and enums,
// and the checks the engine runs for them, the per-node regex gate
// among them. string() and the format constants live in format.typ,
// the containers and combinators in structure.typ, and registry.typ
// holds a descriptor for every kind.

#import "../core/error.typ": (
  _error, _expected-got, _type-miss, _type-name-of, _json-type-name,
  _array-problem, _fail,
)
#import "constraint.typ": _constraint-errors, _constrain

/// Deprecated: use `string()` instead. Kept until 1.0.
///
/// A string, passed through as it is. The same as `string()`.
#let str-type = (kind: "string")
/// A string that the model returns as Typst `content`, so it splices into
/// markup.
#let content-type = (kind: "content")
/// Deprecated: use `number()` instead. Kept until 1.0.
///
/// An integer or a float. The same as `number()`.
#let number-type = (kind: "number")
/// A boolean.
#let bool-type = (kind: "bool")

// JSON Schema `integer`: any number with a zero fractional part
// (draft-7 semantics — 1.0 passes, 1.5 fails). A kind of its own, so
// introspection tells it from a number; the engine judges it as a
// number plus the integral gate.
/// Deprecated: use `integer()` instead. Kept until 1.0.
///
/// A number with no fractional part. `1.0` passes and `1.5` fails. The
/// same as `integer()`.
#let integer-type = (kind: "integer")

// The constructors take their constraints as named arguments, as
// Typst's own functions take their options (`text(size:)`,
// `rect(stroke:)`). The parameters are the number rows' fields
// (constraint.typ); _constrain checks each against its row, so a
// constructor holds no rule of its own. An unset argument adds no
// field, so `number() == number-type`.

/// A number (an integer or a float), with optional bounds. Each
/// argument is the JSON Schema keyword of the same meaning; an argument
/// left at `none` sets nothing, so `number()` is `number-type`. Panics
/// on a value of the wrong type, or on bounds no number satisfies.
///
/// - minimum (int, float, none): The smallest allowed value.
/// - maximum (int, float, none): The largest allowed value.
/// - exclusive-minimum (int, float, none): A value the number must be
///   greater than.
/// - exclusive-maximum (int, float, none): A value the number must be
///   less than.
/// - multiple-of (int, float, none): A positive number the value must be
///   a multiple of.
/// -> dictionary
#let number(
  minimum: none,
  maximum: none,
  exclusive-minimum: none,
  exclusive-maximum: none,
  multiple-of: none,
) = _constrain("number()", number-type, "number", (
  minimum: minimum,
  maximum: maximum,
  exclusive-minimum: exclusive-minimum,
  exclusive-maximum: exclusive-maximum,
  multiple-of: multiple-of,
))

/// A number with no fractional part (`1.0` passes, `1.5` fails), with
/// optional bounds. Takes the same arguments as `number()`; `integer()`
/// is `integer-type`. Panics on a value of the wrong type, or on bounds
/// no number satisfies.
///
/// - minimum (int, float, none): The smallest allowed value.
/// - maximum (int, float, none): The largest allowed value.
/// - exclusive-minimum (int, float, none): A value the number must be
///   greater than.
/// - exclusive-maximum (int, float, none): A value the number must be
///   less than.
/// - multiple-of (int, float, none): A positive number the value must be
///   a multiple of.
/// -> dictionary
#let integer(
  minimum: none,
  maximum: none,
  exclusive-minimum: none,
  exclusive-maximum: none,
  multiple-of: none,
) = _constrain("integer()", integer-type, "number", (
  minimum: minimum,
  maximum: maximum,
  exclusive-minimum: exclusive-minimum,
  exclusive-maximum: exclusive-maximum,
  multiple-of: multiple-of,
))

// JSON Schema `{}`: no constraint at all. A leaf, so nested values
// pass through as given; in strict-null mode it takes null too.
/// Any value, passed through to the model unchanged (nested values
/// included). In `strict-null` mode it also accepts `null`.
#let any-type = (kind: "any")

// "Must be null or absent". By default a null is absent before any
// kind sees it; in strict-null mode it reaches the check, which takes
// it.
/// `null` or an absent key. Any other value is an error.
#let null-type = (kind: "null")

// Mixed-type members allowed — the validator's `in` check gates on
// equality, not type. `const` is a singleton enum.
/// One of a fixed list of values. The values may be of mixed types.
/// Panics if `values` is not an array.
///
/// - values (array): The allowed values.
/// -> dictionary
#let enum-of(values) = {
  let p = _array-problem(values, "values", "an array", "value")
  if p != none { _fail("enum-of()", p) }
  (kind: "enum", values: values)
}
/// Exactly one value. Same as `enum-of` with a single value.
///
/// - value (any): The only allowed value.
/// -> dictionary
#let const-of(value) = enum-of((value,))

// ---- engine behaviour ------------------------------------------------
//
// A leaf check is (schema, value, ctx) -> (errors, value, fatal). It
// judges the JSON-level value and may normalise it (a datetime becomes
// its ISO string), but never wraps it: the kind's `model` does that.
// When the check passes, the walk adds the constraint errors of the
// kind's `family` (none: no rows).
//
// `fatal` is none, or (path, expected, got) when the value leaves no
// model at all; coerce panics with it ("coerce at <path>: expected
// <expected>, got …").
// Each check says so itself: a miss that still leaves a usable value (a
// pattern, a format regex, `integer`) has no fatal.
//
// A check emits `type` exactly when the value's JSON type is wrong for
// the kind: a union counts a member as claiming a value unless the
// member reports `type` at the union's own path.

/// The engine walk of a leaf kind, from its check, constraint family and
/// model, so the engine runs every kind the same way.
#let _leaf-walk(check, family, model) = (schema, value, ctx, recur) => {
  let r = check(schema, value, ctx)
  if r.fatal != none { return r }
  let errors = if r.errors == () and family != none {
    _constraint-errors(schema, family, r.value, ctx.path)
  } else { r.errors }
  (errors: errors, value: model(r.value), fatal: none)
}

#let _pass(value) = (errors: (), value: value, fatal: none)

/// A check that only gates on the value's Typst type.
#let _typed-check(types, expected) = (schema, value, ctx) => {
  if type(value) in types { _pass(value) } else {
    _type-miss(ctx.path, expected, value)
  }
}

#let _string-check = _typed-check((str,), "string")
#let _bool-check = _typed-check((bool,), "boolean")

// The number gate, then, when `integral`, the integral one: draft-7
// semantics, so a float with zero fractional part passes. The miss is
// `integer`, not `type`: the member still takes numbers, so a union
// counts it as claiming the value. Nor is it a gate: the number rows
// still judge the value alongside it.
#let _numeric-check(schema, value, ctx, integral) = {
  if type(value) not in (int, float) {
    return _type-miss(ctx.path, "number", value)
  }
  if integral and calc.fract(value) != 0 {
    let errors = _error(
      ctx.path,
      "integer",
      _expected-got("an integer", str(value)),
      got: value,
    )
    let constraint-errors = _constraint-errors(
      schema,
      "number",
      value,
      ctx.path,
    )
    return (errors: errors + constraint-errors, value: value, fatal: none)
  }
  _pass(value)
}

// A hand-built number node may still carry the `integer: true` flag
// integer-type used to set; it gates as the integer kind does.
#let _number-check(schema, value, ctx) = _numeric-check(
  schema,
  value,
  ctx,
  schema.at("integer", default: false),
)
#let _integer-check(schema, value, ctx) = _numeric-check(
  schema,
  value,
  ctx,
  true,
)

#let _any-check(schema, value, ctx) = _pass(value)

// An absent value never reaches a check, so a null arrives here only
// in strict-null mode, where it is this kind's one value. Every other
// check rejects a null with `type` ("got null") at its type gate.
#let _null-check(schema, value, ctx) = if value == none { _pass(value) } else {
  _type-miss(ctx.path, "null", value)
}

// The node's own `pattern` gate, if it carries one (a patterned
// string, or a formatted one with an extra pattern).
#let _pattern-errors(schema, value, path) = {
  if "pattern" in schema and value.match(schema.pattern) == none {
    // Hand-built nodes may omit `expected`; default as string() does.
    let expected = schema.at("expected", default: "matching pattern")
    _error(
      path,
      "pattern",
      "expected " + expected + ".",
      expected: expected,
      got: value,
    )
  } else { () }
}

// The check of a string with no format: the type gate, then the
// node's own pattern, if it carries one. Pattern and hint travel on the schema node rather
// than via the format table, since each instance is unique.
#let _pattern-check(schema, value, ctx) = {
  if type(value) != str {
    return _type-miss(ctx.path, "string", value)
  }
  (errors: _pattern-errors(schema, value, ctx.path), value: value, fatal: none)
}

#let _enum-check(schema, value, ctx) = {
  if value in schema.values { return _pass(value) }
  let listed = schema.values.map(repr).join(", ")
  let message = _expected-got("one of " + listed, repr(value))
  // `type` when no value shares the value's JSON type, so a union
  // doesn't count this member as claiming it; `enum` otherwise.
  let names = schema.values.map(_json-type-name).dedup()
  let errors = if _json-type-name(value) not in names {
    _error(
      ctx.path,
      "type",
      message,
      expected: names.join(" or "),
      got: _type-name-of(value),
    )
  } else {
    _error(ctx.path, "enum", message, expected: schema.values, got: value)
  }
  // Either way no listed value is left to model, and coerce names them.
  (
    errors: errors,
    value: value,
    fatal: (path: ctx.path, expected: "one of " + listed, got: value),
  )
}
