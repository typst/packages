// The leaf kinds' constructors: the scalars and enums,
// and the checks the engine runs for them, the per-node regex gate
// among them. string() and the format table live in format.typ,
// the containers and combinators in structure.typ with their walks in
// walk.typ, and registry.typ holds a descriptor for every kind.

#import "../core/error.typ": (
  _error, _expected-got, _type-miss, _type-name-of, _json-type-name, _bail,
  _fail, _num, _problem, _shown, _json,
)
#import "constraint.typ": _constraint-errors, _constrain, _comparable

/// A string that the model returns as Typst `content`, so it splices into
/// markup.
///
/// -> dictionary
#let markup() = (kind: "markup")
/// A boolean.
///
/// -> dictionary
#let boolean() = (kind: "boolean")

// The constructors take their constraints as named arguments, as
// Typst's own functions take their options (`text(size:)`,
// `rect(stroke:)`). The parameters are the number rows' fields
// (constraint.typ); _constrain checks each against its row, so a
// constructor holds no rule of its own. An unset argument adds no
// field, so `number() == (kind: "number")`.

/// A number (an integer or a float), with optional bounds. Each
/// argument is the JSON Schema keyword of the same meaning; an argument
/// left at `none` sets nothing. Panics on a value of the wrong type, or
/// on bounds no number satisfies.
///
/// - minimum (int, float, decimal, none): The smallest allowed value.
/// - maximum (int, float, decimal, none): The largest allowed value.
/// - exclusive-minimum (int, float, decimal, none): A value the number must be
///   greater than.
/// - exclusive-maximum (int, float, decimal, none): A value the number must be
///   less than.
/// - multiple-of (int, float, decimal, none): A positive number the value must be
///   a multiple of.
/// -> dictionary
#let number(
  minimum: none,
  maximum: none,
  exclusive-minimum: none,
  exclusive-maximum: none,
  multiple-of: none,
) = _constrain(
  "number()",
  (kind: "number"),
  "number",
  (
    minimum: minimum,
    maximum: maximum,
    exclusive-minimum: exclusive-minimum,
    exclusive-maximum: exclusive-maximum,
    multiple-of: multiple-of,
  ),
)

/// A number with no fractional part (`1.0` passes, `1.5` fails), with
/// optional bounds. Takes the same arguments as `number()`. Panics on a
/// value of the wrong type, or on bounds no number satisfies.
///
/// - minimum (int, float, decimal, none): The smallest allowed value.
/// - maximum (int, float, decimal, none): The largest allowed value.
/// - exclusive-minimum (int, float, decimal, none): A value the number must be
///   greater than.
/// - exclusive-maximum (int, float, decimal, none): A value the number must be
///   less than.
/// - multiple-of (int, float, decimal, none): A positive number the value must be
///   a multiple of.
/// -> dictionary
#let integer(
  minimum: none,
  maximum: none,
  exclusive-minimum: none,
  exclusive-maximum: none,
  multiple-of: none,
) = _constrain(
  "integer()",
  (kind: "integer"),
  "number",
  (
    minimum: minimum,
    maximum: maximum,
    exclusive-minimum: exclusive-minimum,
    exclusive-maximum: exclusive-maximum,
    multiple-of: multiple-of,
  ),
)

// JSON Schema `{}`. A leaf, so nested values are never walked.
/// Any value, passed through to the model unchanged (nested values
/// included). In `strict-null` mode it also accepts `null`.
///
/// -> dictionary
#let unknown() = (kind: "unknown")

// By default a null is absent before any kind sees it; in strict-null
// mode it reaches the check, which takes it.
/// `null`, under `strict-null: true`; by default a `null` key counts as
/// absent. Any other value is an error.
///
/// -> dictionary
#let null() = (kind: "null")

