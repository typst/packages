// Awards — title (optionally linked via the altacv `url` extension to
// JSON Resume's `awards[]` shape), accent awarder line, single date,
// optional summary paragraph. Entries without a `title` are skipped
// so a stray entry can't emit an orphan heading.

#import "../internal/text.typ": _present, styled-link
#import "../internal/primitives.typ": name, term, _join_with_dividers
#import "../internal/dates.typ": _format_date

#let _awards(entries, labels, prefs) = {
  let valid = entries.filter(a => _present(a.at("title", default: none)))
  if valid.len() == 0 { return }
  [== #labels.awards]
  _join_with_dividers(valid, award => block(breakable: false, {
    let url = award.at("url", default: none)
    [=== #styled-link(award.title, dest: url)]
    let awarder = award.at("awarder", default: none)
    if _present(awarder) { name[#awarder] }
    let date = award.at("date", default: none)
    if _present(date) { term(_format_date(date, prefs, labels)) }
    let summary = award.at("summary", default: none)
    if _present(summary) { par(summary) }
  }))
}
