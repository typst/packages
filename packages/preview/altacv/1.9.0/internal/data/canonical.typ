// Rewrites caller input into the one shape renderers read: `none`
// fields drop out, deprecated CV, preference and label forms (#239)
// become their current spelling,
// and case-insensitive label tables get lowercase keys. Dropping a
// legacy form in the next major then touches only this module.

#import "../util/fields.typ": (
  _array-or-empty, _dict-or-empty, _field, _string, _texts,
)
#import "../util/checks.typ": _check-type
#import "../util/values.typ": _group-by, _map-at
#import "../design/theme.typ": _accent-roles
#import "cv.typ": _altacv-ns, _entry-type, _reference-usable

// #239: the deprecated top-level homes of altacv's non-spec fields,
// lifted into `custom.altacv` (which wins when both are set).
#let _legacy-root-fields = ("focusAreas",)
#let _legacy-entry-fields = (languages: ("rating",), awards: ("url",))

// #239: sections whose `description` is a deprecated alias of `summary`.
#let _summary-alias-sections = ("work", "volunteer", "projects")

// #239: plural free-text publication types, mapped to their code so
// `"Articles"` and untyped entries share one subheading.
#let _legacy-type-codes = (
  articles: "article",
  books: "book",
  patents: "patent",
  theses: "thesis",
  talks: "talk",
)

// #239: icons for deprecated free-text publication types.
#let _legacy-publication-icons = (
  "blog posts": "newspaper",
  "blog post": "newspaper",
  presentations: "microphone",
  presentation: "microphone",
  "conference papers": "newspaper",
  "conference paper": "newspaper",
  papers: "newspaper",
  paper: "newspaper",
)

// Tables matched case-insensitively and merged entry by entry over
// their defaults (`_strict-merge`'s `tables`).
#let _label-tables = ("publication-types",)
#let _preference-tables = (
  "publication-icons",
  "project-icons",
  "profile-icons",
)

// `custom.altacv` wins when both are set. A non-dictionary `custom`
// or `altacv` is replaced, as nothing else reads it.
#let _lift-into-custom(obj, keys) = {
  let ns = _altacv-ns(obj)
  let lifted = keys
    .filter(k => (
      obj.at(k, default: none) != none and ns.at(k, default: none) == none
    ))
    .map(k => (k, obj.at(k)))
    .to-dict()
  if lifted.len() == 0 { obj } else {
    let custom = _dict-or-empty(obj.at("custom", default: none))
    obj + (custom: custom + (altacv: ns + lifted))
  }
}

#let _alias-summary(entry) = {
  let description = entry.at("description", default: none)
  if _field(entry, "summary") != none or description == none { entry } else {
    entry + (summary: description)
  }
}

// `" talk "` groups with `talk`; an all-space `type` becomes untyped.
// After `_lenient-fields`, so a `type` is a non-empty string.
#let _trim-type(entry) = if "type" not in entry { entry } else {
  entry + (type: _entry-type(entry))
}

#let _canonical-type(pub) = {
  let pub = _trim-type(pub)
  let raw = pub.at("type", default: none)
  let code = if raw != none { _legacy-type-codes.at(lower(raw), default: none) }
  if code == none { pub } else { pub + (type: code) }
}

// Non-dictionary entries are left for the shape checks to report.
#let _map-entries(cv, key, f) = {
  let entries = cv.at(key, default: none)
  if type(entries) != array { cv } else {
    cv + ((key): entries.map(e => if type(e) == dictionary { f(e) } else { e }))
  }
}

// Fields 1.8.0 read leniently, a value of the wrong type reading as
// absent, so a CV that relied on it still renders (#239 checks them):
// each section's fields, and what keeps of a value, `none` dropping the
// field. Every reader after this, the template's mapping
// (`adapter/json-resume.typ`) included, then meets JSON Resume's types.
#let _lenient-fields = (
  // 1.8.0 drew no work keywords; an array of anything but text draws none.
  work: (keywords: _texts),
  projects: (type: _string),
  publications: (
    type: _string,
    volume: _string,
    issue: _string,
    pages: _string,
    // The strings, as an author or an ID of another type has no text.
    authors: v => _array-or-empty(v).filter(a => type(a) == str),
    identifiers: v => (
      _dict-or-empty(v).pairs().filter(((_, id)) => type(id) == str).to-dict()
    ),
  ),
  references: (
    relationship: _string,
    organization: _string,
    date: _string,
    // Only a real boolean counts, so a stray `"yes"` doesn't hide a quote.
    availableOnRequest: v => if type(v) == bool { v },
  ),
)
#let _lenient-entry(entry, fields) = (
  entry
    .pairs()
    .map(((k, v)) => (k, if k in fields { (fields.at(k))(v) } else { v }))
    .filter(((k, v)) => k not in fields or v != none)
    .to-dict()
)

