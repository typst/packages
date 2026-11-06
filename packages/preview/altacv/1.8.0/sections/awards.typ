// Awards. The title links via the altacv `custom.altacv.url`
// extension; entries without a `title` are skipped.

#import "../internal/text.typ": _altacv, _field
#import "../internal/primitives.typ": _entry, _section
#import "../internal/dates.typ": _format_date

#let _awards(entries, (labels, prefs, ..)) = _section(
  labels.awards,
  entries.filter(a => _field(a, "title") != none),
  award => _entry(
    title: award.title,
    url: _altacv(award, "url"),
    org: _field(award, "awarder"),
    period: _format_date(_field(award, "date"), prefs, labels),
    summary: _field(award, "summary"),
  ),
)
