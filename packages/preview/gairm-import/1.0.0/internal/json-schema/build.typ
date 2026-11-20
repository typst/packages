// The translator's builders: one per JSON type, each reading its own
// keywords from a node, the constraint keywords folded on afterwards,
// and the enum / const fold that filters a value list by them.

#import "../core/ctx.typ": _ctx
#import "../core/error.typ": _json-type-name, _problem
#import "../engine.typ": _walk
#import "../kinds/leaf.typ": number, integer, boolean, null, unknown
#import "../kinds/structure.typ": array-of, object
#import "../kinds/registry.typ": _object-problem
#import "../kinds/format.typ": string, _string-problem
#import "../kinds/constraint.typ": _read-constraints, _comparable
#import "keyword.typ": (
  _bail, _bail-problem, _json, _into, _constraint-family,
  _membership-structural,
)

// `dependentRequired` (2019-09) and draft 7's array-form `dependencies`
// are the same constraint, read as (keyword, value); object() checks the
// value's shape. The schema form of `dependencies` is out of scope, like
// `dependentSchemas`, which it means.
#let _dependent-required(js, ctx) = {
  let has-dr = "dependentRequired" in js
  let has-dep = "dependencies" in js
  if has-dr and has-dep {
    _bail(
      ctx,
      "\"dependencies\" and \"dependentRequired\" cannot both be set; use one.",
    )
  }
  let keyword = if has-dr { "dependentRequired" } else { "dependencies" }
  let map = js.at(keyword, default: (:))
  if type(map) != dictionary { return (keyword, map) }
  for (trigger, dependents) in map {
    // A boolean is a schema too, in draft 7's `dependencies`.
    if keyword == "dependencies" and type(dependents) in (dictionary, bool) {
      _bail(
        ctx,
        "unsupported JSON Schema keyword: the schema form of \"dependencies\" (for "
          + _json(trigger)
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
#let _string-base(js, ctx) = {
  let pattern = js.at("pattern", default: none)
  let args = (
    format: js.at("format", default: none),
    pattern: pattern,
    expected: if pattern != none { "matching " + _json(pattern) },
  )
  let p = _string-problem(..args)
  // JSON has no regex: a pattern is a string there.
  if p != none and p.at("arg", default: none) == "pattern" {
    p.must = "a string"
  }
  if p != none { _bail-problem(ctx, p, node: js) }
  string(..args)
}

// No `items`: items of any value, as in draft 7.
#let _array-base(js, ctx, recur) = {
  let items = js.at("items", default: (:))
  if type(items) == array {
    _bail(
      ctx,
      "unsupported JSON Schema keyword: the array form of \"items\" "
        + "(one schema per position). Tuple validation is out of scope; "
        + "give \"items\" one schema for every element.",
    )
  }
  array-of(recur(items, _into(ctx, "items")))
}

// Under an `if` or a `not` (`ctx.open-objects`, conditional.typ,
// translate.typ) an undeclared `additionalProperties` is open, as
// draft 7 reads it: the condition is only a test, and a closed one
// would fail on every key it doesn't mention.
#let _object-base(js, ctx, recur) = {
  let has-props = "properties" in js
  let has-ap = "additionalProperties" in js
  // Fully open with no constraints inverts the engine's strict intent.
  if not has-props and not has-ap and not ctx.open-objects {
    _bail(
      ctx,
      "open object schemas (`type: \"object\"` with no `properties` "
        + "or `additionalProperties`) are out of scope; every field "
        + "must be declared or covered by `additionalProperties`.",
    )
  }
  let props = if has-props { js.at("properties") } else { (:) }
  if type(props) != dictionary {
    _bail-problem(
      ctx,
      _problem("properties", "an object", _json(props)),
    )
  }
  let additional = if not has-ap {
    if ctx.open-objects { true } else { none }
  } else {
    let ap = js.at("additionalProperties")
    if ap == false { none } else if ap == true { true } else if (
      type(ap) == dictionary
    ) {
      // A schema that takes any value (`{}`) is `true`, so the two
      // spellings build one node, and an allOf of both agrees.
      let node = recur(ap, _into(ctx, "additionalProperties"))
      if node == unknown() { true } else { node }
    } else {
      _bail(
        ctx,
        "\"additionalProperties\" must be a schema, true, or false, got: "
          + _json(ap)
          + ".",
      )
    }
  }
  let required = js.at("required", default: ())
  let (keyword, dependent) = _dependent-required(js, ctx)
  // object()'s own check, so a bad value bails in the translator's words.
  let p = _object-problem(required, dependent, additional, keys: props.keys())
  if p != none {
    _bail-problem(
      ctx,
      p,
      keywords: (required-keys: "required", dependent-required: keyword),
      node: js,
    )
  }
  let shape = (:)
  for (k, v) in props { shape.insert(k, recur(v, _into(ctx, "properties", k))) }
  object(
    shape,
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
  string: (js, ctx, recur) => _string-base(js, ctx),
  number: (..) => number(),
  integer: (..) => integer(),
  array: _array-base,
  object: _object-base,
  boolean: (..) => boolean(),
  "null": (..) => null(),
)

// Reads the constraint keywords for JSON type `t` onto `node`, bailing
// at translate time on a bad-shape value — better than a kind dict the
// validator can't reason about — and on bounds no value can satisfy
// (min > max, etc.), which would translate cleanly but reject every
// input as a mystery validation failure. Returns `(node, gap)`: `gap`
// is the problem of integer bounds that hold no integer (constraint.typ),
// which the caller decides on, since a `type` list's other members may
// still take a value.
#let _with-constraints(node, js, t, ctx) = {
  let family = _constraint-family.at(t, default: none)
  if family == none { return (node: node, gap: none) }
  // Draft 4 wrote an exclusive bound as `minimum` plus a boolean flag.
  for keyword in ("exclusiveMinimum", "exclusiveMaximum") {
    if family == "number" and type(js.at(keyword, default: 0)) == bool {
      _bail(
        ctx,
        _json(keyword)
          + " must be a number, got: "
          + _json(js.at(keyword))
          + ". Draft 4's boolean form is not supported; give the bound itself, as draft 7 does.",
      )
    }
  }
  let read = _read-constraints(node, family, js, row => row.json)
  if read.problem != none { _bail-problem(ctx, read.problem, node: js) }
  (node: read.node, gap: read.gap)
}

