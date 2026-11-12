// References. `available-on-request: true` shows
// `labels.references-available-on-request` instead of a quote; when every
// entry is on request the section is that one line, with no names.
// Nameless entries render anonymously. Contact details stay out, as
// JSON Resume intends.

#import "../internal/util/fields.typ": _field
#import "../internal/data/cv.typ": _on-request
#import "../internal/primitives.typ": _preamble
#import "../internal/components/entry.typ": _entry
#import "../internal/components/frame.typ": _section, _section-frame

// Who, then when, each part optional, as the entry's `subtitle` fact
// groups: "Manager, Pied Piper · 2024". Each part is a non-empty
// string or absent (`_lenient-fields`).
#let _attribution(entry, format-date) = {
  let date = entry.at("date", default: none)
  (
    ("relationship", "organization").map(k => entry.at(k, default: none)),
    (if date != none { format-date(date) },),
  )
}

#let _references(entries, (labels, format-date, ..)) = {
  // `all` holds on an empty list, which `_section-frame` then renders
  // as nothing.
  if entries.all(_on-request) {
    _section-frame(labels.references, entries, _preamble(
      labels.references-available-on-request,
    ))
  } else {
    _section(labels.references, entries, entry => _entry(
      labels,
      title: _field(entry, "name"),
      subtitle: _attribution(entry, format-date),
      summary: if _on-request(entry) {
        labels.references-available-on-request
      } else {
        entry.reference
      },
    ))
  }
}
