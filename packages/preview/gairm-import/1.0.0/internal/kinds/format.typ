// The string formats, one row each. A row is everything the package
// knows about a format: its JSON Schema `format` name, which a string
// node carries as its `format` field, the regex that gates it (and, as
// `real`, any check a regex can't state), the hint an error shows.
// Only `date` also takes a Typst `datetime` (below): a datetime has no
// offset, so it can't be a `date-time`.
// The engine's string check, string() and the translator all read this
// table, so adding a format is one row.

#import "../core/error.typ": _error, _expected-got, _type-miss, _problem, _fail
#import "leaf.typ": _pattern-errors, _pattern-check
#import "constraint.typ": _constrain

// IPv6 is spelled as the eight-group form plus each place a single `::`
// can sit: `h` is one 1-4 digit hex group, and every alternative below
// is "n groups, `::`, m groups" with n + m <= 7. Embedded-IPv4 tails
// (`::ffff:1.2.3.4`) are not accepted.
#let _hex-group = "[0-9A-Fa-f]{1,4}"
#let _ipv6-pattern = {
  let h = _hex-group
  let alternatives = (
    h + "(?::" + h + "){7}",
    "(?:" + h + ":){1,7}:",
    "(?:" + h + ":){1,6}:" + h,
    // Up to n groups, `::`, up to 7 - n groups, for n = 2..5.
    ..range(2, 6).map(n => (
      "(?:" + h + ":){1," + str(n) + "}(?::" + h + "){1," + str(7 - n) + "}"
    )),
    h + ":(?::" + h + "){1,6}",
    ":(?::" + h + "){1,7}",
    "::",
  )
  "^(?:" + alternatives.join("|") + ")$"
}

// One DNS label (1-63 characters, no leading or trailing hyphen) and one
// IPv4 octet (0-255, no leading zeros), each used twice below.
#let _label = "[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
#let _octet = "(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])"

// A time of day as RFC 3339's `full-time`: `HH:MM:SS`, an optional
// fraction, then an offset, `Z` (either case) or `±HH:MM`. Second 60 (a
// leap second) is let through where one can fall — at minute 59, or at
// any minute under an offset with minutes (UTC 23:59:60 at +01:30 is
// 01:29:60). Which hour is not checked.
#let _clock = {
  let hour = "([01][0-9]|2[0-3])"
  let fraction = "(\.[0-9]+)?"
  let offset-hour = "[+-]([01][0-9]|2[0-3]):"
  let offset = "([Zz]|" + offset-hour + "[0-5][0-9])"
  (
    "(?:"
      + hour
      + ":([0-5][0-9]:[0-5][0-9]|59:60)"
      + fraction
      + offset
      + "|"
      + hour
      + ":[0-5][0-9]:60"
      + fraction
      + offset-hour
      + "(0[1-9]|[1-5][0-9]))"
  )
}

// A `YYYY-MM-DD` prefix is a day its month has (RFC 3339 §5.7):
// February has a 29th only in a leap year. The regex has already
// checked the digits, so the slices read.
#let _days-in-month = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
#let _real-date(s) = {
  let (y, m, d) = (int(s.slice(0, 4)), int(s.slice(5, 7)), int(s.slice(8, 10)))
  let leap = (
    calc.rem(y, 4) == 0 and (calc.rem(y, 100) != 0 or calc.rem(y, 400) == 0)
  )
  d <= _days-in-month.at(m - 1) + if m == 2 and leap { 1 } else { 0 }
}

