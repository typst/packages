// Awards. The title links via the altacv `custom.altacv.url`
// extension.

#import "../internal/util/fields.typ": _field
#import "../internal/data/cv.typ": _altacv
#import "../internal/components/entry.typ": _entry
#import "../internal/components/frame.typ": _section

#let _awards(entries, (labels, format-date, ..)) = _section(
  labels.awards,
  entries,
  award => _entry(
    labels,
    title: award.title,
    url: _altacv(award, "url"),
    org: _field(award, "awarder"),
    period: (format-date(_field(award, "date")),),
    summary: _field(award, "summary"),
  ),
)
