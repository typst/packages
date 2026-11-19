// The string formats, one row each. A row is everything the package
// knows about a format: its JSON Schema `format` name, which a string
// node carries as its `format` field, the regex that gates it, the
// hint an error shows, and whether a Typst `datetime` is accepted for
// it (none: no; false: a date with no time; true: a date and a time).
// The engine's string check, string() and the translator all read this
// table, so adding a format is one row.

#import "../core/error.typ": (
  _error, _expected-got, _type-miss, _type-name-of, _problem, _fail,
)
#import "leaf.typ": str-type, _pattern-errors, _pattern-check
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

// A time of day, `HH:MM:SS` with an optional fraction and offset, as in
// RFC 3339: `Z` may be lowercase, and second 60 (a leap second) is let
// through where one can fall — at minute 59, or at any minute under an
// offset with minutes (UTC 23:59:60 at +01:30 is 01:29:60). Which hour
// is not checked.
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
      + "?|"
      + hour
      + ":[0-5][0-9]:60"
      + fraction
      + offset-hour
      + "(0[1-9]|[1-5][0-9]))"
  )
}

// Tightened over the upstream JSON Resume regexes, which accept
// impossible months / days because they use [0-1][0-9] / [0-3][0-9].
// Deliberately permissive (no full RFC compliance). The hint omits the
// offending value — the path already names the field, the canonical
// example is the actionable part.
#let _format-rows = (
  (
    format: "date",
    datetime: false,
    pattern: regex(
      "^([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])|[0-9]{4}-(0[1-9]|1[0-2])|[0-9]{4})$",
    ),
    expected: "an ISO-8601 date (e.g. \"2024-01-15\")",
  ),
  (
    format: "date-time",
    datetime: true,
    pattern: regex(
      "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[Tt]" + _clock + "$",
    ),
    expected: "an ISO-8601 datetime (e.g. \"2024-01-15T10:00:00Z\")",
  ),
  (
    format: "uri",
    datetime: none,
    // Any scheme, then no whitespace; a `//` authority must not be
    // empty, so `https://` alone still fails.
    pattern: regex("^[A-Za-z][A-Za-z0-9+.\-]*:(//\S+|/?[^/\s]\S*)$"),
    expected: "a URI (e.g. \"https://example.com\")",
  ),
  (
    format: "email",
    datetime: none,
    // An unquoted local part without whitespace, or a quoted one; a domain of one or
    // more labels, or an address literal in brackets (`[127.0.0.1]`,
    // `[IPv6:::1]`).
    pattern: regex(
      "^([^@\s\"]+|\"([^\"\\\\]|\\\\.)+\")@([^@\s.\[\]]+(\.[^@\s.\[\]]+)*|\[[^\[\]\s]+\])$",
    ),
    expected: "an email (e.g. \"name@example.com\")",
  ),
  (
    format: "uuid",
    datetime: none,
    pattern: regex(
      "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$",
    ),
    expected: "a UUID (e.g. \"123e4567-e89b-12d3-a456-426614174000\")",
  ),
  (
    format: "hostname",
    datetime: none,
    pattern: regex("^" + _label + "(\." + _label + ")*$"),
    expected: "a hostname (e.g. \"example.com\")",
  ),
  (
    format: "ipv4",
    datetime: none,
    pattern: regex("^" + _octet + "(\." + _octet + "){3}$"),
    expected: "an IPv4 address (e.g. \"192.0.2.1\")",
  ),
  (
    format: "ipv6",
    datetime: none,
    pattern: regex(_ipv6-pattern),
    expected: "an IPv6 address (e.g. \"2001:db8::1\")",
  ),
  (
    format: "time",
    datetime: none,
    pattern: regex("^" + _clock + "$"),
    expected: "an ISO-8601 time (e.g. \"10:00:00Z\")",
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
  if format != none and format not in _formats {
    let names = _formats.keys().map(repr)
    return _problem("format", "one of " + names.join(", "), repr(format))
  }
  if expected != none and pattern == none {
    return (
      message: "expected describes a pattern, so it needs pattern:; got expected: "
        + repr(expected)
        + " alone.",
    )
  }
  if pattern != none and type(pattern) not in (regex, str) {
    return _problem("pattern", "a regex or a string", _type-name-of(pattern))
  }
  if expected != none and type(expected) != str {
    return _problem("expected", "a string", repr(expected))
  }
}

/// A string, with an optional format, pattern and length bounds. An
/// argument left at `none` sets nothing, so `string()` is `str-type`
/// and `string(format: "email")` is `email-string`.
/// Panics on a value of the wrong type, an unknown format, an
/// `expected` without a `pattern`, or length bounds no string
/// satisfies.
///
/// - min-length (int, none): The fewest characters (grapheme clusters)
///   allowed.
/// - max-length (int, none): The most characters (grapheme clusters)
///   allowed.
/// - format (str, none): A JSON Schema format name: `"date"`,
///   `"date-time"`, `"uri"`, `"email"`, `"uuid"`, `"hostname"`,
///   `"ipv4"`, `"ipv6"` or `"time"`. The string must have that form.
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
  let base = str-type
  if format != none { base.format = format }
  if pattern != none {
    base.pattern = if type(pattern) == regex { pattern } else {
      regex(pattern)
    }
    base.expected = if expected == none { "matching pattern" } else {
      expected
    }
  }
  _constrain("string()", base, "string", (
    min-length: min-length,
    max-length: max-length,
  ))
}

