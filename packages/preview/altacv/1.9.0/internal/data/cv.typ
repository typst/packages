// Accessors that know the CV's shape: the references flag, a profile's
// network, a location, an entry's period, ratings from terms, a
// publication's authors and identifiers, and altacv's own
// `custom.altacv` namespace.

#import "../design/icon-set.typ": _network-aliases
#import "../util/dates.typ": _date-span
#import "../util/fields.typ": _dict-or-empty, _field, _string-at
#import "../util/values.typ": _present, _round-half

// A `references[]` entry's flag: only a real boolean counts, so a
// stray `"yes"` doesn't hide a quote. Rendering reads it kebab-case
// (`_kebab-fields`), the checks under JSON Resume's name.
#let _on-request(r, key: "available-on-request") = (
  r.at(key, default: false) == true
)

// A reference worth rendering, read before the field names go
// kebab-case (`_read-sections`' `keep`, `_canonical-cv`): a quote, or
// the on-request flag.
#let _reference-usable(r) = (
  _on-request(r, key: "availableOnRequest") or _field(r, "reference") != none
)

// `(:)` when either level is missing or not a dictionary.
#let _altacv-ns(obj) = _dict-or-empty(
  _dict-or-empty(obj.at("custom", default: none)).at("altacv", default: none),
)

// One of altacv's non-spec fields (`focusAreas`, `languages[].rating`,
// `awards[].url`) from its own `custom` namespace (#242), on the CV
// root or an entry. `_canonical-cv` has already lifted the deprecated
// top-level forms there.
#let _altacv(obj, key, default: none) = _altacv-ns(obj).at(
  key,
  default: default,
)

// A `basics.profiles[]` entry's network as its icon key: lowercased,
// with renamed networks mapped to the key their icon still ships under.
#let _profile-network(profile) = {
  let raw = lower(profile.network)
  _network-aliases.at(raw, default: raw)
}

// A profile network's FontAwesome glyph from the merged, lowercase-keyed
// `preferences.profile-icons`, or `none` for a network it doesn't map.
// The network as written is looked up before its alias's key, so `x`
// can be mapped apart from `twitter`, and a `twitter` mapping covers
// both.
#let _profile-glyph(profile, profile-icons) = {
  let raw = lower(profile.network)
  profile-icons.at(
    raw,
    default: profile-icons.at(_profile-network(profile), default: none),
  )
}

// JSON Resume's `location` (a string or the shared dict), collapsed
// one way for every caller so a location reads the same everywhere.
// `address` / `postalCode` are accepted but not rendered — a CV isn't
// a mailing label. The fields are JSON Resume's names, for the checks;
// the display order is rendering's (`_kebab-fields`). Absent values
// become `none`, so callers' `!= none` checks leave no orphan row or
// blank-query maps URL.
#let _location-fields = (
  "address",
  "postalCode",
  "city",
  "countryCode",
  "region",
)
#let _location-display-order = ("city", "region", "country-code")
// A `location` (an entry's or `basics`') as its present parts, for
// `_fact-line` to join with the theme's separator; `()` when there are
// none. It has passed `_check-location` (`cv-checks.typ`).
#let _location-parts(value) = {
  if not _present(value) { return () }
  if type(value) == str { return (value,) }
  _location-display-order.map(k => _field(value, k)).filter(_present)
}

// A period from `start` to `end` as `_date-span` sides, an absent
// (`_present`) end reading `present` (`labels.present`); a fully
// undated one has neither side, not a bare "Present".
#let _date-sides(start, end, format-date, present) = {
  let (start, end) = (start, end).map(v => if _present(v) { v })
  if start == none and end == none { return (none, none) }
  _date-span(start, end, format-date, open-end: present)
}

// A `start-date` / `end-date` entry's `_date-sides`.
#let _entry-period(entry, ..args) = _date-sides(
  entry.at("start-date", default: none),
  entry.at("end-date", default: none),
  ..args,
)

// Rating terms as fractions of the full scale, matched
// case-insensitively: LinkedIn's `languages[].fluency` and the common
// `skills[].level` words.
#let _fluency-terms = (
  "Native": 1.0,
  "Bilingual": 1.0,
  "Full Professional": 0.8,
  "Professional Working": 0.6,
  "Limited Working": 0.4,
  "Elementary": 0.2,
)
#let _skill-levels = (
  "Beginner": 0.2,
  "Novice": 0.2,
  "Intermediate": 0.6,
  "Advanced": 0.8,
  "Expert": 1.0,
  "Master": 1.0,
)