// #239: `preferences.references-available-on-request` means the same as
// one `availableOnRequest: true` entry when no reference is usable.
#let _references-on-request(cv, prefs) = {
  let refs = cv.at("references", default: ())
  let usable(r) = type(r) == dictionary and _reference-usable(r)
  if (
    not prefs.references-available-on-request
      or type(refs) != array
      or refs.any(usable)
  ) { cv } else { cv + (references: refs + ((availableOnRequest: true),)) }
}

// The CV's values in JSON Resume's forms, at any depth. `none` (JSON's
// `null`) means absent: a key set to it is dropped, so checks and
// renderers meet one absent form, a missing key, and a reader's
// default applies. A `datetime` with a date reads as the ISO string
// the spec writes (`2024-06-15`, with its time if it has one): a Typst
// convenience over the string, so every date reader meets one form.
#let _spec-values(v) = if type(v) == dictionary {
  v
    .pairs()
    .filter(((_, x)) => x != none)
    .map(((k, x)) => (k, _spec-values(x)))
    .to-dict()
} else if type(v) == array { v.map(_spec-values) } else if (
  type(v) == datetime and v.year() != none
) {
  v.display(
    "[year]-[month]-[day]"
      + if v.hour() != none { "T[hour]:[minute]:[second]" } else { "" },
  )
} else { v }

// `prefs` is the merged, validated preferences dict.
#let _canonical-cv(cv, prefs) = (
  _spec-values,
  cv => _lenient-fields
    .pairs()
    .fold(cv, (acc, (key, fields)) => _map-entries(
      acc,
      key,
      e => _lenient-entry(e, fields),
    )),
  cv => _lift-into-custom(cv, _legacy-root-fields),
  cv => _legacy-entry-fields
    .pairs()
    .fold(cv, (acc, (key, fields)) => _map-entries(
      acc,
      key,
      e => _lift-into-custom(e, fields),
    )),
  cv => _summary-alias-sections.fold(cv, (acc, key) => _map-entries(
    acc,
    key,
    _alias-summary,
  )),
  cv => _map-entries(cv, "publications", _canonical-type),
  cv => _map-entries(cv, "projects", _trim-type),
  cv => _references-on-request(cv, prefs),
  // Absent `meta` reads as empty, so its readers needn't default it.
  cv => (meta: (:)) + cv,
).fold(cv, (acc, step) => step(acc))

// `table` with each key mapped by `f`. Two keys mapping onto one panic,
// named with `name` (the table's path) and `why`, rather than letting
// the last silently win.
#let _rekey(table, f, name, why) = {
  let sources = _group-by(table.keys(), f)
  let clashes = sources.values().filter(ks => ks.len() > 1)
  if clashes.len() > 0 {
    panic(
      name
        + " "
        + why
        + ": "
        + clashes.map(ks => ks.map(repr).join(" and ")).join("; "),
    )
  }
  table.pairs().map(((k, v)) => (f(k), v)).to-dict()
}

// #239: a camelCase option name (`columnRatio`) reads as its
// kebab-case one (`column-ratio`): the labels' and the preferences'
// top-level keys. Their values are untouched: section keys, type codes
// and icon names are data. A name set both ways panics, as neither
// would win on purpose. Option names start lowercase, so no key gains
// a leading `-`. A camelCase name whose concept has since been
// renamed reads straight as the new name (`_renamed-options`).
#let _renamed-options = (
  imagePosition: "photo-position",
  imageSize: "photo-size",
)
#let _kebab(name) = _renamed-options.at(
  name,
  default: name.replace(regex("[A-Z]"), m => "-" + lower(m.text)),
)
#let _kebab-keys(name) = table => if type(table) != dictionary { table } else {
  _rekey(
    table,
    _kebab,
    name,
    "sets an option both in camelCase and in kebab-case; keep the kebab-case one",
  )
}
#let _kebab-options(labels, preferences) = (
  _kebab-keys("labels")(labels),
  _kebab-keys("preferences")(preferences),
)

// Matching is case-insensitive, so `Talks` and `talks` are one key.
// `name` is the table's full path (`labels.publication-types`), for
// the message.
#let _lowercase-table(table, name) = _rekey(
  table,
  lower,
  name,
  "has keys that collide after lowercasing (matching is case-insensitive)",
)