// `date`, `date-time` and `time` are RFC 3339's `full-date`,
// `date-time` and `full-time`, as draft 7 defines them: a row's `real`
// check, after its regex, rejects a day its month lacks. The others are
// deliberately permissive: they reject obvious malformations without a
// full RFC grammar. The hint omits the offending value — the path
// already names the field, and the canonical example is the actionable
// part.
#let _format-rows = (
  (
    format: "date",
    pattern: regex(
      "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$",
    ),
    real: _real-date,
    expected: "an RFC 3339 date (e.g. \"2024-01-15\")",
  ),
  (
    format: "date-time",
    pattern: regex(
      "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[Tt]" + _clock + "$",
    ),
    real: _real-date,
    expected: "an RFC 3339 date-time (e.g. \"2024-01-15T10:00:00Z\")",
  ),
  (
    format: "uri",
    // Any scheme, then no whitespace; a `//` authority must not be
    // empty, so `https://` alone still fails.
    pattern: regex("^[A-Za-z][A-Za-z0-9+.\-]*:(//\S+|/?[^/\s]\S*)$"),
    expected: "a URI (e.g. \"https://example.com\")",
  ),
  (
    format: "email",
    // An unquoted local part without whitespace, or a quoted one; a
    // domain of one or more labels, or an address literal in brackets
    // (`[127.0.0.1]`, `[IPv6:::1]`).
    pattern: regex(
      "^([^@\s\"]+|\"([^\"\\\\]|\\\\.)+\")@([^@\s.\[\]]+(\.[^@\s.\[\]]+)*|\[[^\[\]\s]+\])$",
    ),
    expected: "an email (e.g. \"name@example.com\")",
  ),
  (
    format: "uuid",
    pattern: regex(
      "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$",
    ),
    expected: "a UUID (e.g. \"123e4567-e89b-12d3-a456-426614174000\")",
  ),
  (
    format: "hostname",
    pattern: regex("^" + _label + "(\." + _label + ")*$"),
    expected: "a hostname (e.g. \"example.com\")",
  ),
  (
    format: "ipv4",
    pattern: regex("^" + _octet + "(\." + _octet + "){3}$"),
    expected: "an IPv4 address (e.g. \"192.0.2.1\")",
  ),
  (
    format: "ipv6",
    pattern: regex(_ipv6-pattern),
    expected: "an IPv6 address (e.g. \"2001:db8::1\")",
  ),
  (
    format: "time",
    pattern: regex("^" + _clock + "$"),
    expected: "an RFC 3339 time (e.g. \"10:00:00Z\")",
  ),
)

// Format name → row, for the engine and coerce; the keys are the
// formats string() and the translator take.
#let _formats = _format-rows.map(row => (row.format, row)).to-dict()

// The string constructor lives here, beside the format table its
// `format:` reads; its length parameters are the string rows' fields
// (constraint.typ), checked by _constrain as number() checks its own.
// A format and a pattern are fields on the node, the pattern with the
// hint its error shows, so a formatted or patterned string is still
// the string kind. `format:` and `pattern:` compose as the translator
// composes `format` and `pattern`: the format with an extra pattern
// gate.

/// The first problem (error.typ) with string()'s `format`, `pattern`
/// and `expected` arguments, or none. The translator words it for the
/// JSON keywords of the same names.
#let _string-problem(format: none, pattern: none, expected: none) = {
  if format != none and (type(format) != str or format not in _formats) {
    let names = _formats.keys().map(repr)
    return _problem("format", "one of " + names.join(", "), repr(format))
  }
  // An argument, so a hand-built node's problem names its field.
  if expected != none and pattern == none {
    return _problem(
      "expected",
      "given with a pattern, which it describes",
      repr(expected),
    )
  }
  if pattern != none and type(pattern) not in (regex, str) {
    return _problem("pattern", "a regex or a string", repr(pattern))
  }
  if expected != none and type(expected) != str {
    return _problem("expected", "a string", repr(expected))
  }
}

