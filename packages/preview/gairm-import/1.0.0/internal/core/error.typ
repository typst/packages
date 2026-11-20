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

/// `word` with its indefinite article: "a string", "an integer", "a
/// union" (a vowel letter with a consonant sound).
#let _a(word) = {
  let vowel = word.first() in "aeiou" and not word.starts-with("uni")
  (if vowel { "an " } else { "a " }) + word
}

/// One validation error, as a one-element array so results concatenate.
#let _error(path, code, message, expected: none, got: none) = {
  _internal(code in _codes, "unknown error code " + repr(code))
  ((path: path, code: code, message: message, expected: expected, got: got),)
}

/// A number as a message writes it: an ASCII minus, where `str` writes
/// U+2212, a float in its shortest form (`1e300`, not 301 digits), and
/// a NaN or an infinity as JavaScript writes it, not as `float.nan`.
#let _num(v) = if type(v) == float {
  if v.is-nan() { "NaN" } else if v.is-infinite() {
    if v > 0 { "Infinity" } else { "-Infinity" }
  } else { repr(v) }
} else {
  str(v).replace("\u{2212}", "-")
}

// A control character, as a JSON string escapes it.
#let _json-escapes = (
  "\n": "\\n",
  "\r": "\\r",
  "\t": "\\t",
  "\u{8}": "\\b",
  "\u{c}": "\\f",
)
#let _control = regex("[\u{0}-\u{1f}]")
#let _json-escape(c) = _json-escapes.at(c, default: {
  let hex = str(c.to-unicode(), base: 16)
  "\\u" + "0" * (4 - hex.len()) + hex
})

/// `v` as JSON writes it, so a message quotes a value in the syntax of
/// the data it came from: `[1]`, `null`, `{"type": "string"}`. A value
/// JSON has no syntax for (a regex, a datetime) keeps its repr.
#let _json(v) = if v == none { "null" } else if type(v) == bool {
  if v { "true" } else { "false" }
} else if type(v) in (int, float, decimal) { _num(v) } else if (
  type(v) == str
) {
  (
    "\""
      + v
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace(_control, m => _json-escape(m.text))
      + "\""
  )
} else if type(v) == array {
  "[" + v.map(_json).join(", ", default: "") + "]"
} else if type(v) == dictionary {
  (
    "{"
      + v
        .pairs()
        .map(((k, x)) => _json(k) + ": " + _json(x))
        .join(", ", default: "")
      + "}"
  )
} else { repr(v) }

// A key that reads unambiguously after a dot: a letter or `_`, then
// letters, digits, `_` and `-`.
#let _plain-key = regex("^[\\p{L}_][\\p{L}\\p{N}_-]*$")

/// `key` as a label shows it: as written when it reads unambiguously,
/// quoted otherwise, so an empty or dotted key is still visible.
#let _key-label(key) = if key.match(_plain-key) != none { key } else {
  repr(key)
}

/// `"<what> not in <where>[: <names, …>]. <label>: <valid, …>."`, for
/// key names an edit or a schema path may not use: `what` names one, or
/// introduces the list `names`. Each name is labelled as a path shows
/// it, so an empty key or one holding `, ` still reads as one.
#let _not-in(what, where, label, valid, names: none) = (
  what
    + " not in "
    + where
    + if names != none { ": " + names.map(_key-label).join(", ") }
    + ". "
    + label
    + ": "
    + valid.map(_key-label).join(", ", default: "none")
    + "."
)

// A data path as a reader writes it: `work[0].name`. A key that is not
// plain is quoted in brackets, `["a.b"].c`, so no two paths read the
// same; the empty path renders as "<root>", so a top-level type error
// reads `"<root>: expected object, got …"`.
#let _format-path(parts) = {
  if parts.len() == 0 { return "<root>" }
  parts
    .enumerate()
    .map(((i, part)) => {
      if type(part) == int { "[" + _num(part) + "]" } else if (
        part.match(_plain-key) == none
      ) { "[" + repr(part) + "]" } else if i == 0 { part } else { "." + part }
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
  decimal: "number",
  bool: "boolean",
  array: "array",
  dictionary: "object",
)

// A null reaches a type check only in strict-null mode, where every
// kind but null() rejects it ("got null"). A NaN or an infinity is no
// JSON number, so it is named as itself.
#let _type-name-of(value) = {
  if value == none { return "null" }
  if type(value) == float and (value.is-nan() or value.is-infinite()) {
    return _num(value)
  }
  let raw = repr(type(value))
  _type-names.at(raw, default: raw)
}

/// A JSON type name per value, with int, float and decimal as the one
/// number type JSON has.
#let _json-type-name(value) = {
  if type(value) in (int, float, decimal) { "number" } else {
    _type-name-of(value)
  }
}

