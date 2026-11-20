// The constraint keywords, one row each. A row ties a node field to
// its JSON Schema keyword, the family of values it applies to, the
// error code a miss reports, and which raw keyword values the
// translator accepts (and, as `read`, how it stores one when that is
// not the value itself). A bound (`op`) is checked against the family's
// measure; the two keywords that are not bounds carry a `test`. The
// engine, the translator's reader, its allow-list and its enum/const
// fold all read these rows, so a new keyword is one row.

#import "../core/error.typ": _error, _expected-got, _problem, _fail, _num

// Which raw values a keyword takes, as checks run in order; the first
// that fails names what the value must be. A count may be a float with
// no fractional part (`2.0`), as draft 7's `integer` allows; its row's
// `read` stores it as an int, so it must fit one (below 2^63).
#let _whole(v) = (
  type(v) == int
    or (type(v) == float and not v.is-infinite() and calc.fract(v) == 0)
)
#let _count = (
  (ok: v => _whole(v) and v >= 0, must: "a non-negative integer"),
  (ok: v => type(v) == int or v < calc.pow(2.0, 63), must: "below 2^63"),
)
#let _number = (
  (
    ok: v => (
      type(v) in (int, decimal) or (type(v) == float and not v.is-nan())
    ),
    must: "a number",
  ),
)
// A multiple of ∞ would take every finite value (their ratio is 0).
#let _positive = (
  _number
    + (
      (ok: v => v > 0, must: "> 0"),
      (ok: v => type(v) != float or not v.is-infinite(), must: "finite"),
    )
)
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

// Every decimal lies strictly within ±2^96 and on a grid of 1e-28.
#let _decimal-limit = calc.pow(2.0, 96)

// A float as the decimal it is written as, so a decimal value compares
// with it at its own precision: `str(1.6)` is "1.6", where `decimal(1.6)`
// is the float's binary value, 1.60000000000000008…. None when no
// decimal is that number: past ±2^96, or with more than 28 decimal
// places, or a NaN. (`str` never writes an exponent.)
#let _as-decimal(f) = {
  if f.is-nan() or f.is-infinite() or calc.abs(f) >= _decimal-limit {
    return none
  }
  let t = str(f)
  if t.split(".").at(1, default: "").len() > 28 { return none }
  decimal(t)
}

// A decimal `n` against a float bound under `op`, as the (n, op, bound)
// to compare exactly. A bound a decimal is compares as one. One past
// ±2^96 lies on the same side of every decimal as of 0, so 0 stands in
// for `n`. One between two points of the 1e-28 grid moves to the point
// below it, g: `n ≥ b` and `n > b` both read `n > g`, and `n ≤ b` and
// `n < b` both read `n ≤ g`.
#let _decimal-against(n, op, f) = {
  let d = _as-decimal(f)
  if d != none { return (n, op, d) }
  if f.is-infinite() or calc.abs(f) >= _decimal-limit { return (0, op, f) }
  // Its first 28 places, toward zero, then down one step if negative.
  let (whole, places) = str(f).split(".")
  let g = decimal(whole + "." + places.slice(0, 28))
  if f < 0 { g -= decimal("0.0000000000000000000000000001") }
  if op in ("≥", ">") { (n, ">", g) } else { (n, "≤", g) }
}

// `a op b` for any two of int, float and decimal, none of them NaN. A
// decimal compares with an int, but not with a float, and an int past
// 2^53 compares with a float only after rounding to one: either pair
// compares as _decimal-against reads it, as decimals, the float on the
// right. Any other pair compares natively.
#let _mirror = ("≥": "≤", ">": "<", "≤": "≥", "<": ">")
#let _float-exact = calc.pow(2, 53)
// An int or decimal a float can't stand in for exactly, as a decimal,
// or none: a decimal always, an int only past 2^53.
#let _unfloatable(v) = if type(v) == decimal { v } else if (
  type(v) == int and (v > _float-exact or v < -_float-exact)
) { decimal(v) }
#let _compare(a, op, b) = {
  let (m, o, c) = if type(b) == float and _unfloatable(a) != none {
    _decimal-against(_unfloatable(a), op, b)
  } else if type(a) == float and _unfloatable(b) != none {
    _decimal-against(_unfloatable(b), _mirror.at(op), a)
  } else { (a, op, b) }
  (_holds.at(o))(m, c)
}

/// `v` with every float in it, nested ones too, as the decimal it is
/// written as (`1.5` as `decimal("1.5")`), so `==` compares a float and
/// a decimal as the bounds do; it already takes `1` for `1.0`. A float
/// no decimal can hold stays a float.
#let _comparable(v) = if type(v) == float {
  let d = _as-decimal(v)
  if d == none { v } else { d }
} else if type(v) == array { v.map(_comparable) } else if (
  type(v) == dictionary
) { v.pairs().map(((k, x)) => (k, _comparable(x))).to-dict() } else { v }

