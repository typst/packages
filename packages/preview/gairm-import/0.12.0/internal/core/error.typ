// Every validation error carries one of these codes. Engine logic
// branches on the code, never on message text.
#let _codes = (
  "type",
  "required",
  "unknown-key",
  "dependent",
  "enum",
  "format",
  "pattern",
  "length",
  "range",
  "multiple",
  "integer",
  "items",
  "unique",
  "union",
  "not",
)

/// Panics with `msg` as `who` says it: the public function (or its
/// argument) the problem concerns, or none for the package itself.
#let _bail(who, msg) = panic(
  "gairm-import: " + if who != none { who + " " } + msg,
)

/// Asserts a package invariant: a failure is a bug in gairm-import, not
/// in the caller's input.
#let _internal(ok, msg) = assert(
  ok,
  message: "gairm-import: internal — " + msg,
)

/// `"expected <expected>, got <got>."`, as every message that compares
/// what a check wanted with what it found says it.
#let _expected-got(expected, got) = (
  "expected " + expected + ", got " + got + "."
)

/// `"<what> not in <where>[: <names, …>]. <label>: <valid, …>."`, for
/// names an edit or a lens path may not use: `what` names one, or
/// introduces the list `names`.
#let _not-in(what, where, label, valid, names: none) = (
  what
    + " not in "
    + where
    + if names != none { ": " + names.join(", ") }
    + ". "
    + label
    + ": "
    + valid.join(", ")
    + "."
)

/// One validation error, as a one-element array so results concatenate.
#let _error(path, code, message, expected: none, got: none) = {
  _internal(code in _codes, "unknown error code " + repr(code))
  ((path: path, code: code, message: message, expected: expected, got: got),)
}

// Empty path renders as "<root>" so a top-level type error reads
// `"<root>: expected object, got …"`.
#let _format-path(parts) = {
  if parts.len() == 0 { return "<root>" }
  parts
    .enumerate()
    .map(((i, part)) => {
      if type(part) == int { "[" + str(part) + "]" } else if i == 0 {
        part
      } else { "." + part }
    })
    .join("")
}

// Typst's `repr(type(...))` renders as `"int"` / `"dictionary"` /
// `"type(none)"` — accurate but jarring. Translate to JSON-shaped
// names for user-facing messages; unknown reprs fall through.
#let _type-names = (
  str: "string",
  int: "integer",
  float: "number",
  bool: "boolean",
  array: "array",
  dictionary: "object",
)

// A null reaches a type check only in strict-null mode, where every
// kind but null-type rejects it ("got null").
#let _type-name-of(value) = {
  if value == none { return "null" }
  let raw = repr(type(value))
  _type-names.at(raw, default: raw)
}

/// A JSON type name per value, with int and float as the one number
/// type JSON has.
#let _json-type-name(value) = {
  if type(value) in (int, float) { "number" } else { _type-name-of(value) }
}

/// A walk result for a value of the wrong JSON type: the `type` error,
/// and no model, so coerce panics naming the type with its article ("a
/// string", "an array"; null takes none).
#let _type-miss(path, expected, value) = {
  let got = _type-name-of(value)
  let noun = if expected == "null" { expected } else if (
    expected.first() in "aeiou"
  ) { "an " + expected } else { "a " + expected }
  (
    errors: _error(
      path,
      "type",
      _expected-got(expected, got),
      expected: expected,
      got: got,
    ),
    value: value,
    fatal: (path: path, expected: noun, got: value),
  )
}

/// What `coerce` panics with where a value leaves no sound model, at
/// data path `path`. `expected` is the noun phrase ("a string", "an
/// array", …).
#let _coerce-message(path, expected, value) = (
  "coerce at "
    + _format-path(path)
    + ": "
    + _expected-got(expected, _type-name-of(value))
    + " Run validate(data) first."
)

