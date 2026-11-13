// JSON Resume's `work[]` and `volunteer[]` render as the same block
// list — position heading, accent-coloured (optionally linked) org
// line, optional term row + location, optional italic preamble,
// bulleted highlights. They differ only in their section label and in
// the dict key naming the organisation (`work` uses `name`,
// `volunteer` uses `organization`), and `volunteer[]`
// cannot have a `keywords` section

#import "../internal/util/fields.typ": _field
#import "../internal/data/cv.typ": _entry-period, _location-parts
#import "../internal/components/entry.typ": _entry
#import "../internal/components/frame.typ": _section

#let _entry-slots(entry, org-key, format-date, labels) = (
  title: _field(entry, "position"),
  org: _field(entry, org-key),
  org-url: _field(entry, "url"),
  period: _entry-period(entry, format-date, labels.present),
  location: _location-parts(entry.at("location", default: none)),
  summary: _field(entry, "summary"),
  highlights: entry.at("highlights", default: ()),
)

#let _work(entries, (labels, format-date, ..)) = _section(
  labels.work,
  entries,
  e => _entry(
    labels,
    .._entry-slots(e, "name", format-date, labels),
    // Read leniently: 1.8.0 didn't draw them, so accepted any value;
    // `_lenient-fields` dropped any but an array of text.
    keywords: e.at("keywords", default: ()),
  ),
)

#let _volunteer(entries, (labels, format-date, ..)) = _section(
  labels.volunteer,
  entries,
  e => _entry(
    labels,
    .._entry-slots(e, "organization", format-date, labels),
  ),
)
