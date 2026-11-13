// Internal functions for all modules. They are not part of the public API.
// Only `rfc3339` and `rfc2822` are public, because `lib.typ` exports them.

// Arrays and strings

/// Concatenates strings. For an empty array, it returns `""`, not `none` as `array.join` does.
#let concat(parts) = if parts.len() == 0 { "" } else { parts.join() }

/// Flattens nested arrays and removes `none`. If the value is not an array,
/// the function uses it as an array with one item.
#let flatten(items) = {
  if type(items) != array { items = (items,) }
  let out = ()
  for item in items {
    if item == none { continue }
    if type(item) == array { out += flatten(item) } else { out.push(item) }
  }
  out
}

// Content to plain text

#let _space = [ ].func()
#let _sequence = [a *b*].func()
#let _styled = {
  set text(red)
  [a]
}.func()

// Elements that have the same plain text as their `body`.
#let _wrappers = (
  strong,
  emph,
  underline,
  overline,
  strike,
  highlight,
  smallcaps,
  sub,
  super,
  link,
  box,
  block,
  align,
  pad,
)

#let _content-to-text(c, field) = {
  let f = c.func()
  if f == _space {
    " "
  } else if f == linebreak {
    "\n"
  } else if f == parbreak {
    "\n\n"
  } else if f == smartquote {
    if c.at("double", default: true) { "\"" } else { "'" }
  } else if f == metadata {
    ""
  } else if f == _sequence {
    concat(c.children.map(ch => _content-to-text(ch, field)))
  } else if f == _styled {
    _content-to-text(c.child, field)
  } else if c.has("text") and type(c.text) == str {
    // `text`, `raw`, symbols and shorthands, for example `--`
    c.text
  } else if f in _wrappers and c.has("body") {
    if type(c.body) == content { _content-to-text(c.body, field) } else { str(c.body) }
  } else {
    panic(
      "cannot convert `"
        + repr(f)
        + "` to plain text for `"
        + field
        + "`; only plain markup (text, spaces, quotes, emphasis, links, raw, …) is supported. "
        + "Pass a string instead.",
    )
  }
}

/// Converts strings, numbers, symbols and simple markup to plain text. If a
/// value has no correct plain-text form, the function stops with an error. It
/// does not remove the value without a message.
#let to-text(v, field: "value") = {
  let t = type(v)
  if t == str {
    v
  } else if t in (int, float, decimal, symbol) {
    str(v)
  } else if t == content {
    _content-to-text(v, field)
  } else {
    panic("`" + field + "` must be a string or content, found " + str(t))
  }
}

/// The same as `to-text`, but returns `none` for `none`.
#let opt-text(v, field: "value") = if v == none { none } else { to-text(v, field: field) }

// Dates

#let _iso-re = regex("^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2}))?)?$")

/// Changes a `datetime` or an ISO 8601 string without a time zone to a
/// `datetime`. Examples of strings: `2026-07-01`, `2026-07-01T14:30` and
/// `2026-07-01T14:30:00`.
#let to-datetime(v, field: "date") = {
  if type(v) == datetime {
    if v.year() == none {
      panic("`" + field + "` must include a date (year, month and day)")
    }
    return v
  }
  if type(v) != str {
    panic("`" + field + "` must be a `datetime` or an ISO 8601 string, found " + str(type(v)))
  }
  let m = v.trim().match(_iso-re)
  if m == none {
    panic(
      "`"
        + field
        + "` is not a supported date: \""
        + v
        + "\"; use `YYYY-MM-DD`, `YYYY-MM-DDTHH:MM` or `YYYY-MM-DDTHH:MM:SS` "
        + "without a time zone (set the time zone with `tz`)",
    )
  }
  let (y, mo, d, h, mi, s) = m.captures
  if h == none {
    datetime(year: int(y), month: int(mo), day: int(d))
  } else {
    datetime(
      year: int(y),
      month: int(mo),
      day: int(d),
      hour: int(h),
      minute: int(mi),
      second: if s == none { 0 } else { int(s) },
    )
  }
}

/// The same as `to-datetime`, but returns `none` for `none`.
#let opt-datetime(v, field: "date") = if v == none { none } else { to-datetime(v, field: field) }

#let has-time(dt) = dt.hour() != none

/// Adds the time 00:00:00 to a date that has no time.
#let with-time(dt) = if has-time(dt) { dt } else {
  datetime(year: dt.year(), month: dt.month(), day: dt.day(), hour: 0, minute: 0, second: 0)
}

