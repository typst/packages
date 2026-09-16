// Column type inference and number parsing.
// Typst's csv() gives strings, so gribouille parses them on demand.

#let _numeric-re = regex("^\\s*-?\\d+(\\.\\d+)?([eE][-+]?\\d+)?\\s*$")
#let _date-re = regex("^(\\d{4})-(\\d{2})-(\\d{2})$")
#let _datetime-re = regex(
  "^(\\d{4})-(\\d{2})-(\\d{2})[T ](\\d{2}):(\\d{2})(?::(\\d{2}))?$",
)
#let _time-re = regex("^(\\d{2}):(\\d{2})(?::(\\d{2}))?$")

/// Parse an ISO-8601 temporal string into a numeric epoch.
///
/// The reference epoch is `2000-01-01T00:00:00`. `kind` selects the unit of the returned number: `"date"` returns days since the epoch, `"datetime"` returns seconds since the epoch, and `"time"` returns seconds since midnight. Numeric values pass through unchanged so a column can mix pre-encoded numbers and ISO strings. Empty, `none`, and unparseable values return `none`.
///
/// Recognised string forms:
///
/// - `"date"`: `YYYY-MM-DD`.
/// - `"datetime"`: `YYYY-MM-DDTHH:MM[:SS]` or `YYYY-MM-DD HH:MM[:SS]`.
/// - `"time"`: `HH:MM[:SS]`.
///
/// - value: Raw cell value: numeric, string, or `none`.
/// - kind: One of `"date"`, `"datetime"`, `"time"`.
///
/// Returns: Numeric epoch value, or `none` if `value` cannot be parsed.
#let parse-temporal(value, kind) = {
  if value == none { return none }
  if type(value) == int { return float(value) }
  if type(value) == float { return value }
  if type(value) != str { return none }
  let t = value.trim()
  if t == "" { return none }
  if kind == "date" {
    let m = t.match(_date-re)
    if m == none { return none }
    let (y, mo, d) = m.captures
    let dt = datetime(year: int(y), month: int(mo), day: int(d))
    let epoch = datetime(year: 2000, month: 1, day: 1)
    let dur = dt - epoch
    return float(dur.days())
  }
  if kind == "datetime" {
    let m = t.match(_datetime-re)
    if m == none { return none }
    let (y, mo, d, h, mi, s) = m.captures
    let sec = if s == none { 0 } else { int(s) }
    let dt = datetime(
      year: int(y),
      month: int(mo),
      day: int(d),
      hour: int(h),
      minute: int(mi),
      second: sec,
    )
    let epoch = datetime(
      year: 2000,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
    )
    let dur = dt - epoch
    return float(dur.seconds())
  }
  if kind == "time" {
    let m = t.match(_time-re)
    if m == none { return none }
    let (h, mi, s) = m.captures
    let sec = if s == none { 0 } else { int(s) }
    return float(int(h) * 3600 + int(mi) * 60 + sec)
  }
  none
}

// Map an ISO-8601 string to the numeric epoch implied by its shape so a
// column carrying date/datetime/time strings can flow through the same
// pipeline as a pre-encoded numeric column. Datetime is checked before
// date so a `YYYY-MM-DDTHH:MM:SS` value is not mis-classified.
#let _iso-numeric(t) = {
  if t.match(_datetime-re) != none { return parse-temporal(t, "datetime") }
  if t.match(_date-re) != none { return parse-temporal(t, "date") }
  if t.match(_time-re) != none { return parse-temporal(t, "time") }
  none
}

#let parse-number(v) = {
  if v == none { return none }
  if type(v) == int { return float(v) }
  if type(v) == float { return v }
  if type(v) == str {
    let t = v.trim()
    if t == "" { return none }
    if t.match(_numeric-re) != none { return float(t) }
    return _iso-numeric(t)
  }
  none
}

#let is-numeric-value(v) = {
  if v == none or v == "" { return true }
  if type(v) == int or type(v) == float { return true }
  if type(v) == str and v.trim().match(_numeric-re) != none { return true }
  false
}

#let infer-column-type(values) = {
  let non-empty = values.filter(v => v != none and v != "")
  if non-empty.len() == 0 { return "unknown" }
  if non-empty.all(v => type(v) == color) { return "colour" }
  if non-empty.all(v => type(v) == length) { return "length" }
  if non-empty.all(is-numeric-value) { return "numeric" }
  "string"
}
