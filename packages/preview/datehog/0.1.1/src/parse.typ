// String -> moment parsers.
//
// Three independent strategies, each usable on its own:
//
//   parse-iso     strict ECMAScript Date Time String Format
//   parse-numeric slash/dash/dot separated numeric dates
//   parse-loose   month-name forms ("Feb 2020", "15 January 2020", RFC 2822)
//
// `js.typ` layers V8's `Date.parse` ordering on top of these. Everything here
// returns a moment in UTC or `none`; nothing throws, because Typst has no way
// to catch an error and a bad cell in a data table must not take down the
// document.
//
// Every regex is bound at module level so it is compiled once per compile
// rather than once per call, and every parser is a pure top-level function so
// repeated parses of the same string are memoised by Typst — which matters a
// lot, since real data re-presents the same handful of dates thousands of times.

#import "civil.typ": is-valid-date
#import "moment.typ": from-parts, from-ms
#import "tokens.typ": month-from-name

// ---------------------------------------------------------------------------
// ISO 8601 / ECMAScript Date Time String Format
// ---------------------------------------------------------------------------

// YYYY | YYYY-MM | YYYY-MM-DD, optionally followed by a time and a zone.
// A leading `+`/`-` six-digit expanded year is deliberately not supported;
// it does not occur in tabular data and complicates the year sign handling.
#let _ISO = regex(
  "^(\\d{4})(?:-(\\d{2})(?:-(\\d{2}))?)?" +
  "(?:[T ](\\d{2}):(\\d{2})(?::(\\d{2})(?:\\.(\\d{1,9}))?)?" +
  "(Z|z|[+-]\\d{2}:?\\d{2})?)?$",
)

/// Is `s` an ISO date with no time part (`2020`, `2020-03`, `2020-03-14`)?
///
/// ECMAScript treats these as UTC while date-*time* forms without a zone are
/// local, so callers reproducing JS semantics need to distinguish them.
#let is-iso-date-only(s) = {
  if type(s) != str { return false }
  s.trim().match(regex("^\\d{4}(-\\d{2}(-\\d{2})?)?$")) != none
}

// Offset string ("Z", "+02:00", "-0500") -> minutes east of UTC.
#let _zone-minutes(zone) = {
  if zone == none { return none }
  if zone == "Z" or zone == "z" { return 0 }
  let sign = if zone.starts-with("-") { -1 } else { 1 }
  let digits = zone.slice(1).replace(":", "")
  if digits.len() != 4 { return none }
  sign * (int(digits.slice(0, 2)) * 60 + int(digits.slice(2, 4)))
}

/// Parse a strict ISO 8601 / ECMAScript date-time string.
///
/// `assume-offset` (minutes east of UTC) is applied when the string carries no
/// zone of its own. The default of 0 means a zoneless string is read as UTC,
/// which keeps parsing reproducible across machines — see the README.
/// Returns a moment or `none`.
#let parse-iso(s, assume-offset: 0) = {
  if type(s) != str { return none }
  let m = s.trim().match(_ISO)
  if m == none { return none }
  let g = m.captures

  let year = int(g.at(0))
  let month = if g.at(1) == none { 1 } else { int(g.at(1)) }
  let day = if g.at(2) == none { 1 } else { int(g.at(2)) }
  if not is-valid-date(year, month, day) { return none }

  let hour = if g.at(3) == none { 0 } else { int(g.at(3)) }
  let minute = if g.at(4) == none { 0 } else { int(g.at(4)) }
  let second = if g.at(5) == none { 0 } else { int(g.at(5)) }
  // Fractional seconds: pad or truncate to exactly three digits.
  let millisecond = if g.at(6) == none { 0 } else {
    let f = g.at(6)
    int((f + "000").slice(0, 3))
  }
  // 24:00 is a legal ECMAScript end-of-day marker; anything else out of range
  // is a rejection rather than a normalisation.
  if hour > 24 or minute > 59 or second > 59 { return none }
  if hour == 24 and (minute != 0 or second != 0 or millisecond != 0) { return none }

  let zone = _zone-minutes(g.at(7))
  let offset = if zone == none { assume-offset } else { zone }

  from-parts(
    year, month, day,
    hour: hour, minute: minute - offset, second: second, millisecond: millisecond,
  )
}

// ---------------------------------------------------------------------------
// Numeric dates
// ---------------------------------------------------------------------------