// Runs before the merge over the defaults; a non-dictionary (overall
// or as a table) passes through for `_strict-merge` to reject.
#let _canonical-labels(overrides) = _map-at(
  overrides,
  "publication-types",
  default: (:),
  types => {
    // #239: a set `labels.articles` heads `article`, unless
    // `publication-types.article` is set too.
    let articles = if "articles" in overrides {
      (article: overrides.articles)
    } else { (:) }
    articles + _lowercase-table(types, "labels.publication-types")
  },
)

// #239: the top-level `accent` colours the accent roles with one
// colour (`_accent-roles`), as the internal `colours` preference that
// overrides standalone `alta()`'s theme (`_token-prefs`). A caller
// can't set `colours` (`_merge-options`). A non-dictionary
// `preferences` passes through for `_strict-merge` to reject.
#let _fold-accent(overrides) = {
  if type(overrides) != dictionary or "accent" not in overrides {
    overrides
  } else {
    let accent = overrides.accent
    _check-type("accent", accent, (color,), "a colour (e.g. rgb(\"#1A3A6C\"))")
    let rest = overrides.pairs().filter(((k, _)) => k != "accent").to-dict()
    rest + (colours: _accent-roles(accent))
  }
}

// #239: the strings `header-text-align` and `photo-position` took become
// Typst's alignments. `"center"` placed the photo on its own row,
// `image-stack-order` (`"above"`, the default, or `"below"`) the text,
// so it becomes `top` or `bottom`. A string with no alignment passes
// through for validation to name.
// `v`'s value in `table` when it names one, else `v`.
#let _named(table, v) = if type(v) == str and v in table { table.at(v) } else {
  v
}

#let _alignments = (left: left, center: center, right: right)
#let _canonical-alignments(overrides) = if type(overrides) != dictionary {
  overrides
} else {
  let at(key, default: none) = overrides.at(key, default: default)
  // Only the keys the caller set, so a missing one keeps its default.
  let set-only(key, value) = if key in overrides { ((key): value) } else {
    (:)
  }
  let position = if at("photo-position") == "center" {
    _named((above: top, below: bottom), at(
      "image-stack-order",
      default: "above",
    ))
  } else { _named(_alignments, at("photo-position")) }
  (
    overrides
      + set-only("header-text-align", _named(
        _alignments,
        at("header-text-align"),
      ))
      + set-only("photo-position", position)
  )
}

// Runs before the merge over the defaults. #239: the deprecated
// top-level `accent` becomes the internal `colours` (`_fold-accent`), the string
// alignments become Typst's values, and the free-text icons, then a
// set `labels.publication-icons`, sit beneath the caller's
// `publication-icons`, all lowercased, so the merge sees one table. `project-icons` and `profile-icons` are lowercased too.
// #239: the string `page-footer: "auto"` becomes `auto`. A
// non-dictionary (overall or as a table) passes through for
// `_strict-merge` to reject.
// #390: the section key `"focusAreas"` in a column list reads as
// `"focus-areas"`, as the section is named inside.
#let _section-aliases = (focusAreas: "focus-areas")
#let _canonical-columns(overrides) = (
  ("left-column-sections", "right-column-sections").fold(overrides, (
    acc,
    key,
  ) => {
    let v = _dict-or-empty(acc).at(key, default: none)
    if type(v) != array { acc } else {
      acc + ((key): v.map(k => _named(_section-aliases, k)))
    }
  })
)

#let _canonical-preferences(overrides, labels) = {
  let overrides = _canonical-columns(_canonical-alignments(
    _fold-accent(
      overrides,
    ),
  ))
  let overrides = if (
    type(overrides) == dictionary
      and overrides.at("page-footer", default: none) == "auto"
  ) { overrides + (page-footer: auto) } else { overrides }
  // `publication-icons` is lowercased with its deprecated sources below.
  let overrides = _preference-tables
    .filter(t => t != "publication-icons")
    .fold(overrides, (acc, key) => _map-at(
      acc,
      key,
      t => _lowercase-table(t, "preferences." + key),
    ))
  _map-at(overrides, "publication-icons", default: (:), icons => {
    let label-icons = _dict-or-empty(labels).at(
      "publication-icons",
      default: none,
    )
    let from-label = if type(label-icons) == dictionary {
      _lowercase-table(label-icons, "labels.publication-icons")
    } else { (:) }
    (
      _legacy-publication-icons
        + from-label
        + _lowercase-table(icons, "preferences.publication-icons")
    )
  })
}