// A `term` (one of `terms`) as a rating on a scale of `max`, rounded
// to the half; `none` for anything else.
#let _term-rating(term, terms, max) = {
  if type(term) != str { return none }
  let key = lower(term.trim())
  let match = terms.pairs().find(((t, _)) => lower(t) == key)
  if match != none { _round-half(match.last() * max) }
}

// An entry's rating on a scale of `max`: its `custom.altacv.rating`,
// else its `field`'s `_term-rating`.
#let _entry-rating(entry, field, terms, max) = {
  let value = _altacv(entry, "rating")
  if value != none { value } else {
    _term-rating(entry.at(field, default: none), terms, max)
  }
}

// A `projects[]` or `publications[]` entry's `type`, trimmed, or
// `none` when it's untyped: missing, not a string, or blank. The one
// reading of it, so `_canonical-cv`, the sections' grouping and the
// public `adapter` can't disagree on which entries are typed.
#let _entry-type(entry) = {
  let raw = _string-at(entry, "type")
  if raw != none and raw.trim() != "" { raw.trim() }
}

// `items` grouped by `_entry-type`: `(group, items)` pairs in the
// order each group first appears. A typed item's group is `key(type)`
// (`lower` matches types ignoring case), an untyped one's `untyped`,
// which a type may share (projects' "Other"). Pairs, not a dictionary,
// as `untyped` may be `none`, which can't be a key. The one grouping,
// for the standalone sections and the public `adapter`.
#let _type-groups(items, key: t => t, untyped: none) = items.fold(
  (),
  (acc, item) => {
    let type = _entry-type(item)
    let group = if type == none { untyped } else { key(type) }
    let i = acc.position(((g, _)) => g == group)
    if i == none { acc + ((group, (item,)),) } else {
      let (_, members) = acc.at(i)
      acc.slice(0, i) + ((group, members + (item,)),) + acc.slice(i + 1)
    }
  },
)

// A skill group's `level` as a rating on `prefs.max-rating`, per
// `skill-level-display`: where it has one (`auto`, `"rating"`), else
// `none`, so the level shows as text.
#let _skill-rating(group, prefs) = if prefs.skill-level-display != "text" {
  _entry-rating(group, "level", _skill-levels, prefs.max-rating)
}

// Names as the publication owners are matched: trimmed, lowercased.
#let _owner-keys(names) = names.map(n => lower(n.trim()))

// A publication's `authors`, strings, in published order, trimmed,
// each flagged when it's one of `owners` (`_owner-keys`), ignoring
// case; an empty one is dropped. A CV's have only strings left
// (`_lenient-fields`).
#let _authors(authors, owners) = (
  authors
    .map(a => a.trim())
    .filter(a => a != "")
    .map(a => (name: a, owner: lower(a) in owners))
)

// Identifier scheme names are proper nouns, so not labels. Order
// matters: an unlinked title takes the first linkable scheme listed.
#let _identifier-schemes = (
  doi: (name: "DOI", url: "https://doi.org/"),
  arxiv: (name: "arXiv", url: "https://arxiv.org/abs/"),
  pmid: (name: "PMID", url: "https://pubmed.ncbi.nlm.nih.gov/"),
  isbn: (name: "ISBN", url: none),
)
#let _identifier-scheme(scheme) = _identifier-schemes.at(
  scheme,
  default: (name: scheme, url: none),
)

// A publication's `identifiers`, string IDs by scheme, as
// `(scheme, id)` pairs, the scheme lowercased; an empty ID is skipped.
// A CV's have only string IDs left (`_lenient-fields`).
#let _identifiers(ids) = (
  ids
    .pairs()
    .filter(((_, id)) => id != "")
    .map(((scheme, id)) => (lower(scheme), id))
)

// One `(scheme, name, id, url)` per identifier, `url` being `none`
// for a scheme that doesn't link.
#let _identifier-refs(ids) = ids.map(((scheme, id)) => {
  let s = _identifier-scheme(scheme)
  (scheme: scheme, name: s.name, id: id, url: if s.url != none { s.url + id })
})

// An unlinked title's destination: the first linkable ref in
// `_identifier-schemes` order, whatever order the data lists them in.
// Of two refs sharing a scheme (`DOI` and `doi`), the last wins.
#let _identifier-url(refs) = {
  let linkable = refs.rev().filter(r => r.url != none)
  let hit = _identifier-schemes
    .keys()
    .map(k => linkable.find(r => r.scheme == k))
    .find(r => r != none)
  if hit != none { hit.url }
}
