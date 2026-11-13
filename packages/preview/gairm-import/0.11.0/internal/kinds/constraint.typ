// The constraint keywords, one row each. A row ties a node field to
// its JSON Schema keyword, the family of values it applies to, the
// error code a miss reports, and which raw keyword values the
// translator accepts (and, as `read`, how it stores one when that is
// not the value itself). A bound (`op`) is checked against the family's
// measure; the two keywords that are not bounds carry a `test`. The
// engine, the translator's reader, its allow-list and its enum/const
// fold all read these rows, so a new keyword is one row.

#import "../core/error.typ": _bail, _error, _expected-got, _problem, _fail

// Which raw values a keyword takes, as checks run in order; the first
// that fails names what the value must be. A count may be a float with
// no fractional part (`2.0`), as draft 7's `integer` allows; its row's
// `read` stores it as an int.
#let _whole(v) = (
  type(v) == int
    or (type(v) == float and not v.is-infinite() and calc.fract(v) == 0)
)
#let _count = (
  (ok: v => _whole(v) and v >= 0, must: "a non-negative integer"),
)
#let _number = ((ok: v => type(v) in (int, float), must: "a number"),)
#let _positive = _number + ((ok: v => v > 0, must: "> 0"),)
#let _flag = ((ok: v => type(v) == bool, must: "a boolean"),)

// What a bound measures in each family, and how a message names it.
// Strings count clusters, not bytes — JSON Schema talks "length"
// without pinning. An array arrives as the items its model keeps, each
// as (source index, item): an absent item is not among them, so the
// bounds judge what the model holds.
#let _measures = (
  string: (label: "string length ", of: v => v.clusters().len()),
  number: (label: "", of: v => v),
  array: (label: "array length ", of: v => v.len()),
)

#let _holds = (
  "≥": (n, bound) => n >= bound,
  "≤": (n, bound) => n <= bound,
  ">": (n, bound) => n > bound,
  "<": (n, bound) => n < bound,
)

// Integers stay exact; floats compare the ratio with a tolerance, since
// calc.rem(0.3, 0.1) is not 0. A ratio too large for a float (1e308 /
// 0.123...) is infinite, and no finite multiple: report it rather than
// compare the NaN its rounding leaves.
#let _multiple-test(mult, value) = {
  // A schema bug, not a data error: the translator rejects it, but a
  // hand-built node can carry it.
  if mult <= 0 {
    _bail(none, "multiple-of must be positive, got " + str(mult) + ".")
  }
  let off = if type(value) == int and type(mult) == int {
    calc.rem(value, mult) != 0
  } else {
    let q = value / mult
    q.is-infinite() or q.is-nan() or calc.abs(q - calc.round(q)) >= 1e-9
  }
  if off {
    (
      message: _expected-got("multiple of " + str(mult), str(value)),
      expected: (multiple-of: mult),
      got: value,
    )
  }
}

// The first duplicate only, cited by source positions so callers can
// find it. The items are the walked ones the model keeps, so they
// compare as the model holds them: absent items and null keys dropped,
// items coerced, and free-form objects kept as given.
#let _unique-test(on, kept) = {
  if not on { return none }
  for i in range(kept.len()) {
    for j in range(i + 1, kept.len()) {
      if kept.at(i).at(1) == kept.at(j).at(1) {
        let orig-i = kept.at(i).at(0)
        let orig-j = kept.at(j).at(0)
        return (
          message: "expected unique items, duplicate at indices "
            + str(orig-i)
            + " and "
            + str(orig-j)
            + ".",
          expected: none,
          got: (orig-i, orig-j),
        )
      }
    }
  }
  none
}

// Within a family, rows run in this order, so errors and translator
// diagnostics come out in it.
#let _constraint-rows = (
  (
    field: "min-length",
    json: "minLength",
    family: "string",
    code: "length",
    accepts: _count,
    read: int,
    op: "≥",
  ),
  (
    field: "max-length",
    json: "maxLength",
    family: "string",
    code: "length",
    accepts: _count,
    read: int,
    op: "≤",
  ),
  (
    field: "minimum",
    json: "minimum",
    family: "number",
    code: "range",
    accepts: _number,
    op: "≥",
  ),
  (
    field: "maximum",
    json: "maximum",
    family: "number",
    code: "range",
    accepts: _number,
    op: "≤",
  ),
  (
    field: "exclusive-minimum",
    json: "exclusiveMinimum",
    family: "number",
    code: "range",
    accepts: _number,
    op: ">",
  ),
  (
    field: "exclusive-maximum",
    json: "exclusiveMaximum",
    family: "number",
    code: "range",
    accepts: _number,
    op: "<",
  ),
  (
    field: "multiple-of",
    json: "multipleOf",
    family: "number",
    code: "multiple",
    accepts: _positive,
    test: _multiple-test,
  ),
  (
    field: "min-items",
    json: "minItems",
    family: "array",
    code: "items",
    accepts: _count,
    read: int,
    op: "≥",
  ),
  (
    field: "max-items",
    json: "maxItems",
    family: "array",
    code: "items",
    accepts: _count,
    read: int,
    op: "≤",
  ),
  (
    field: "unique-items",
    json: "uniqueItems",
    family: "array",
    code: "unique",
    accepts: _flag,
    test: _unique-test,
  ),
)