// A check on an argument returns a problem, or none, rather than
// panicking, so each caller words it in its own terms: a constructor
// names its parameter (`string() format must be …`), the translator the
// JSON keyword it read (`"format" must be …`). A problem says what the
// argument `arg` `must` be and what it `got` (rendered), with the key
// whose entry failed (`entry`) and a Typst-side `hint` only constructors
// print; or it is a whole `message`, when it isn't a "must be".
#let _problem(arg, must, got, entry: none, hint: none) = (
  arg: arg,
  must: must,
  got: got,
  entry: entry,
  hint: hint,
)

/// `p` worded with `name` standing for its argument.
#let _worded(p, name) = {
  if "message" in p { return p.message }
  (
    name
      + if p.entry != none { " for " + repr(p.entry) }
      + " must be "
      + p.must
      + ", got: "
      + p.got
      + "."
  )
}

/// Panics with `p` as constructor `who` words it.
#let _fail(who, p) = _bail(
  who,
  _worded(p, p.at("arg", default: none)) + p.at("hint", default: none),
)

/// A problem unless `value` is an array whose every item passes
/// `item-ok`; `what` is what it must be. No list argument accepts a lone
/// item: a string is iterable in spirit only, so taking one would read
/// `"ab"` as a key here and as the letters elsewhere. A string gets the
/// one-item spelling as a hint instead.
#let _array-problem(value, arg, what, one, item-ok: _ => true, entry: none) = {
  if type(value) == array and value.all(item-ok) { return none }
  _problem(
    arg,
    what,
    repr(value),
    entry: entry,
    hint: if type(value) == str {
      " Write (" + repr(value) + ",) for one " + one + "."
    },
  )
}

/// `_array-problem` for a list of object keys.
#let _key-names-problem(value, arg, entry: none) = _array-problem(
  value,
  arg,
  "an array of key names",
  "key",
  item-ok: k => type(k) == str,
  entry: entry,
)

/// Panics, as `who` words it, unless argument `arg` is a list of keys.
#let _require-key-names(value, who, arg) = {
  let p = _key-names-problem(value, arg)
  if p != none { _fail(who, p) }
}

#let _format-report(errors) = {
  let n = errors.len()
  let noun = if n == 1 { "problem" } else { "problems" }
  let lines = errors.map(e => "  - " + _format-path(e.path) + ": " + e.message)
  (
    "gairm-import: found "
      + str(n)
      + " "
      + noun
      + " in the input:\n"
      + lines.join("\n")
  )
}

/// Panics with the report of `errors`, as parse does on an invalid input.
#let _panic-report(errors) = panic(_format-report(errors))

// Classic two-row Levenshtein edit distance. We fold over the
// characters of `a`, carrying the previous DP row and producing the
// next. Each new row is itself built by folding over the characters
// of `b`, since cell `(i, j)` depends on `(i-1, j)`, `(i, j-1)` and
// `(i-1, j-1)`. The base row is `0..n` (cost of deleting `j` chars
// from `b` to reach the empty prefix of `a`).
#let _edit-distance(a, b) = {
  let ac = a.clusters()
  let bc = b.clusters()
  let n = bc.len()
  let final-row = ac
    .enumerate()
    .fold(range(0, n + 1), (prev, (i, ca)) => {
      bc
        .enumerate()
        .fold((i + 1,), (row, (j, cb)) => {
          let cost = if ca == cb { 0 } else { 1 }
          (
            row
              + (
                calc.min(
                  prev.at(j + 1) + 1, // deletion
                  row.at(j) + 1, // insertion
                  prev.at(j) + cost, // substitution
                ),
              )
          )
        })
    })
  final-row.at(n)
}

// Pure: pick the candidate closest to `target` by edit distance, or
// `none` if the best is outside `max-distance` (inclusive) or
// `candidates` is empty. Single-pass fold — strict `<` keeps the
// first-seen winner on ties, so the schema's declaration order
// decides equidistant matches.
#let _closest-match(target, candidates, max-distance) = {
  let best = candidates.fold(none, (acc, c) => {
    let d = _edit-distance(target, c)
    if acc == none or d < acc.distance { (key: c, distance: d) } else { acc }
  })
  if best != none and best.distance <= max-distance { best.key } else { none }
}