/// A string, with an optional format, pattern and length bounds. An
/// argument left at `none` sets nothing, so `string()` is
/// `(kind: "string")`. Panics on a value of the wrong type, an unknown
/// format, an `expected` without a `pattern`, or length bounds no
/// string satisfies; a pattern string that is no valid regex fails with
/// Typst's own regex error.
///
/// - min-length (int, none): The fewest characters (grapheme clusters)
///   allowed.
/// - max-length (int, none): The most characters (grapheme clusters)
///   allowed.
/// - format (str, none): A JSON Schema format name: `"date"`,
///   `"date-time"`, `"time"`, `"uri"`, `"email"`, `"uuid"`,
///   `"hostname"`, `"ipv4"` or `"ipv6"`. The string must have that form.
/// - pattern (regex, str, none): A regular expression the string must
///   match, anywhere in it unless anchored with `^…$`. With a `format`,
///   the string must have the format and match the pattern.
/// - expected (str, none): What a string matching `pattern` looks like,
///   for the error message ("expected …"). Only with `pattern`; by
///   default `"matching pattern"`.
/// -> dictionary
#let string(
  min-length: none,
  max-length: none,
  format: none,
  pattern: none,
  expected: none,
) = {
  let p = _string-problem(format: format, pattern: pattern, expected: expected)
  if p != none { _fail("string()", p) }
  let base = (kind: "string")
  if format != none { base.format = format }
  if pattern != none {
    base.pattern = if type(pattern) == regex { pattern } else {
      regex(pattern)
    }
  }
  // Stored only when given: a pattern miss falls back to "matching
  // pattern" (leaf.typ), and a find-paths query that sets no `expected`
  // then matches any.
  if expected != none { base.expected = expected }
  _constrain("string()", base, "string", (
    min-length: min-length,
    max-length: max-length,
  ))
}

// Typst-native input for a `date` field (#134): a datetime with a date
// and no time converts to the ISO string the row's regex checks, so
// validate and coerce treat it exactly like the JSON string. One with a
// time returns none — a time is never dropped to make a date fit — and
// so does a year outside RFC 3339's four digits, which the regex the
// conversion skips would refuse.
#let _datetime-expected = "a string or a datetime with a date in years 0 to 9999 and no time"

#let _from-datetime(value) = {
  let year = value.year()
  if year != none and year >= 0 and year <= 9999 and value.hour() == none {
    value.display("[year]-[month]-[day]")
  }
}

// The format check: the datetime conversion, then the row's regex and
// `real` check, and the node's own extra pattern. A datetime of the
// wrong shape is a `format` miss that leaves no string to model; a
// format or pattern miss still leaves the string. A converted datetime
// skips the regex: it is a real date by construction.
#let _format-check(row, schema, value, ctx) = {
  if type(value) == datetime and row.format == "date" {
    let s = _from-datetime(value)
    if s == none {
      return (
        errors: _error(
          ctx.path,
          "format",
          _expected-got(_datetime-expected, "datetime"),
          expected: _datetime-expected,
          got: value,
        ),
        value: value,
        fatal: (path: ctx.path, expected: _datetime-expected, got: value),
      )
    }
    return (errors: _pattern-errors(schema, s, ctx.path), value: s, fatal: none)
  }
  if type(value) != str {
    return _type-miss(ctx.path, "string", value)
  }
  // The node's own pattern runs beside a format miss, as JSON Schema
  // reports every failing keyword; neither leaves the string unmodelled.
  let errors = if (
    value.match(row.pattern) == none
      or not row.at("real", default: _ => true)(value)
  ) {
    _error(
      ctx.path,
      "format",
      "expected " + row.expected + ".",
      expected: row.expected,
      got: value,
    )
  } else { () }
  (
    errors: errors + _pattern-errors(schema, value, ctx.path),
    value: value,
    fatal: none,
  )
}

// The string kind's check: its format's, when it has one, which runs
// the node's own pattern after the format; the type gate and the
// pattern alone otherwise.
#let _string-kind-check(schema, value, ctx) = {
  let format = schema.at("format", default: none)
  if format == none { return _pattern-check(schema, value, ctx) }
  _format-check(_formats.at(format), schema, value, ctx)
}
