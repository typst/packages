// `work[]` and `volunteer[]` render identically, differing only in
// section label and organisation key, so both use `_entry_section`.

#import "../internal/text.typ": _field
#import "../internal/primitives.typ": _entry, _entry_when, _section

// `key` (`"work"` / `"volunteer"`) names the label and the field in
// panic messages; `org-key` holds the organisation name. `position` is
// optional; without it the org line leads.
#let _entry_section(entries, key, org-key, (labels, prefs, ..)) = _section(
  labels.at(key),
  entries,
  entry => _entry(
    title: _field(entry, "position"),
    org: _field(entry, org-key),
    org-url: _field(entry, "url"),
    .._entry_when(entry, key, prefs, labels),
    summary: _field(entry, "summary"),
    highlights: entry.at("highlights", default: ()),
  ),
)

#let _experience(work, ctx) = _entry_section(work, "work", "name", ctx)

#let _volunteer(entries, ctx) = _entry_section(
  entries,
  "volunteer",
  "organization",
  ctx,
)