// Folds the `type` and constraint keywords beside `enum` / `const` into
// the value set: each value is checked against the schema the node
// builds for its JSON type, and only survivors are kept. With both
// `enum` and `const`, only the enum values equal to the const survive.
// Type-specific keywords ignore other types (JSON Schema semantics), so
// a value of a type no keyword applies to — a bool, null, object, or a
// string beside only `minimum` — survives. A value is literal JSON,
// judged as written whatever mode the data is later validated in, so
// a null item in an array value counts toward its length.
#let _fold-membership(js, ctx, names, recur) = {
  for keyword in _membership-structural {
    if keyword in js {
      _bail(
        ctx,
        _json(keyword)
          + " cannot be combined with enum/const — it describes object/array structure, which membership does not check.",
      )
    }
  }
  let values = if "enum" in js { js.at("enum") } else { (js.at("const"),) }
  if type(values) != array or values == () {
    _bail-problem(ctx, _problem(
      "enum",
      "a non-empty array of values",
      _json(values),
    ))
  }
  if "enum" in js and "const" in js {
    let c = js.at("const")
    // As enum-of() compares: 2^53 + 1 is no float.
    let cc = _comparable(c)
    values = values.filter(v => _comparable(v) == cc)
    if values == () {
      _bail(
        ctx,
        "\"const\" "
          + _json(c)
          + " is not one of the \"enum\" values "
          + _json(js.at("enum"))
          + ", so the schema is unsatisfiable.",
      )
    }
  }
  let by-type = (:)
  for t in ("string", "number", "array") {
    by-type.insert(
      t,
      _with-constraints(_builders.at(t)(js, ctx, recur), js, t, ctx).node,
    )
  }
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
            or _walk(by-type.at(kind), v, _ctx(strict-null: true)).errors.len()
              == 0
        )
    )
  })
  if survivors.len() == 0 {
    _bail(
      ctx,
      "no enum/const value satisfies the accompanying type/constraints, so the schema is unsatisfiable.",
    )
  }
  survivors
}