// Every lower bound row against every upper one of its family, by upper
// in row order: a pair must leave a satisfying value, and a `strict`
// pair (an exclusive bound on either side) may not even meet.
#let _bound-pairs = {
  let pairs = ()
  for upper in _constraint-rows.filter(row => (
    row.at("op", default: none) in ("≤", "<")
  )) {
    for lower in _constraint-rows.filter(row => (
      row.family == upper.family and row.at("op", default: none) in ("≥", ">")
    )) {
      pairs.push((
        lower: lower.field,
        upper: upper.field,
        strict: lower.op == ">" or upper.op == "<",
      ))
    }
  }
  pairs
}

/// What a raw keyword value must be, if `value` is not one the row
/// accepts; none if it is.
#let _value-problem(row, value) = {
  let failed = row.accepts.find(check => not (check.ok)(value))
  if failed != none { failed.must }
}

/// The first pair on `node` that no value can satisfy, or none. Callers
/// word the diagnostic themselves.
#let _bounds-conflict(node) = _bound-pairs.find(pair => {
  let lower = node.at(pair.lower, default: none)
  let upper = node.at(pair.upper, default: none)
  (
    lower != none
      and upper != none
      and not if pair.strict { lower < upper } else { lower <= upper }
  )
})

/// `node` with the constraint values in `given` set, as the translator
/// and the constructors both read them. `given` is keyed by `key(row)`:
/// the row's JSON keyword for the translator, its field for a
/// constructor. Only `family`'s rows are read, in row order; each value
/// is stored as the row reads it, and `false` (uniqueItems' default) is
/// left off. Returns `(node, problem)`: the problem (error.typ) is the
/// first value a row does not accept, its `arg` the `key`, or bounds no
/// value satisfies, each named by its `key` with its value; or none.
#let _read-constraints(node, family, given, key) = {
  let result = node
  for row in _constraint-rows {
    if row.family != family or key(row) not in given { continue }
    let v = given.at(key(row))
    let must = _value-problem(row, v)
    if must != none {
      return (node: result, problem: _problem(key(row), must, repr(v)))
    }
    if v != false {
      result.insert(row.field, row.at("read", default: x => x)(v))
    }
  }
  let clash = _bounds-conflict(result)
  if clash == none { return (node: result, problem: none) }
  let (lower, upper) = (clash.lower, clash.upper).map(field => (
    key(_constraint-rows.find(row => row.field == field))
      + " ("
      + repr(result.at(field))
      + ")"
  ))
  let message = if clash.strict {
    lower + " and " + upper + " leave no satisfying value."
  } else { lower + " > " + upper + " is unsatisfiable." }
  (node: result, problem: (message: message))
}

/// `node` with a constructor's constraint arguments of `family` set.
/// `args` holds every constraint parameter the constructor takes, by
/// field; an argument left at none adds nothing. Panics, naming `who`
/// and the argument as the signature spells it, on a value its row
/// does not accept or on bounds no value satisfies.
#let _constrain(who, node, family, args) = {
  let given = args.pairs().filter(((_, v)) => v != none).to-dict()
  let read = _read-constraints(node, family, given, row => row.field)
  if read.problem != none { _fail(who, read.problem) }
  read.node
}

/// How `value` misses the row's constraint `bound`, as the error's
/// `(message, expected, got)`, or none when it holds.
#let _constraint-miss(row, bound, value) = {
  if "test" in row { return (row.test)(bound, value) }
  let measure = _measures.at(row.family)
  let n = (measure.of)(value)
  if not (_holds.at(row.op))(n, bound) {
    (
      message: _expected-got(
        measure.label + row.op + " " + str(bound),
        str(n),
      ),
      expected: ((row.field): bound),
      got: n,
    )
  }
}

/// Every constraint row of `family` that `schema` sets, checked against
/// `value`, as error records at `path`, in row order.
#let _constraint-errors(schema, family, value, path) = {
  let errs = ()
  for row in _constraint-rows {
    let bound = schema.at(row.field, default: none)
    if row.family != family or bound == none { continue }
    let miss = _constraint-miss(row, bound, value)
    if miss != none {
      errs += _error(
        path,
        row.code,
        miss.message,
        expected: miss.expected,
        got: miss.got,
      )
    }
  }
  errs
}
