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

// Parse every entry via `parse-number` and drop the unparseable ones.
#let to-numeric(values) = {
  values.map(parse-number).filter(v => v != none)
}

#let is-native-numeric(v) = type(v) == int or type(v) == float

#let infer-column-type(values) = {
  let non-empty = values.filter(v => v != none and v != "")
  if non-empty.len() == 0 { return "unknown" }
  if non-empty.all(v => type(v) == color) { return "colour" }
  if non-empty.all(v => type(v) == length) { return "length" }
  if non-empty.all(is-native-numeric) { return "numeric" }
  "string"
}

/// Desugar a Typst `stroke`-typed value into the separate `stroke` (thickness) and `colour` (paint) fields gribouille resolves independently.
///
/// Accepts the native `1.3pt + accent` form so a stroke's thickness and paint can be written together. The embedded paint is routed to `colour` only when `colour` is still `unset`, so an explicit `colour:` (or a mapped colour, a pin at param level) keeps priority. The geometry collapses to a bare length for the common thickness-only case, to a dictionary when the full `stroke(...)` constructor set extra fields (`cap`/`join`/`dash`/`miter-limit`), and back to `unset` for a paint-only stroke.
///
/// Non-`stroke` values pass through untouched, so callers can wrap every stroke param unconditionally.
///
/// `value` is deliberately not named `stroke`: a `stroke` parameter would shadow the built-in `stroke` type and break the `type(...) == stroke` check.
///
/// - value: The raw stroke param (a `stroke`, length, dictionary, `auto`, or `none`).
/// - colour: The sibling colour param.
/// - unset: The caller's "not set" sentinel (`auto` for geoms, `none` for theme elements).
///
/// Returns: A dict `(stroke: ..., colour: ...)` with the pair split.
#let split-stroke-shorthand(value, colour, unset) = {
  if type(value) != stroke { return (stroke: value, colour: colour) }
  let out-colour = if value.paint != auto and colour == unset {
    value.paint
  } else { colour }
  let geometry = (:)
  if value.thickness != auto { geometry.insert("thickness", value.thickness) }
  if value.cap != auto { geometry.insert("cap", value.cap) }
  if value.join != auto { geometry.insert("join", value.join) }
  if value.dash != auto { geometry.insert("dash", value.dash) }
  if value.miter-limit != auto {
    geometry.insert("miter-limit", value.miter-limit)
  }
  let out-stroke = if geometry.len() == 0 {
    unset
  } else if geometry.keys() == ("thickness",) {
    geometry.at("thickness")
  } else { geometry }
  (stroke: out-stroke, colour: out-colour)
}