// A value and a multiple that are each an int, a decimal or a float a
// decimal can hold compare exactly, as decimals: calc.rem(0.3, 0.1) is
// not 0, but the decimals 0.3 and 0.1 divide evenly. Anything else (a
// float past ±2^96 or with more than 28 places) compares the float
// ratio with a tolerance relative to it. A ratio too large for a float
// (1e308 / 0.123...) is infinite, and no finite multiple: report it
// rather than compare the NaN its rounding leaves. A NaN or infinite
// value never gets here: it is a `type` miss (leaf.typ).
#let _exact(v) = if type(v) == float { _as-decimal(v) } else { v }
#let _multiple-test(mult, value) = {
  let (m, v) = (_exact(mult), _exact(value))
  let off = if m != none and v != none { calc.rem(v, m) != 0 } else {
    let q = float(value) / float(mult)
    (
      q.is-infinite() or calc.abs(q - calc.round(q)) > 1e-9 * calc.abs(q)
    )
  }
  if off {
    (
      message: _expected-got("multiple of " + _num(mult), _num(value)),
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
  // The pair cited is the first item with a later duplicate, and that
  // duplicate's nearest copy. Strings key a dictionary, and ints too by
  // their repr, which tells `"1"` from `1`, so one right-to-left pass
  // holding each key's nearest later index finds it. Other values
  // compare as _comparable writes them, with `==` natively in `contains`
  // and `position`, over a copied suffix per item: quadratic, but only
  // where a float may equal an int or a decimal.
  let vals = kept.map(((_, v)) => v)
  let (i, j) = if vals.all(v => type(v) in (str, int)) {
    let keys = if vals.all(v => type(v) == str) { vals } else {
      vals.map(repr)
    }
    let later = (:)
    let pair = (none, none)
    for k in range(keys.len() - 1, -1, step: -1) {
      let key = keys.at(k)
      if key in later { pair = (k, later.at(key)) }
      later.insert(key, k)
    }
    pair
  } else {
    let vals = vals.map(_comparable)
    let i = range(vals.len()).find(i => vals.slice(i + 1).contains(vals.at(i)))
    if i == none { (none, none) } else {
      (i, i + 1 + vals.slice(i + 1).position(v => v == vals.at(i)))
    }
  }
  if i == none { return none }
  let (orig-i, orig-j) = (kept.at(i).at(0), kept.at(j).at(0))
  (
    message: "expected unique items, duplicate at indices "
      + str(orig-i)
      + " and "
      + str(orig-j)
      + ".",
    expected: none,
    got: (orig-i, orig-j),
  )
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

// Whole-number rounding, float-safe, so a bound past the int range
// needs no conversion.
#let _trunc(v) = v - calc.fract(v)
#let _ceil(v) = _trunc(v) + if calc.fract(v) > 0 { 1 } else { 0 }
#let _floor(v) = _trunc(v) - if calc.fract(v) < 0 { 1 } else { 0 }

// `v + d` for a step of one: exact in int, and in float only where the
// int step would overflow, at the largest or smallest int. (A float
// step anywhere near the limit rounds to a multiple of 1024, and could
// land past the other bound.)
#let _int-max = 9223372036854775807
#let _int-min = -_int-max - 1
#let _step(v, d) = if (
  type(v) == int and ((d > 0 and v == _int-max) or (d < 0 and v == _int-min))
) { float(v) + d } else { v + d }

// The nearest whole number a bound of each `op` lets through.
#let _whole-bound = (
  "≥": _ceil,
  ">": v => _step(_floor(v), 1),
  "≤": _floor,
  "<": v => _step(_ceil(v), -1),
)