/// A walk result for a value of the wrong JSON type: the `type` error,
/// and no model, so coerce panics naming the type with its article ("a
/// string", "an array"; null takes none).
#let _type-miss(path, expected, value) = {
  let got = _type-name-of(value)
  let noun = if expected == "null" { expected } else { _a(expected) }
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

/// `value` as a message shows it where its type is not the problem (an
/// enum miss): a scalar as JSON writes it, anything else by its type
/// name.
#let _shown(value) = if type(value) in (int, float, decimal, str, bool) {
  _json(value)
} else { _type-name-of(value) }

/// What `coerce` panics with where a value leaves no sound model, at
/// data path `path`. `expected` is the noun phrase ("a string", "an
/// array", …); the value is named by `shown` when the fatal gives it,
/// and by its type otherwise.
#let _coerce-message(path, expected, value, shown: none) = (
  "coerce at "
    + _format-path(path)
    + ": "
    + _expected-got(
      expected,
      if shown != none { shown } else { _type-name-of(value) },
    )
    + " Run validate(schema, data) first."
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

/// `p` worded with `name` standing for its argument, or with no name
/// when the caller's `who` already names it (`array-of() elem`).
#let _worded(p, name) = {
  if "message" in p { return p.message }
  (
    (if name != none { name + " " })
      + (if p.entry != none { "for " + repr(p.entry) + " " })
      + "must be "
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

/// Panics, as `who` words it, unless argument `arg` is true or false.
#let _require-bool(value, who, arg) = {
  if type(value) != bool {
    _fail(who, _problem(arg, "true or false", repr(value)))
  }
}

/// Panics, as `who` words it, unless argument `arg` is a list of keys.
#let _require-key-names(value, who, arg) = {
  let p = _key-names-problem(value, arg)
  if p != none { _fail(who, p) }
}

#let _format-report(errors) = {
  let n = errors.len()
  if n == 0 { return "gairm-import: found no problems in the input." }
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

// Levenshtein edit distance, capped: `limit + 1` stands for anything
// further. Only the cells within `limit` of the diagonal can hold a
// distance within it, so a row is that band alone, and a row whose best
// cell is past it ends the search: a long key costs linear time, not
// quadratic. Loops, not folds: this runs once per unknown key per field.
#let _clusters(s) = s.clusters()
#let _edit-distance(a, b, limit) = {
  let (ac, bc) = (_clusters(a), _clusters(b))
  let (m, n) = (ac.len(), bc.len())
  let far = limit + 1
  if calc.abs(m - n) > limit { return far }
  // Within `limit` edits of a longer `a`, one of its first `limit + 1`
  // clusters survives unedited, within `limit` places of where it was, so
  // it is among b's first `2 limit + 1`; the same holds at the end. A
  // cheap test that rules out most unrelated keys before the table.
  if m > limit {
    let w = 2 * limit + 1
    let head = bc.slice(0, calc.min(w, n))
    let tail = bc.slice(calc.max(0, n - w))
    if not ac.slice(0, limit + 1).any(c => c in head) { return far }
    if not ac.slice(m - limit - 1).any(c => c in tail) { return far }
  }
  // Each row keeps only its band: row i's slot t is column
  // j = i - limit + t, so row i - 1's slot t + 1 is the column above and
  // slot t the one diagonally above. A column outside 0..n is `far`.
  let w = 2 * limit + 1
  let prev = range(w).map(t => {
    let j = t - limit
    if j < 0 or j > n { far } else { calc.min(j, far) }
  })
  for i in range(1, m + 1) {
    let row = ()
    let best = far
    for t in range(w) {
      let j = i - limit + t
      let d = if j < 0 or j > n { far } else if j == 0 {
        calc.min(i, far)
      } else {
        let cost = if ac.at(i - 1) == bc.at(j - 1) { 0 } else { 1 }
        calc.min(
          (if t + 1 < w { prev.at(t + 1) } else { far }) + 1, // deletion
          (if t > 0 { row.at(t - 1) } else { far }) + 1, // insertion
          prev.at(t) + cost, // substitution
          far,
        )
      }
      row.push(d)
      best = calc.min(best, d)
    }
    if best > limit { return far }
    prev = row
  }
  prev.at(n - m + limit)
}

// Pure: pick the candidate closest to `target` by edit distance, or
// `none` if the best is too far or `candidates` is empty. Too far is
// more than 2 edits, or more than 1 for a target of up to three
// characters, where 2 edits reach almost any short key (`a` → `id`).
// Single-pass fold — strict `<` keeps the first-seen winner on ties,
// so the schema's declaration order decides equidistant matches.
#let _closest-match(target, candidates) = {
  let max-distance = if target.clusters().len() <= 3 { 1 } else { 2 }
  let best = candidates.fold(none, (acc, c) => {
    let d = _edit-distance(target, c, max-distance)
    if acc == none or d < acc.distance { (key: c, distance: d) } else { acc }
  })
  if best != none and best.distance <= max-distance { best.key } else { none }
}