// The two separators must be the same character. Typst's regex engine is
// Rust's, which has no backreferences, so `\2` is not available: both
// separators are captured and compared in code instead.
#let _NUMERIC = regex("^\\s*(\\d{1,4})\\s*([./-])\\s*(\\d{1,2})\\s*([./-])\\s*(\\d{1,4})\\s*$")

#let _numeric-captures(s) = {
  if type(s) != str { return none }
  let m = s.match(_NUMERIC)
  if m == none { return none }
  if m.captures.at(1) != m.captures.at(3) { return none }
  m.captures
}

/// Does `s` have the shape of a slash/dash/dot separated numeric date?
///
/// Shape only — `is-numeric-date-shape("15.01.2020")` is `true` even though
/// `parse-numeric` rejects it (see below).
#let is-numeric-date-shape(s) = _numeric-captures(s) != none

/// Parse `M/D/YYYY`, `YYYY-M-D` and the dot/dash variants.
///
/// Follows V8: a leading four-digit component means year-first, otherwise the
/// first component is the **month** (US ordering). A month outside 1-12 is a
/// rejection, not a re-interpretation — so `"15.01.2020"` returns `none`
/// rather than being read as 15 January. Forms where no component is
/// four digits are rejected outright.
#let parse-numeric(s, assume-offset: 0) = {
  let caps = _numeric-captures(s)
  if caps == none { return none }
  let a = caps.at(0)
  let b = caps.at(2)
  let c = caps.at(4)

  let parts = if a.len() == 4 {
    (int(a), int(b), int(c))
  } else if c.len() == 4 {
    (int(c), int(a), int(b))
  } else {
    return none
  }
  let (year, month, day) = parts
  if not is-valid-date(year, month, day) { return none }
  from-parts(year, month, day, minute: -assume-offset)
}

// ---------------------------------------------------------------------------
// Loose / month-name forms
// ---------------------------------------------------------------------------

// "Feb 2020", "February 2020"
#let _MON-YEAR = regex("^([A-Za-z]{3,9})\\.?\\s+(\\d{4})$")
// "Feb 15 2020", "Feb 15, 2020", "February 15, 2020"
#let _MON-DAY-YEAR = regex("^([A-Za-z]{3,9})\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?\\s*,?\\s+(\\d{4})$")
// "15 Feb 2020", "15 February 2020"
#let _DAY-MON-YEAR = regex("^(\\d{1,2})(?:st|nd|rd|th)?\\s+([A-Za-z]{3,9})\\.?\\s*,?\\s+(\\d{4})$")
// RFC 2822: "Tue, 15 Feb 2020 08:30:00 GMT"
#let _RFC2822 = regex(
  "^(?:[A-Za-z]{3},?\\s+)?(\\d{1,2})\\s+([A-Za-z]{3,9})\\.?\\s+(\\d{4})" +
  "(?:\\s+(\\d{2}):(\\d{2})(?::(\\d{2}))?)?" +
  "(?:\\s+(?:GMT|UTC|UT|Z)?([+-]\\d{4})?)?\\s*$",
)
// A bare year, or a "word soup plus exactly one year" string like "FY 2018".
#let _YEAR-TOKEN = regex("\\b(\\d{4})\\b")
#let _WORDS-ONLY = regex("^[A-Za-z\\s]+$")

/// If `s` is words plus exactly one four-digit year (`"FY 2018"`, `"Q1 2018"`
/// after its digit is stripped, `"hello world 2018"`), return that year.
///
/// This mirrors a genuine V8 leniency that stricter parsers reject, and it is
/// load-bearing for real spreadsheet data where a column reads "FY 2018".
#let year-from-words(s) = {
  if type(s) != str { return none }
  let years = s.matches(_YEAR-TOKEN)
  if years.len() != 1 { return none }
  let year = int(years.first().captures.at(0))
  if year < 1000 or year > 9999 { return none }
  let rest = s.replace(_YEAR-TOKEN, "").trim()
  if rest != "" and rest.match(_WORDS-ONLY) == none { return none }
  year
}