/// Returns the latest date in an array, or `none` if there is no date. The function ignores `none`.
#let latest(dts) = {
  let dts = dts.filter(d => d != none)
  if dts.len() == 0 { return none }
  dts.sorted(key: d => with-time(d).display("[year][month][day][hour][minute][second]")).last()
}

#let _tz-re = regex("^([+-])(\d{2}):?(\d{2})$")

// Parses a time zone. Returns `none` for UTC, or `(sign, hours, minutes)`.
#let _parse-tz(tz) = {
  if type(tz) != str {
    panic("`tz` must be a string like \"Z\", \"+01:00\" or \"-0530\", found " + str(type(tz)))
  }
  let s = tz.trim()
  if s in ("Z", "z", "UTC", "GMT") { return none }
  let m = s.match(_tz-re)
  if m == none {
    panic("`tz` must look like \"Z\", \"+01:00\" or \"-0530\", found \"" + tz + "\"")
  }
  let (sign, hh, mm) = m.captures
  if int(hh) > 23 or int(mm) > 59 {
    panic("`tz` offset out of range: \"" + tz + "\"")
  }
  if int(hh) == 0 and int(mm) == 0 { none } else { (sign, hh, mm) }
}

/// Formats a date as an RFC 3339 timestamp. Atom feeds and sitemaps use this
/// format. If the date has no time, the function uses `00:00:00`.
///
/// ```examplec
/// rfc3339("2026-07-01T14:30", tz: "+02:00")
/// ```
///
/// -> str
#let rfc3339(
  /// The date. -> datetime | str
  dt,
  /// The time zone of the date. Use `"Z"` for UTC, or an offset, for example
  /// `"+01:00"` or `"-0530"`. -> str
  tz: "Z",
) = {
  let dt = with-time(to-datetime(dt, field: "dt"))
  let offset = _parse-tz(tz)
  let suffix = if offset == none { "Z" } else { offset.at(0) + offset.at(1) + ":" + offset.at(2) }
  dt.display("[year]-[month]-[day]T[hour]:[minute]:[second]") + suffix
}

/// Formats a date as an RFC 2822 timestamp. RSS feeds use this format. If the
/// date has no time, the function uses `00:00:00`.
///
/// ```examplec
/// rfc2822("2026-07-01T14:30", tz: "+02:00")
/// ```
///
/// -> str
#let rfc2822(
  /// The date. -> datetime | str
  dt,
  /// The time zone of the date. Use `"Z"` for UTC, or an offset, for example
  /// `"+01:00"` or `"-0530"`. -> str
  tz: "Z",
) = {
  let dt = with-time(to-datetime(dt, field: "dt"))
  let offset = _parse-tz(tz)
  let suffix = if offset == none { "+0000" } else { offset.join() }
  (
    dt.display("[weekday repr:short], [day] [month repr:short] [year] [hour]:[minute]:[second] ")
      + suffix
  )
}

/// Formats a date as a W3C datetime for sitemaps. If the date has no time, the result also has no time.
#let w3c(dt, tz: "Z") = {
  let dt = to-datetime(dt, field: "lastmod")
  if has-time(dt) { rfc3339(dt, tz: tz) } else { dt.display("[year]-[month]-[day]") }
}

// Records that functions such as `atom.entry` return

#let record(kind, fields) = (syndicate: kind) + fields

#let is-record(v, kind) = type(v) == dictionary and v.at("syndicate", default: none) == kind

#let expect-record(v, kind, field) = {
  if not is-record(v, kind) {
    panic("every entry of `" + field + "` must be created with `" + kind + "`, found " + repr(v))
  }
  v
}

// Functions for documents

/// Returns a `<?xml-stylesheet?>` processing instruction for `href`, or `none`.
#let stylesheet-pi(href) = {
  if href == none { return none }
  let href = to-text(href, field: "stylesheet")
  let kind = if lower(href).ends-with(".css") { "text/css" } else { "text/xsl" }
  let href = href.replace("&", "&amp;").replace("\"", "&quot;")
  (pi: "xml-stylesheet", data: "type=\"" + kind + "\" href=\"" + href + "\"")
}

/// Changes `(prefix: uri)` to the attributes `("xmlns:prefix": uri)`.
#let xmlns-attrs(namespaces) = {
  let out = (:)
  for (prefix, uri) in namespaces {
    out.insert(if prefix == "" { "xmlns" } else { "xmlns:" + prefix }, uri)
  }
  out
}
