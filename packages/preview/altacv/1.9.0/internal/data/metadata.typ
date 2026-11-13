// `_pdf-metadata`: the read CV's PDF metadata, as arguments for
// `set document(..)`.

#import "../util/dates.typ": _iso-datetime
#import "../util/fields.typ": _field, _string-at
#import "../util/values.typ": _fill-template, _present-str

// Skill keywords for the PDF `Keywords` field, first occurrence first.
#let _collect-keywords(skills) = (
  skills
    .map(group => group.at("keywords", default: ()))
    .sum(default: ())
    .filter(_present-str)
    .dedup()
)

// Optional fields are set only when non-empty: `set document(...)`
// rejects a `none` date, and empty strings would still write an entry.
// It has no URL or version field, so `meta.canonical` / `meta.version`
// ride the Keywords, the only machine-readable home; `_string-at`, as
// Keywords must be strings. `uppercase-name` is purely visual, so the
// title and author keep the name as given.
#let _pdf-metadata(cv, sections, labels) = {
  let meta = cv.meta
  let keywords = (
    _collect-keywords(sections.skills)
      + (_string-at(meta, "canonical"), _string-at(meta, "version")).filter(
        v => v != none,
      )
  )
  let description = _field(cv.basics, "summary")
  let date = _iso-datetime(meta.at("last-modified", default: none))
  (
    title: _fill-template(labels.document-title, (name: cv.basics.name)),
    author: cv.basics.name,
    ..(if keywords.len() > 0 { (keywords: keywords) }),
    ..(if description != none { (description: description) }),
    ..(if date != none { (date: date) }),
  )
}