// Mixed-type members allowed: membership is by value (_enum-check),
// whatever the type. `const` is a singleton enum. The values come as
// any-of's members do (structure.typ's _members): a lone array argument
// is the list, so an enum whose one value is an array wraps it.
/// One of a fixed list of values. The values may be of mixed types.
/// `enum-of("a", "b")` and `enum-of(("a", "b"))` build the same node; an
/// enum whose only value is an array is `enum-of(((1, 2),))`. Panics if
/// there are no values.
///
/// - ..values (any, array): The allowed values, as separate arguments or
///   as one array.
/// -> dictionary
#let enum-of(..values) = {
  if values.named() != (:) {
    _bail(
      "enum-of()",
      "takes no named arguments; got: " + repr(values.named()) + ".",
    )
  }
  let pos = values.pos()
  let values = if pos.len() == 1 and type(pos.first()) == array {
    pos.first()
  } else { pos }
  // An empty enum takes nothing, so every value would fail it.
  if values == () {
    _fail("enum-of()", _problem("values", "a non-empty array", "()"))
  }
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
// Unless the check is fatal, the walk adds the constraint errors of the
// kind's `family` (none: no rows), so a pattern miss still reports a
// length miss beside it, as JSON Schema reports every failing keyword.
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
  let errors = r.errors
  if family != none {
    errors += _constraint-errors(schema, family, r.value, ctx.path)
  }
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
// A Typst `decimal` is a number too: JSON never gives one, but data
// written in Typst may. A NaN or an infinite float is not: JSON has no
// syntax for one, and no bound or multiple could judge it.
#let _numeric-check(expected) = (schema, value, ctx) => {
  if type(value) == float and (value.is-nan() or value.is-infinite()) {
    return _type-miss(ctx.path, expected, value)
  }
  _typed-check((int, float, decimal), expected)(schema, value, ctx)
}
#let _number-check = _numeric-check("number")
#let _integer-gate = _numeric-check("integer")

// The number gate, then the integral one: draft-7 semantics, so a
// float with zero fractional part passes. The integral miss is
// `integer`, not `type`: the member still takes numbers, so a union
// counts it as claiming the value. Nor is it a gate: the number rows
// still judge the value alongside it.
#let _integer-check(schema, value, ctx) = {
  let r = _integer-gate(schema, value, ctx)
  if r.fatal != none or calc.fract(value) == 0 { return r }
  (
    errors: _error(
      ctx.path,
      "integer",
      _expected-got("an integer", _num(value)),
      got: value,
    ),
    value: value,
    fatal: none,
  )
}

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

// The check of a string with no format: the type gate, then the node's
// own pattern, if it carries one. Pattern and hint travel on the schema
// node rather than via the format table, since each instance is unique.
#let _pattern-check(schema, value, ctx) = {
  if type(value) != str {
    return _type-miss(ctx.path, "string", value)
  }
  (errors: _pattern-errors(schema, value, ctx.path), value: value, fatal: none)
}

// Values compare as _comparable writes them, so a float meets a decimal,
// and an int past 2^53 a float, as the bounds compare them: `==` would
// round the int to the float. A string or a boolean holds no number, so
// `==` is exact for it. Messages write values as JSON, the syntax of
// the data they came from.
#let _enum-check(schema, value, ctx) = {
  if type(value) in (str, bool) {
    if value in schema.values { return _pass(value) }
  } else {
    let v = _comparable(value)
    if schema.values.any(x => _comparable(x) == v) { return _pass(value) }
  }
  let listed = schema.values.map(_json).join(", ")
  let message = _expected-got("one of " + listed, _json(value))
  // `type` when no value shares the value's JSON type, so a union
  // doesn't count this member as claiming it; `enum` otherwise. A null
  // reaches here only in strict-null mode, and
  // `null` is named only when it is the one value: `expected` lists the
  // types a non-null value could have, as a nullable union's does.
  let names = schema.values.filter(v => v != none).map(_json-type-name).dedup()
  if names == () { names = ("null",) }
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
  // Either way no listed value is left to model, and coerce names them
  // and the value.
  (
    errors: errors,
    value: value,
    fatal: (
      path: ctx.path,
      expected: "one of " + listed,
      got: value,
      shown: _shown(value),
    ),
  )
}
