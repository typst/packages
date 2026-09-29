// JavaScript `Date.parse` / `new Date(value)` emulation.
//
// V8's date parsing is permissive and inconsistent in ways that matter when
// you are reproducing the output of a JS tool. Two directions in particular:
//
//   * V8 *accepts* free-form prefixes like "FY 2018" or "hello world 2018",
//     extracting the trailing year — most strict parsers reject them.
//   * V8 *rejects* "15.01.2020" and "15/01/2020", because it reads the first
//     component as a month and 15 is not a month — lenient parsers happily
//     read them as 15 January.
//
// The strategy order below mirrors V8's, so a value that V8 parses parses
// here, and a value V8 rejects returns `none`.
//
// **Timezones.** ECMAScript reads a zoneless date-*time* string in the host's
// local zone, and an ISO date-only string as UTC. Typst exposes no local UTC
// offset — `datetime.today()` gives a local date but no time, and 14 different
// offsets reproduce it — so "local" is not recoverable here. Zoneless input is
// therefore read as UTC by default, and `assume-offset` (minutes east of UTC)
// is available for callers who know their data's zone and want it applied.
// This makes parsing reproducible across machines, which for a typesetting
// system is the more useful guarantee anyway.

#import "moment.typ": from-ms, from-typst-datetime, is-moment, to-ms
#import "parse.typ": is-iso-date-only, is-numeric-date-shape, parse-iso, parse-loose, parse-numeric, year-from-words

/// Milliseconds since the Unix epoch for `value`, mirroring `Date.parse`.
///
/// Returns `none` where JavaScript would return `NaN`. Numbers pass through
/// unchanged (as `new Date(n)` does), booleans become 1/0, Typst `datetime`
/// values and datehog moments are converted directly.
#let parse-ms(value, assume-offset: 0) = {
  if value == none { return none }
  if type(value) == bool { return if value { 1 } else { 0 } }
  if type(value) == int { return value }
  if type(value) == float {
    if value.is-nan() or value.is-infinite() { return none }
    return value
  }
  if type(value) == datetime { return to-ms(from-typst-datetime(value)) }
  if is-moment(value) { return value.ms }
  if type(value) != str { return none }

  let s = value.trim()
  if s == "" { return none }

  // 1. Strict ISO 8601. Date-only forms are UTC per spec; zoned forms carry
  //    their own offset; zoneless date-times fall back to `assume-offset`.
  let m = parse-iso(s, assume-offset: if is-iso-date-only(s) { 0 } else { assume-offset })
  if m != none { return m.ms }

  // 2. Numeric forms. Handled before the loose parser so that a string V8
  //    rejects (month out of range) does not get quietly re-read as a
  //    day-first date by a more permissive path.
  if is-numeric-date-shape(s) {
    let m = parse-numeric(s, assume-offset: assume-offset)
    if m != none { return m.ms }
    // V8 rejects it; only the trailing-year heuristic can still apply.
    let year = year-from-words(s)
    if year != none { return to-ms(parse-iso(str(year) + "-01-01")) }
    return none
  }

  // 3. Month-name and RFC 2822 forms.
  let m = parse-loose(s, assume-offset: assume-offset)
  if m != none { return m.ms }

  // 4. V8's trailing-year heuristic: "FY 2018", "hello world 2018".
  let year = year-from-words(s)
  if year != none { return to-ms(parse-iso(str(year) + "-01-01")) }

  none
}

/// A moment for `value`, mirroring `new Date(value)`. `none` where JS would
/// produce an Invalid Date.
#let parse(value, assume-offset: 0) = from-ms(parse-ms(value, assume-offset: assume-offset))

/// Would `Date.parse(value)` succeed?
#let is-parseable(value, assume-offset: 0) = parse-ms(value, assume-offset: assume-offset) != none

// Seconds and milliseconds both appear as bare numbers in real data. The
// boundary is the same one flint uses: 1e9 (2001-09-09) up to 4102444800
// (2100-01-01) is read as seconds, above that as milliseconds.
#let MAX-TIMESTAMP-SECONDS = 4102444800
#let MAX-TIMESTAMP-MS = 4102444800000

/// Does `value` look like a Unix timestamp rather than an ordinary quantity?
#let is-likely-timestamp(value) = {
  if type(value) != int and type(value) != float { return false }
  if type(value) == bool { return false }
  (
    (value >= 1e9 and value <= MAX-TIMESTAMP-SECONDS)
      or (value > MAX-TIMESTAMP-SECONDS and value <= MAX-TIMESTAMP-MS)
  )
}

/// Normalise a bare timestamp to milliseconds, guessing the unit by magnitude.
#let timestamp-to-ms(value) = if value <= MAX-TIMESTAMP-SECONDS { value * 1000 } else { value }
