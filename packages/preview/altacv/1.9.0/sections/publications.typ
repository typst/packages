// Publications, grouped by `type` code (case-insensitive) under
// icon-led subheadings named from `labels.publication-types`, or as
// first written for unknown codes. The CV owner is bold among
// `authors`; `identifiers` give an unlinked title somewhere to point.
// Helpers shape the fields into data; `_bib-entry` lays them out.

#import "../internal/util/fields.typ": _field
#import "../internal/data/cv.typ": (
  _authors, _identifier-refs, _identifier-url, _identifiers, _type-groups,
)
#import "../internal/primitives.typ": _icon-heading
#import "../internal/components/bibliography.typ": _bib-entry
#import "../internal/components/frame.typ": _grouped-section

#let _render-publication(pub, (format-date, owners, ..)) = {
  let refs = _identifier-refs(_identifiers(pub.at("identifiers", default: (:))))
  let url = _field(pub, "url")
  _bib-entry(
    pub.name,
    url: if url != none { url } else { _identifier-url(refs) },
    authors: _authors(pub.at("authors", default: ()), owners),
    publisher: _field(pub, "publisher"),
    // Non-empty strings or absent (`_lenient-fields`).
    citation: (
      volume: pub.at("volume", default: none),
      issue: pub.at("issue", default: none),
      pages: pub.at("pages", default: none),
    ),
    date: format-date(_field(pub, "release-date")),
    identifiers: refs,
    summary: _field(pub, "summary"),
  )
}

// `publication-types` and `publication-icons` arrive lowercase-keyed
// (`_canonical-labels`, `_canonical-preferences`); a code with no icon
// gets `file`. A list, so nothing between entries.
#let _publications(pubs, ctx) = {
  let (labels, prefs, ..) = ctx
  let headings = labels.publication-types
  _grouped-section(
    labels.publications,
    // Lowercased, so `Talk` and `talk` share a subheading; untyped
    // entries join `article`.
    _type-groups(pubs, key: lower, untyped: "article").to-dict(),
    (code, items) => {
      let group-icon = prefs.publication-icons.at(code, default: "file")
      // An unknown code's entries all share a string `type`, so print
      // the first as written. Not `default:`, which is evaluated even
      // when the key exists.
      let heading = if code in headings { headings.at(code) } else {
        items.first().type
      }
      _icon-heading(group-icon, heading)
    },
    pub => _render-publication(pub, ctx),
    separator: none,
  )
}
