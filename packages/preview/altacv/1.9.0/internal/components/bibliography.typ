// The bibliography list item publications map onto, and the line
// builders for its author and identifier records and its citation.

#import "../util/values.typ": _join-present
#import "../primitives.typ": (
  _fact-line, _join-facts, _link-if, _meta, _preamble, _with-theme, styled-link,
)

// `(name, owner)` records, the owner set apart (`treatment.owner`,
// bold by default: the academic-CV convention), with `theme`'s
// separator; `none` when there are none.
#let _author-names(theme, authors) = (
  authors
    .map(a => if a.owner { (theme.treatment.owner)(a.name) } else {
      a.name
    })
    .join(theme.separator.items)
)

// `_author-names` with the theme's.
#let _author-line(authors) = _with-theme(authors, t => _author-names(
  t,
  authors,
))

// `(name, id, url)` records as `_fact-line` groups, one per record:
// `name id`, the id linked when `url` is set.
#let _identifier-groups(refs) = refs.map(r => (
  [#r.name #_link-if(r.url, r.id)],
))

#let _page-hyphens = regex("-+")

// Journal-style `12(3), 45–67` from `citation`'s `volume`, `issue`
// and `pages` (each optional), in `style` (the theme's `citation`):
// each part takes its punctuation with it, and hyphens in `pages`
// become one `page-range` dash.
#let _citation(style, citation) = {
  let part(key) = citation.at(key, default: none)
  let issue = part("issue")
  let pages = part("pages")
  let (open, close) = style.issue
  _join-present(
    (
      (part("volume"), if issue != none { open + issue + close }).join(),
      if pages != none { pages.replace(_page-hyphens, style.page-range) },
    ),
    style.pages,
  )
}

// The publisher, then the citation, in `style`.
#let _source(style, publisher, citation) = _join-present(
  (publisher, _citation(style, citation)),
  style.source,
)

// The source then its date (`ACM 12(3), 45–67 · Jun 2024`), in the
// theme's citation style and separators. One context for the line
// keeps it one run of text, as a plain join would be.
#let _source-line(publisher, citation, date) = _with-theme(
  (publisher, ..citation.values(), date),
  t => _join-facts(
    t.separator,
    (_source(t.citation, publisher, citation),),
    (_meta(date),),
  ),
)

// One bibliography list item: the title (linked to `url`), then
// authors, the source with its date (`ACM 12(3), 45–67 · Jun 2024`),
// identifiers and summary, each on its own line. Absent parts drop
// out so none leaves an orphan `\` break or separator.
#let _bib-entry(
  title,
  url: none,
  authors: (),
  publisher: none,
  citation: (:),
  date: none,
  identifiers: (),
  summary: none,
) = {
  let lines = _join-present(
    (
      _author-line(authors),
      _source-line(publisher, citation, date),
      _meta(_fact-line(.._identifier-groups(identifiers))),
      _preamble(summary),
    ),
    [\ ],
  )
  [- #styled-link(title, dest: url). #if lines != none [\ #lines]]
}
