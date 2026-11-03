// Education. The heading falls back to `area` when `studyType` is
// absent; `courses` render as pills like other string arrays, inline
// after the score.

#import "../internal/text.typ": _field
#import "../internal/primitives.typ": _entry, _entry_when, _section

#let _education(entries, (labels, prefs, ..)) = _section(
  labels.education,
  entries,
  edu => _entry(
    // An empty `studyType` falls through to `area`, as a missing one does.
    title: (_field(edu, "studyType"), _field(edu, "area")).find(t => t != none),
    org: _field(edu, "institution"),
    org-url: _field(edu, "url"),
    .._entry_when(edu, "education", prefs, labels),
    summary: _field(edu, "summary"),
    tags-lead: _field(edu, "score"),
    tags: edu.at("courses", default: ()),
  ),
)
