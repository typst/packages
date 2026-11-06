// Date parsing, formatting, and ranges.
//
// JSON Resume dates may be `YYYY`, `YYYY-MM` or `YYYY-MM-DD`. Typst's
// `datetime` has no year-only or year-month form, so partials live in
// a `(year, month, day)` dict. `datetime.display()` only emits English
// names, which would defeat `labels.months`, so we render names
// ourselves while mirroring its bracketed token syntax, so a template
// carries over to other Typst code.

#import "text.typ": _field, _join_present, _present

// Strict ISO prefix parse (zero-padded, months 1–12, days 1–31) to a
// `(year, month, day)` dict, or `none` so callers render anything else
// ("Jan 2022", "2024/06") verbatim.
#let _parse_iso_date(s) = {
  if type(s) != str { return none }
  let m = s.match(regex("^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$"))
  if m == none { return none }
  let (year, month, day) = m.captures
  let year-num = int(year)
  let month-num = if month == none { none } else { int(month) }
  let day-num = if day == none { none } else { int(day) }
  if month-num != none and (month-num < 1 or month-num > 12) { return none }
  if day-num != none and (day-num < 1 or day-num > 31) { return none }
  (year: year-num, month: month-num, day: day-num)
}

// `meta.lastModified` may be a full timestamp with `T` or a space
// (RFC 3339 §5.6) after the date, so only the date prefix is parsed;
// `_parse_iso_date` stays strict for its other callers. Partial or
// calendar-invalid dates return `none` rather than panicking inside
// `datetime()` (e.g. Feb 29 in a non-leap year).
#let _iso_datetime(s) = {
  if type(s) != str { return none }
  let prefix = s.match(regex("^\d{4}-\d{2}-\d{2}"))
  if prefix == none { return none }
  let parts = _parse_iso_date(prefix.text)
  if parts == none { return none }
  let is-leap = (
    calc.rem(parts.year, 4) == 0
      and (calc.rem(parts.year, 100) != 0 or calc.rem(parts.year, 400) == 0)
  )
  let days-in-month = (
    31,
    if is-leap { 29 } else { 28 },
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  )
  if parts.day > days-in-month.at(parts.month - 1) { return none }
  datetime(year: parts.year, month: parts.month, day: parts.day)
}

// Named shorthands for `dateFormat`; partial dates are handled by the
// token elision in `_apply_date_template`.
#let _date_format_aliases = (
  long: "[day padding:none] [month repr:long] [year]",
  short: "[day]/[month]/[year]",
)
#let _pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }

// Resolves one bracketed token (`year`, `month`, `day` with `repr:` /
// `padding:` modifiers) — a subset of `datetime.display()`. Long and
// short month names come from `labels.months` so they localise. A
// component the input lacks yields `_date_token_drop` for the caller
// to collapse.
#let _date_token_drop = "\u{FFFD}" // Private placeholder for missing parts.
#let _resolve_date_token(token, parts, labels) = {
  let parts-list = token.split(" ")
  let head = parts-list.first()
  let modifiers = parts-list.slice(1)
  let has(m) = modifiers.contains(m)
  if head == "year" {
    // Year is always 4 digits from the regex, so `padding:` is a no-op.
    str(parts.year)
  } else if head == "month" {
    if parts.month == none { return _date_token_drop }
    if has("repr:long") {
      labels.months.at(parts.month - 1)
    } else if has("repr:short") {
      // Slice by cluster, not byte: "März" or "août" would otherwise
      // panic on a non-char boundary at byte 3.
      let clusters = labels.months.at(parts.month - 1).clusters()
      clusters.slice(0, calc.min(3, clusters.len())).join("")
    } else if has("padding:none") {
      str(parts.month)
    } else {
      _pad2(parts.month)
    }
  } else if head == "day" {
    if parts.day == none { return _date_token_drop }
    if has("padding:none") {
      str(parts.day)
    } else {
      _pad2(parts.day)
    }
  } else {
    panic(
      "Unknown dateFormat token: ["
        + token
        + "]. Supported: year, month, day (each with optional `padding:` / `repr:` modifiers).",
    )
  }
}

// Missing components leave a sentinel; it is stripped together with
// its bordering separators, so a year-only input under
// `[day] · [month repr:short] [year]` renders `2024`, not `· · 2024`.
#let _apply_date_template(template, parts, labels) = {
  let body = template.replace(
    regex("\[([^\]]+)\]"),
    m => _resolve_date_token(m.captures.at(0), parts, labels),
  )
  // Any non-letter, non-digit counts as a separator, so exotic
  // glyphs (`·`, `—`) collapse without being listed.
  body
    .replace(regex("[^\p{L}\p{N}]*" + _date_token_drop + "[^\p{L}\p{N}]*"), " ")
    .replace(regex("\s+"), " ")
    .trim()
}

// Single entry point for every rendered date. Non-ISO strings pass
// through verbatim, as does everything under `"iso"`. A function
// formatter receives the parsed dict and must return a string.
#let _format_date(value, prefs, labels) = {
  if not _present(value) { return value }
  let format = prefs.dateFormat
  if format == "iso" { return value }
  let parts = _parse_iso_date(value)
  if parts == none { return value }
  if type(format) == function { return format(parts) }
  // `alta()` has already validated non-alias strings as templates.
  let template = _date_format_aliases.at(format, default: format)
  _apply_date_template(template, parts, labels)
}

// `start – end`; a missing side drops out with its dash. `open-end`
// stands in for a missing end — `none` suits ranges with no end, such
// as a certificate that doesn't expire. Callers read the sides with
// `_field`, so `none` is the only absent form here.
#let _format_date_span(start, end, prefs, labels, open-end: none) = {
  let start-text = if start != none { _format_date(start, prefs, labels) }
  let end-text = if end != none { _format_date(end, prefs, labels) } else {
    open-end
  }
  _join_present((start-text, end-text), [ – ])
}

// A `startDate` / `endDate` entry where a missing end reads
// `labels.present`; a fully undated entry stays `none`, not a bare
// "Present". Argument order matches `_format_date`.
#let _format_date_range(entry, prefs, labels) = {
  let start = _field(entry, "startDate")
  let end = _field(entry, "endDate")
  if start == none and end == none { return none }
  _format_date_span(start, end, prefs, labels, open-end: labels.present)
}