/// Parse month-name and RFC 2822 forms. Returns a moment or `none`.
#let parse-loose(s, assume-offset: 0) = {
  if type(s) != str { return none }
  let t = s.trim()
  if t == "" { return none }

  let at-offset(year, month, day, hour: 0, minute: 0, second: 0, offset: assume-offset) = {
    if not is-valid-date(year, month, day) { return none }
    from-parts(year, month, day, hour: hour, minute: minute - offset, second: second)
  }

  // "15 Feb 2020 08:30:00 GMT" -- tried first, being the most specific.
  let m = t.match(_RFC2822)
  if m != none {
    let month = month-from-name(m.captures.at(1))
    if month != none {
      let zone = m.captures.at(6)
      let offset = if zone == none { assume-offset } else {
        let sign = if zone.starts-with("-") { -1 } else { 1 }
        sign * (int(zone.slice(1, 3)) * 60 + int(zone.slice(3, 5)))
      }
      let hh = m.captures.at(3)
      let mm = m.captures.at(4)
      let ss = m.captures.at(5)
      return at-offset(
        int(m.captures.at(2)), month, int(m.captures.at(0)),
        hour: if hh == none { 0 } else { int(hh) },
        minute: if mm == none { 0 } else { int(mm) },
        second: if ss == none { 0 } else { int(ss) },
        offset: offset,
      )
    }
  }

  let m = t.match(_MON-DAY-YEAR)
  if m != none {
    let month = month-from-name(m.captures.at(0))
    if month != none {
      return at-offset(int(m.captures.at(2)), month, int(m.captures.at(1)))
    }
  }

  let m = t.match(_DAY-MON-YEAR)
  if m != none {
    let month = month-from-name(m.captures.at(1))
    if month != none {
      return at-offset(int(m.captures.at(2)), month, int(m.captures.at(0)))
    }
  }

  let m = t.match(_MON-YEAR)
  if m != none {
    let month = month-from-name(m.captures.at(0))
    if month != none {
      return at-offset(int(m.captures.at(1)), month, 1)
    }
  }

  none
}

// ---------------------------------------------------------------------------
// UTC offsets
// ---------------------------------------------------------------------------

#let _OFFSET = regex("^(?:UTC|GMT)?([+-])(\\d{2}):?(\\d{2})?$")

/// Parse a UTC offset string into minutes east of UTC.
///
/// Accepts `Z`, `+02:00`, `+0200`, `-05`, `UTC+02:00`, and a bare number of
/// minutes. Returns `none` if it is not an offset.
///
/// Useful with `sys.inputs`: Typst cannot discover the host's timezone (see
/// `local-offset`), so passing it in on the command line is the only channel.
#let offset-from-string(value) = {
  if type(value) == int { return value }
  if type(value) != str { return none }
  let s = value.trim()
  if s == "" { return none }
  if s == "Z" or s == "z" or s == "UTC" or s == "GMT" { return 0 }
  let m = s.match(_OFFSET)
  if m == none { return none }
  let sign = if m.captures.at(0) == "-" { -1 } else { 1 }
  let hh = int(m.captures.at(1))
  let mm = if m.captures.at(2) == none { 0 } else { int(m.captures.at(2)) }
  if hh > 18 or mm > 59 { return none }
  sign * (hh * 60 + mm)
}

/// The UTC offset supplied by the caller via `--input`, in minutes.
///
/// Typst has no way to discover the host's timezone — plugins are sandboxed
/// with a single host import and no clock, and `datetime.today()` reports a
/// local date but no time of day, so the offset cannot be derived. Passing it
/// in explicitly is the only mechanism:
///
/// ```sh
/// typst compile --input tz="$(date +%z)" doc.typ
/// ```
///
/// ```typst
/// #dh.parse("2020-03-14T08:30:00", assume-offset: dh.local-offset())
/// ```
///
/// Returns `default` (0, i.e. UTC) when the input is absent or unparseable, so
/// a document that does not pass one still compiles — and still compiles the
/// same way everywhere.
///
/// Note the caveat: this is the offset *at compile time*. For data spanning a
/// DST boundary it is the wrong offset for half the rows. Where that matters,
/// prefer input data that carries its own zone.
#let local-offset(key: "tz", default: 0) = {
  let raw = sys.inputs.at(key, default: none)
  if raw == none { return default }
  let parsed = offset-from-string(raw)
  if parsed == none { default } else { parsed }
}

/// Expand a bare two-digit year the way spreadsheet software does:
/// `00`-`49` are 2000s, `50`-`99` are 1900s. Non-two-digit input is returned
/// unchanged, so this is safe to apply blindly to a column.
#let expand-two-digit-year(value) = {
  if type(value) != str { return value }
  let t = value.trim()
  if t.match(regex("^\\d{2}$")) == none { return value }
  let n = int(t)
  str(if n <= 49 { 2000 + n } else { 1900 + n })
}