/// The fields of an integer node's bounds that leave no whole number:
/// a lower bound of +∞ or an upper bound of -∞ on its own, or the
/// tightest lower and upper bound when no whole number lies between
/// them (`minimum: 1.5, maximum: 1.7`); none otherwise. A lower bound of
/// -∞ or an upper bound of +∞ restricts nothing.
#let _integer-gap(node) = {
  if node.at("kind", default: none) != "integer" { return none }
  let bounds(ops) = _constraint-rows.filter(row => (
    row.at("op", default: none) in ops and row.field in node
  ))
  let infinite(row) = (
    type(node.at(row.field)) == float and node.at(row.field).is-infinite()
  )
  let (lows, highs) = (bounds(("≥", ">")), bounds(("≤", "<")))
  let blocking = (
    lows.filter(r => infinite(r) and node.at(r.field) > 0)
      + highs.filter(r => infinite(r) and node.at(r.field) < 0)
  )
  if blocking != () { return (blocking.first().field,) }
  let tightest(rows, pick) = {
    let found = rows
      .filter(row => not infinite(row))
      .map(row => (row.field, _whole-bound.at(row.op)(node.at(row.field))))
    // The bounds may mix floats and decimals, which don't sort together.
    found.fold(none, (acc, p) => if (
      acc == none or _compare(p.at(1), pick, acc.at(1))
    ) { p } else { acc })
  }
  // The largest lower bound, the last in row order on a tie, and the
  // smallest upper one, the first.
  let lower = tightest(lows, "≥")
  let upper = tightest(highs, "<")
  if (
    lower != none and upper != none and _compare(lower.at(1), ">", upper.at(1))
  ) {
    (lower.at(0), upper.at(0))
  }
}

/// The first pair on `node` that no value can satisfy, or none. Callers
/// word the diagnostic themselves.
#let _bounds-conflict(node) = _bound-pairs.find(pair => {
  let lower = node.at(pair.lower, default: none)
  let upper = node.at(pair.upper, default: none)
  (
    lower != none
      and upper != none
      and not _compare(lower, if pair.strict { "<" } else { "≤" }, upper)
  )
})

/// The problems with the bounds `node` sets, as `(problem, gap)`: bounds
/// no value satisfies, and an integer node's bounds that hold numbers but
/// no integer, each named by `key(row)` with its value; or none. The gap
/// is reported apart, so a translated `type` list can drop its integer
/// member alone. The schema check passes only a node's kind and bounds,
/// so this never hashes a subtree.
#let _bounds-problems(node, key) = {
  let named(field) = (
    key(_constraint-rows.find(row => row.field == field))
      + " ("
      + repr(node.at(field))
      + ")"
  )
  let clash = _bounds-conflict(node)
  // A number's lower bound of +∞ or upper bound of -∞ leaves only an
  // infinity, which no JSON number is. (An integer's says so as a gap.)
  let past = if node.at("kind", default: none) == "number" {
    _constraint-rows.find(row => {
      let v = node.at(row.field, default: none)
      let op = row.at("op", default: none)
      (
        type(v) == float
          and v.is-infinite()
          and ((op in ("≥", ">") and v > 0) or (op in ("≤", "<") and v < 0))
      )
    })
  }
  let message = if clash != none {
    let (lower, upper) = (clash.lower, clash.upper).map(named)
    if clash.strict {
      lower + " and " + upper + " leave no satisfying value."
    } else { lower + " > " + upper + " is unsatisfiable." }
  } else if past != none { named(past.field) + " leaves no finite number." }
  let gap = if clash == none { _integer-gap(node) }
  (
    problem: if message != none { (message: message) },
    gap: if gap != none {
      (
        message: gap.map(named).join(" and ")
          + if gap.len() == 1 { " leaves" } else { " leave" }
          + " no integer.",
      )
    },
  )
}

/// `node` with the constraint values in `given` set, as the translator
/// and the constructors both read them. `given` is keyed by `key(row)`:
/// the row's JSON keyword for the translator, its field for a
/// constructor. Only `family`'s rows are read, in row order; each value
/// is stored as the row reads it, and `false` (uniqueItems' default) is
/// left off. Returns `(node, problem, gap)`: the problem (error.typ) is
/// the first value a row does not accept, its `arg` the `key`, or bounds
/// no value satisfies, each named by its `key` with its value; or none.
/// `gap` is the problem of an integer node whose bounds hold numbers but
/// no integer, or none.
#let _read-constraints(node, family, given, key) = {
  let result = node
  for row in _constraint-rows {
    if row.family != family or key(row) not in given { continue }
    let v = given.at(key(row))
    let must = _value-problem(row, v)
    if must != none {
      return (
        node: result,
        problem: _problem(key(row), must, repr(v)),
        gap: none,
      )
    }
    if v != false {
      result.insert(row.field, row.at("read", default: x => x)(v))
    }
  }
  (node: result, .._bounds-problems(result, key))
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
  if read.gap != none { _fail(who, read.gap) }
  read.node
}

/// How `value` misses the row's constraint `bound`, as the error's
/// `(message, expected, got)`, or none when it holds.
#let _constraint-miss(row, bound, value) = {
  if "test" in row { return (row.test)(bound, value) }
  let measure = _measures.at(row.family)
  let n = (measure.of)(value)
  if not _compare(n, row.op, bound) {
    (
      message: _expected-got(
        measure.label + row.op + " " + _num(bound),
        _num(n),
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
