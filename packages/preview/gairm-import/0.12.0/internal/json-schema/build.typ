// The translator's builders: one per JSON type, each reading its own
// keywords from a node, the constraint keywords folded on afterwards,
// and the enum / const fold that filters a value list by them.

#import "../core/ctx.typ": _ctx
#import "../core/error.typ": _json-type-name
#import "../engine.typ": _walk
#import "../kinds/leaf.typ": number-type, integer-type, bool-type, null-type
#import "../kinds/structure.typ": array-of, object, _object-problem
#import "../kinds/format.typ": string, _string-problem
#import "../kinds/constraint.typ": _read-constraints
#import "keyword.typ": (
  _bail, _bail-problem, _constraint-family, _membership-structural,
)

// `dependentRequired` (2019-09) and draft 7's array-form `dependencies`
// are the same constraint, read as (keyword, value); object() checks the
// value's shape. The schema form of `dependencies` is out of scope, like
// `dependentSchemas`, which it means.
#let _dependent-required(js) = {
  let has-dr = "dependentRequired" in js
  let has-dep = "dependencies" in js
  if has-dr and has-dep {
    _bail(
      "\"dependencies\" and \"dependentRequired\" cannot both be set; use one.",
    )
  }
  let keyword = if has-dr { "dependentRequired" } else { "dependencies" }
  let map = js.at(keyword, default: (:))
  if type(map) != dictionary { return (keyword, map) }
  for (trigger, dependents) in map {
    if type(dependents) == dictionary {
      _bail(
        "unsupported JSON Schema keyword: the schema form of \"dependencies\" (for "
          + repr(trigger)
          + "). dependentSchemas and the schema form of dependencies are out of scope.",
      )
    }
  }
  (keyword, map)
}

// Both keywords apply when both are present (JSON Schema's "all
// keywords apply"): string() gives the formatted string the pattern as
// an extra gate, checked after the format regex. string()'s own check runs
// first, so a bad keyword bails in the translator's words.
#let _string-base(js) = {
  let pattern = js.at("pattern", default: none)
  let args = (
    format: js.at("format", default: none),
    pattern: pattern,
    expected: if pattern != none { "matching " + repr(pattern) },
  )
  let p = _string-problem(..args)
  if p != none { _bail-problem(p) }
  string(..args)
}

// No `items`: items of any value, as in draft 7.
#let _array-base(js, ctx, recur) = {
  let items = js.at("items", default: (:))
  if type(items) == array {
    _bail(
      "unsupported JSON Schema keyword: the array form of \"items\" "
        + "(one schema per position). Tuple validation is out of scope; "
        + "give \"items\" one schema for every element.",
    )
  }
  array-of(recur(items, ctx))
}

// Under an `if` (`ctx.open-objects`, conditional.typ) an undeclared
// `additionalProperties` is open, as draft 7 reads it: the condition is
// only a test, and a closed one would fail on every key it doesn't
// mention.
#let _object-base(js, ctx, recur) = {
  let has-props = "properties" in js
  let has-ap = "additionalProperties" in js
  // Fully open with no constraints inverts the engine's strict intent.
  if not has-props and not has-ap and not ctx.open-objects {
    _bail(
      "open object schemas (`type: \"object\"` with no `properties` "
        + "or `additionalProperties`) are out of scope; every field "
        + "must be declared or covered by `additionalProperties`.",
    )
  }
  let props = if has-props { js.at("properties") } else { (:) }
  if type(props) != dictionary {
    _bail("\"properties\" must be an object, got: " + repr(type(props)) + ".")
  }
  let additional = if not has-ap {
    if ctx.open-objects { true } else { none }
  } else {
    let ap = js.at("additionalProperties")
    if ap == false { none } else if ap == true { true } else if (
      type(ap) == dictionary
    ) { recur(ap, ctx) } else {
      _bail(
        "\"additionalProperties\" must be a schema, true, or false, got: "
          + repr(ap)
          + ".",
      )
    }
  }
  let required = js.at("required", default: ())
  let (keyword, dependent) = _dependent-required(js)
  // object()'s own check, so a bad value bails in the translator's words.
  let p = _object-problem(required, dependent, additional)
  if p != none {
    _bail-problem(p, keywords: (
      required-keys: "required",
      dependent-required: keyword,
    ))
  }
  object(
    props.pairs().map(((k, v)) => (k, recur(v, ctx))).to-dict(),
    required-keys: required,
    dependent-required: dependent,
    additional: additional,
  )
}

// One builder per JSON type, keyed by its `type` name, each reading its
// own keywords from the node and ignoring the others' (JSON Schema
// semantics); the constraint keywords are folded on afterwards.
// `integer` keeps its integral constraint rather than flattening to
// number, which would silently drop it.
#let _builders = (
  string: (js, ctx, recur) => _string-base(js),
  number: (..) => number-type,
  integer: (..) => integer-type,
  array: _array-base,
  object: _object-base,
  boolean: (..) => bool-type,
  "null": (..) => null-type,
)

// Reads the constraint keywords for JSON type `t` onto `node`, bailing
// at translate time on a bad-shape value — better than a kind dict the
// validator can't reason about — and on bounds no value can satisfy
// (min > max, etc.), which would translate cleanly but reject every
// input as a mystery validation failure.
#let _with-constraints(node, js, t) = {
  let family = _constraint-family.at(t, default: none)
  if family == none { return node }
  let read = _read-constraints(node, family, js, row => row.json)
  if read.problem != none { _bail-problem(read.problem) }
  read.node
}

// The schema for the node as JSON type `t`.
#let _build(js, ctx, t, recur) = _with-constraints(
  _builders.at(t)(js, ctx, recur),
  js,
  t,
)

// Folds the `type` and constraint keywords beside `enum` / `const` into
// the value set: each value is checked against the schema the node
// builds for its JSON type, and only survivors are kept. Type-specific
// keywords ignore other types (JSON Schema semantics), so a value of a
// type no keyword applies to — a bool, null, object, or a string beside
// only `minimum` — survives.
#let _fold-membership(js, ctx, names, recur) = {
  for keyword in _membership-structural {
    if keyword in js {
      _bail(
        repr(keyword)
          + " cannot be combined with enum/const — it describes object/array structure, which membership does not check.",
      )
    }
  }
  let values = if "enum" in js { js.at("enum") } else { (js.at("const"),) }
  if type(values) != array {
    _bail(
      "\"enum\" must be an array of values, got: " + repr(type(values)) + ".",
    )
  }
  let by-type = ("string", "number", "array")
    .map(t => (t, _build(js, ctx, t, recur)))
    .to-dict()
  let survivors = values.filter(v => {
    let kind = _json-type-name(v)
    // `type` keeps a value whose JSON type it names; `integer` is a
    // number with no fractional part (`1.0` passes, per draft 7).
    let allowed = (
      names == none
        or (
          kind in names
            or (
              kind == "number" and "integer" in names and calc.fract(v) == 0
            )
        )
    )
    (
      allowed
        and (
          kind not in by-type
            or _walk(by-type.at(kind), v, _ctx()).errors.len() == 0
        )
    )
  })
  // `enum: []` was always accepted; only report values that constraints
  // eliminated.
  if values.len() > 0 and survivors.len() == 0 {
    _bail(
      "no enum/const value satisfies the accompanying type/constraints, so the schema is unsatisfiable.",
    )
  }
  survivors
}
