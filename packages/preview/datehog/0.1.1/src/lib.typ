// datehog — date parsing and epoch arithmetic for Typst.
//
// Typst's built-in `datetime` can be constructed from calendar parts and
// formatted, but it cannot parse a string and has no epoch conversion. datehog
// fills exactly that gap: strings and epoch milliseconds in, a plain-dictionary
// `moment` out, everything in UTC and everything a pure function.
//
//   #import "@preview/datehog:0.1.1" as dh
//   #dh.parse("2020-03-14T08:30:00Z").day        // 14
//   #dh.to-iso(dh.from-ms(1584174600000))        // "2020-03-14T08:30:00.000Z"
//   #dh.js.parse-ms("FY 2018")                   // 1514764800000
//
// See README.md for the timezone policy and the JavaScript-compatibility notes.

#import "civil.typ": EPOCH, MAX-DAYS, MAX-YEAR, MIN-DAYS, MIN-YEAR, civil-from-days, days-from-civil, days-in-month, is-days-in-range, is-leap-year, is-valid-date, is-year-in-range, ordinal-from-civil, weekday-from-days
#import "moment.typ": MAX-MS, MIN-MS, MS-PER-DAY, MS-PER-HOUR, MS-PER-MINUTE, MS-PER-SECOND, add-days, add-months, add-ms, from-ms, from-parts, from-typst-datetime, is-moment, pad, to-days, to-iso, to-iso-date, to-ms, to-seconds, to-typst-datetime
#import "tokens.typ": MONTH-ABBR, MONTH-NAMES, WEEKDAY-ABBR, WEEKDAY-NAMES, month-from-name, month-name, weekday-name
#import "parse.typ": expand-two-digit-year, is-iso-date-only, is-numeric-date-shape, local-offset, offset-from-string, parse-iso, parse-loose, parse-numeric, year-from-words

// The JavaScript-compatibility layer stays namespaced: its leniencies are a
// deliberate bug-for-bug match with V8 and should be opted into by name.
#import "js.typ"

/// Parse a date string using every strategy this package knows, in the order
/// V8 would try them. Equivalent to `js.parse`, re-exported as the obvious
/// entry point.
///
/// Returns a moment (a dictionary with `ms`, `year`, `month`, `day`, `hour`,
/// `minute`, `second`, `millisecond`, `weekday`, `ordinal`) or `none`.
#let parse(value, assume-offset: 0) = js.parse(value, assume-offset: assume-offset)

/// Milliseconds since the Unix epoch for `value`, or `none`.
#let parse-ms(value, assume-offset: 0) = js.parse-ms(value, assume-offset: assume-offset)

/// Can `value` be parsed as a date?
#let is-parseable(value, assume-offset: 0) = js.is-parseable(value, assume-offset: assume-offset)
