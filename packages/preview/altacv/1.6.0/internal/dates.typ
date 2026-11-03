// Date parsing, formatting, and ranges.
//
// JSON Resume's iso8601 pattern accepts three partial shapes:
// `YYYY-MM-DD`, `YYYY-MM`, and `YYYY` (verified against the schema's
// `iso8601` regex). Typst's built-in `datetime` type cannot represent
// the latter two — it stores either a full date, a time, or a full
// datetime, with no year-only or year-month variant — so we keep a
// custom `(year, month: opt int, day: opt int)` dict for partials.
// `datetime.display()` is also locked to English month/weekday names
// today (Typst plans localisation in the future), which would defeat
// `labels.months`, so we render names from the labels dict instead of
// delegating. We still mirror Typst's bracketed format-string syntax
// (`[year]`, `[month repr:long]`, …) so call sites can carry the same
// template into other Typst code if they need to.

#import "text.typ": _present

// Tries to parse `s` as an ISO 8601 calendar date prefix — `yyyy`,
// `yyyy-mm`, or `yyyy-mm-dd`. Returns a `(year, month, day)` dict
// (month/day may be `none`) on success, or `none` if the input doesn't
// match. Matching is strict on shape (zero-padded, hyphen-separated)
// and on calendar validity (months 1–12, days 1–31). Anything else —
// "Jan 2022", "2024/06", "May 2016 – Jul 2017" — falls through to
// verbatim rendering by callers.
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

// `meta.lastModified` is ISO 8601 — accept both a bare date and a
// full timestamp with any separator after the date prefix (`T` per
// the spec; space per RFC 3339 §5.6, also what `Python datetime
// .isoformat(sep=" ")` and Postgres emit). Match the date prefix and
// discard the rest, so `_parse_iso_date` itself stays strict — other
// callers (cert dates, work dates …) reject malformed inputs cleanly.
// Returns `none` for partial or calendar-invalid dates so the caller
// can drop the field instead of panicking inside `datetime()` on
// e.g. Feb 29 in a non-leap year.
#let _iso_datetime(s) = {
  if type(s) != str { return none }
  let prefix = s.match(regex("^\d{4}-\d{2}-\d{2}"))
  if prefix == none { return none }
  let parts = _parse_iso_date(prefix.text)
  if parts == none { return none }
  let is-leap = calc.rem(parts.year, 4) == 0 and (calc.rem(parts.year, 100) != 0 or calc.rem(parts.year, 400) == 0)
  let days-in-month = (31, if is-leap { 29 } else { 28 }, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  if parts.day > days-in-month.at(parts.month - 1) { return none }
  datetime(year: parts.year, month: parts.month, day: parts.day)
}

// `"long"` and `"short"` are name aliases for the bracketed templates
// below — kept so callers can write `dateFormat: "long"` without
// reaching for the template syntax. Missing-token elision in
// `_apply_date_template` handles year-only and year-month inputs.
#let _date_format_aliases = (
  long: "[day padding:none] [month repr:long] [year]",
  short: "[day]/[month]/[year]",
)
#let _pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }

// Resolves a single bracketed token from a Typst-style format template
// (e.g. "year", "month repr:long", "day padding:none") against the
// parsed parts. Missing components (month/day on a year-only or
// year-month input) substitute `_DATE_TOKEN_DROP` so adjacent
// separators can be collapsed by the caller. Mirrors a
// subset of Typst's own `datetime.display()` token syntax — the
// supported tokens are `year`, `month`, and `day`, with
// `repr:long`/`repr:short`/`repr:numerical` for `month` (the long/short
// forms read from `labels.months` so they localise) and
// `padding:none`/`padding:zero` for the numeric forms.
#let _DATE_TOKEN_DROP = "\u{FFFD}"  // Private placeholder for missing parts.
#let _resolve_date_token(token, parts, labels) = {
  let parts-list = token.split(" ")
  let head = parts-list.first()
  let modifiers = parts-list.slice(1)
  let has(m) = modifiers.contains(m)
  if head == "year" {
    // Year is always 4 digits from the regex, so `padding:` is a no-op.
    str(parts.year)
  } else if head == "month" {
    if parts.month == none { return _DATE_TOKEN_DROP }
    if has("repr:long") {
      labels.months.at(parts.month - 1)
    } else if has("repr:short") {
      // Slice by cluster, not byte, so localised names beginning with
      // a multi-byte character (e.g. German "März", French "août")
      // don't panic on a non-char boundary at byte index 3.
      let clusters = labels.months.at(parts.month - 1).clusters()
      clusters.slice(0, calc.min(3, clusters.len())).join("")
    } else if has("padding:none") {
      str(parts.month)
    } else {
      _pad2(parts.month)
    }
  } else if head == "day" {
    if parts.day == none { return _DATE_TOKEN_DROP }
    if has("padding:none") {
      str(parts.day)
    } else {
      _pad2(parts.day)
    }
  } else {
    panic("Unknown dateFormat token: [" + token + "]. Supported: year, month, day (each with optional `padding:` / `repr:` modifiers).")
  }
}

// Applies a Typst-style bracketed template like "[day]/[month]/[year]"
// to the parsed parts. Missing components emit a private sentinel
// marker; a final pass strips each sentinel together with the
// whitespace and surrounding non-alphanumeric separator characters
// that bordered it, so a year-only input under template
// `[day] · [month repr:short] [year]` renders as just `2024` rather
// than `· · 2024`.
#let _apply_date_template(template, parts, labels) = {
  let body = template.replace(
    regex("\[([^\]]+)\]"),
    m => _resolve_date_token(m.captures.at(0), parts, labels),
  )
  // Strip the sentinel together with any run of separator-class chars
  // on either side. "Separator" here is anything that isn't a letter
  // or digit — covers ASCII (`/`, `-`, `,`, `.`, space) and Unicode
  // (`·`, `—`, `–`, etc.) so callers can use exotic glyphs without
  // worrying about whether we know about them.
  body
    .replace(regex("[^\p{L}\p{N}]*" + _DATE_TOKEN_DROP + "[^\p{L}\p{N}]*"), " ")
    .replace(regex("\s+"), " ")
    .trim()
}

// Single entry point used by every renderer that surfaces a date.
// Non-string and non-ISO inputs pass through verbatim (back-compat with
// pre-formatted strings like "Jan 2022"). A closure formatter receives
// the parsed `(year, month, day)` dict and must return a string. The
// `"iso"` value passes the original input through unchanged; named
// aliases (`"long"`, `"short"`) and bracketed templates resolve via
// `_apply_date_template`.
#let _format_date(value, prefs, labels) = {
  if value == none or value == "" { return value }
  let format = prefs.dateFormat
  if format == "iso" { return value }
  let parts = _parse_iso_date(value)
  if parts == none { return value }
  if type(format) == function { return format(parts) }
  // Strings: name aliases resolve to their template; everything else
  // is already a bracketed template (`alta()` validates this).
  let template = _date_format_aliases.at(format, default: format)
  _apply_date_template(template, parts, labels)
}

// Returns `none` when neither date is supplied so callers can skip
// emitting the term row, rather than falsely rendering "Present" for
// a fully undated entry. Argument order matches `_format_date`
// (`value/entry, prefs, labels`) so callers can't accidentally swap
// the two helpers' last two args.
#let _format_date_range(entry, prefs, labels) = {
  let start = entry.at("startDate", default: none)
  let end = entry.at("endDate", default: none)
  if not _present(start) and not _present(end) { return none }
  let start-text = if _present(start) { _format_date(start, prefs, labels) }
  let end-text = if _present(end) { _format_date(end, prefs, labels) } else { labels.present }
  if start-text == none { [#end-text] } else { [#start-text – #end-text] }
}
