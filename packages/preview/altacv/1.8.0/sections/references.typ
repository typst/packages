// References. `availableOnRequest: true` shows
// `labels.referencesAvailableOnRequest` instead of a quote; when every
// entry is on request the section is that one line, with no names.
// Entries with neither quote nor flag are skipped; nameless ones
// render anonymously. Contact details stay out, as JSON Resume
// intends.

#import "../internal/text.typ": (
  _field, _join_present, _on_request, _reference_usable, _string_at,
)
#import "../internal/primitives.typ": (
  _entry, _preamble, _section, _section_frame,
)
#import "../internal/dates.typ": _format_date

// "Manager, Pied Piper · 2024": who, then when, each part optional.
// `none` when all are absent.
#let _attribution(entry, prefs, labels) = {
  let date = _string_at(entry, "date")
  _join_present(
    (
      _join_present(
        ("relationship", "organization").map(k => _string_at(entry, k)),
        ", ",
      ),
      if date != none { _format_date(date, prefs, labels) },
    ),
    " · ",
  )
}

#let _references(entries, (labels, prefs, ..)) = {
  let valid = entries.filter(_reference_usable)
  // `all` holds on an empty list, which `_section_frame` then renders
  // as nothing.
  if valid.all(_on_request) {
    _section_frame(labels.references, valid, _preamble(
      labels.referencesAvailableOnRequest,
    ))
  } else {
    _section(labels.references, valid, entry => _entry(
      title: _field(entry, "name"),
      subtitle: _attribution(entry, prefs, labels),
      summary: if _on_request(entry) {
        labels.referencesAvailableOnRequest
      } else {
        entry.reference
      },
    ))
  }
}