/// Deprecated: use `string(pattern: re, expected: …)` instead. Kept
/// until 1.0.
///
/// A string that must match a regular expression. The same as
/// `string(pattern: re, expected: expected)`.
///
/// - re (regex, str): The pattern.
/// - expected (str): What the value should be, for the error message
///   ("expected …").
/// -> dictionary
#let pattern-string(re, expected: "matching pattern") = string(
  pattern: re,
  expected: expected,
)

/// Deprecated: use `string(format: "date")` instead. Kept until
/// 1.0.
///
/// A string in ISO 8601 date form: `YYYY`, `YYYY-MM` or `YYYY-MM-DD`.
/// Data written in Typst may give a `datetime` with a date and no time;
/// it is checked and returned as the ISO string.
#let date-string = string(format: "date")
/// Deprecated: use `string(format: "date-time")` instead. Kept until
/// 1.0.
///
/// A string in ISO 8601 date and time form, `YYYY-MM-DDTHH:MM:SS`, with
/// an optional fraction and `Z` or `±HH:MM` offset; `T` and `Z` may be
/// lowercase and a leap second (`:60`) is allowed. Data written in Typst
/// may give a `datetime` with a date and a time; it is checked and
/// returned as the ISO string.
#let datetime-string = string(format: "date-time")
/// Deprecated: use `string(format: "uri")` instead. Kept until
/// 1.0.
///
/// A string that looks like a URI: a scheme, `:`, then no whitespace (a
/// permissive check).
#let uri-string = string(format: "uri")
/// Deprecated: use `string(format: "email")` instead. Kept until
/// 1.0.
///
/// A string that looks like an email address (a permissive check).
#let email-string = string(format: "email")
/// Deprecated: use `string(format: "uuid")` instead. Kept until
/// 1.0.
///
/// A string that looks like a UUID: 8-4-4-4-12 hex digits (a permissive
/// check; the version and variant are not inspected).
#let uuid-string = string(format: "uuid")
/// Deprecated: use `string(format: "hostname")` instead. Kept until
/// 1.0.
///
/// A string that looks like a hostname: dot-separated labels of letters,
/// digits and inner hyphens (a permissive check).
#let hostname-string = string(format: "hostname")
/// Deprecated: use `string(format: "ipv4")` instead. Kept until
/// 1.0.
///
/// A string in dotted-quad IPv4 form, each octet 0-255.
#let ipv4-string = string(format: "ipv4")
/// Deprecated: use `string(format: "ipv6")` instead. Kept until
/// 1.0.
///
/// A string that looks like an IPv6 address, including `::` compression
/// (a permissive check; the embedded-IPv4 tail form is not accepted).
#let ipv6-string = string(format: "ipv6")
/// Deprecated: use `string(format: "time")` instead. Kept until
/// 1.0.
///
/// A string in `HH:MM:SS` time form, with an optional fraction and `Z`
/// or `±HH:MM` offset; `Z` may be lowercase and a leap second (`:60`) is
/// allowed.
#let time-string = string(format: "time")

// Typst-native input for the date formats (#134): a datetime of the
// right shape converts to the ISO string the row's regex checks, so
// validate and coerce treat it exactly like the JSON string. Wrong
// shape returns none — a time is never dropped to make a date fit.
#let _datetime-expected(row) = (
  "a string or a datetime with a date and "
    + if row.datetime { "a time" } else { "no time" }
)

#let _from-datetime(row, value) = {
  if value.year() != none and (value.hour() != none) == row.datetime {
    value.display(
      "[year]-[month]-[day]"
        + if row.datetime { "T[hour]:[minute]:[second]" } else { "" },
    )
  }
}

// The format check: the datetime conversion, then the row's regex, then
// the node's own extra pattern, each a gate. A datetime of the wrong
// shape is a `format` miss that leaves no string to model; a regex or
// pattern miss still leaves the string.
#let _format-check(row, schema, value, ctx) = {
  let value = if type(value) == datetime and row.datetime != none {
    let converted = _from-datetime(row, value)
    if converted == none {
      let expected = _datetime-expected(row)
      return (
        errors: _error(
          ctx.path,
          "format",
          _expected-got(expected, "datetime"),
          expected: expected,
          got: value,
        ),
        value: value,
        fatal: (path: ctx.path, expected: expected, got: value),
      )
    }
    converted
  } else { value }
  if type(value) != str {
    return _type-miss(ctx.path, "string", value)
  }
  if value.match(row.pattern) == none {
    let errors = _error(
      ctx.path,
      "format",
      "expected " + row.expected + ".",
      expected: row.expected,
      got: value,
    )
    return (errors: errors, value: value, fatal: none)
  }
  // Extra pattern gate (format + pattern), on the converted string.
  (errors: _pattern-errors(schema, value, ctx.path), value: value, fatal: none)
}

// The string kind's check: its format's, when it has one, which runs
// the node's own pattern after the format; the type gate and the
// pattern alone otherwise. The node comes normalised (structure.typ's
// _node), so its format is a known one.
#let _string-kind-check(schema, value, ctx) = {
  let format = schema.at("format", default: none)
  if format == none { _pattern-check(schema, value, ctx) } else {
    _format-check(_formats.at(format), schema, value, ctx)
  }
}
