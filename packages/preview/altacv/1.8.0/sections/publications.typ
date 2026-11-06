// Publications, grouped by `type` code (case-insensitive) under
// icon-led subheadings named from `labels.publicationTypes`, or as
// first written for unknown codes. The CV owner is bold among
// `authors`; `identifiers` give an unlinked title somewhere to point.

#import "../internal/state.typ": _body_size_state
#import "../internal/text.typ": (
  _field, _join_present, _present_str, _string_at, styled-link,
)
#import "../internal/primitives.typ": (
  _group_by, _grouped_section, _meta, _preamble, _small,
)
#import "../internal/icons.typ": icon
#import "../internal/dates.typ": _format_date

// Extended via `labels.publicationIcons`; anything unmatched,
// including `patent`, falls back to `file`.
#let _code_publication_icons = (
  article: "newspaper",
  book: "book",
  thesis: "book",
  talk: "microphone",
)

// `type` arrives trimmed (`_canonical_cv`); lowercasing makes `Talk`
// and `talk` share a subheading, and untyped entries join `article`.
#let _type_code(pub) = {
  let raw = _string_at(pub, "type")
  if raw != none { lower(raw) } else { "article" }
}

// Scheme names are proper nouns, so not labels. Order matters: an
// unlinked title takes the first linkable scheme listed.
#let _identifier_schemes = (
  doi: (name: "DOI", url: "https://doi.org/"),
  arxiv: (name: "arXiv", url: "https://arxiv.org/abs/"),
  pmid: (name: "PMID", url: "https://pubmed.ncbi.nlm.nih.gov/"),
  isbn: (name: "ISBN", url: none),
)
#let _identifier_scheme(scheme) = _identifier_schemes.at(
  scheme,
  default: (name: scheme, url: none),
)

#let _identifiers(pub) = {
  let ids = pub.at("identifiers", default: none)
  if type(ids) != dictionary { return () }
  ids
    .pairs()
    .filter(((_, id)) => _present_str(id))
    .map(((scheme, id)) => (lower(scheme), id))
}

#let _identifier_url(ids) = {
  let by-scheme = ids.to-dict()
  let hit = _identifier_schemes
    .pairs()
    .find(((scheme, s)) => s.url != none and scheme in by-scheme)
  if hit != none { hit.at(1).url + by-scheme.at(hit.at(0)) }
}

#let _identifier_line(ids) = (
  ids
    .map(((scheme, id)) => {
      let s = _identifier_scheme(scheme)
      [#s.name #if s.url == none { id } else { link(s.url + id, id) }]
    })
    .join[ · ]
)

// Journal-style `12(3), 45–67`; each part takes its punctuation with
// it, and hyphens in `pages` become one en dash.
#let _citation(pub) = {
  let part(key) = _string_at(pub, key)
  let issue = part("issue")
  let pages = part("pages")
  _join_present(
    (
      (part("volume"), if issue != none { "(" + issue + ")" }).join(),
      if pages != none { pages.replace(regex("-+"), "–") },
    ),
    ", ",
  )
}

// The entry matching `owner` (`basics.name`, ignoring case and
// surrounding spaces) is bold, the academic-CV convention.
#let _author_line(pub, owner) = {
  let authors = pub.at("authors", default: ())
  if type(authors) != array { return none }
  let owner-key = if _present_str(owner) { lower(owner.trim()) }
  authors
    .filter(a => type(a) == str)
    .map(a => a.trim())
    .filter(_present_str)
    .map(a => if lower(a) == owner-key { strong(a) } else { a })
    .join(", ")
}

#let _source(pub) = _join_present(
  (_field(pub, "publisher"), _citation(pub)),
  " ",
)

// One bibliography line per publication: the linked title, then
// authors, source, date, identifiers and summary, each on its own
// line. Absent lines drop out so none leaves an orphan `\` break.
#let _render_publication(pub, (labels, prefs, owner, ..)) = {
  let ids = _identifiers(pub)
  let url = _field(pub, "url")
  let dest = if url != none { url } else { _identifier_url(ids) }
  let lines = _join_present(
    (
      _small(_author_line(pub, owner)),
      _small(_source(pub)),
      _meta(_format_date(_field(pub, "releaseDate"), prefs, labels)),
      _meta(_identifier_line(ids)),
      _preamble(_field(pub, "summary")),
    ),
    [\ ],
  )
  [- #styled-link(pub.name, dest: dest). #if lines != none [\ #lines]]
}

// Label tables arrive lowercase-keyed (`_canonical_labels`). Icons
// resolve `labels.publicationIcons` → `_code_publication_icons` →
// `file`. A list, so no dividers between entries.
#let _publications(pubs, ctx) = {
  let (labels, ..) = ctx
  let headings = labels.publicationTypes
  _grouped_section(
    labels.publications,
    _group_by(pubs.filter(p => _field(p, "name") != none), _type_code),
    (code, items) => {
      let group-icon = labels.publicationIcons.at(
        code,
        default: _code_publication_icons.at(code, default: "file"),
      )
      // An unknown code's entries all share a string `type`, so print
      // the first as written. Not `default:`, which is evaluated even
      // when the key exists.
      let heading = if code in headings { headings.at(code) } else {
        items.first().type
      }
      // Read in context: `em` inside the heading is already scaled.
      [#context icon(
          group-icon,
          size: 1.2 * _body_size_state.get(),
          shift: 0pt,
        ) #heading]
    },
    pub => _render_publication(pub, ctx),
    dividers: false,
  )
}
