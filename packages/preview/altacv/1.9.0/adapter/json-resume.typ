// The JSON Resume mapping: a CV dictionary in the JSON Resume schema
// turned into altacv's public markup blocks (`cv-header`, `entry`,
// `publication`, `skill-row`, …). It is what `alta(cv)` renders inside
// `#show: altacv.with(..)`, written to be read and copied (#370).
//
// It takes validated JSON Resume: `alta()`'s checked CV, or
// gairm-import's `parse(..)` of a `resume.json`. It reads JSON
// Resume's camelCase fields (`startDate`) and altacv's extensions under
// `custom.altacv` as the schema types them, without checking them.
//
// To adapt it, copy this file into your project, replace the imports
// below with one
//
//   #import "@preview/altacv:<version>": adapter, cv-columns, cv-header, divider, entry, icon, label-row, publication, rating, skill-row
//
// and edit what it draws. Then, in your CV:
//
//   #import "@preview/altacv:<version>": altacv
//   #import "@preview/gairm-import:0.10.1": parse
//   #import "json-resume.typ": resume
//   #show: altacv
//   #set document(title: "Jane Doe", author: "Jane Doe")
//   #resume(parse(path("resume.json")))
//
// Labels come from the template, `#show: altacv.with(labels: ..)`,
// which the blocks read too. The `set document` is only the PDF's
// metadata. In your copy, a bare `basics.image` path resolves from
// your copy's file.
//
// The names below are the public API (`lib.typ` re-exports exactly
// these); this file imports them from the modules that define them
// because `alta()`, which renders it, sits inside `lib.typ`.

#import "../internal/blocks.typ": (
  cv-columns, cv-header, entry, label-row, publication, skill-row,
)
#import "../internal/components/ratings.typ": rating
#import "../internal/icons.typ": icon
#import "../internal/primitives.typ": divider
#import "../internal/adapter.typ" as adapter

// A field's value, or `none` when it's absent: an empty string, blank
// content or empty `bytes` (a photo) counts as missing, so it leaves
// no empty line or empty frame.
#let _field(obj, key) = {
  let value = obj.at(key, default: none)
  if value not in ("", [], bytes(())) { value }
}

// A date as `alta()` shows it, per `date-format` and the months.
#let _date(value, ctx) = if value != none {
  adapter.format-date(
    value,
    format: ctx.prefs.date-format,
    months: ctx.labels.months,
  )
}

// `entry`'s `(start, end)` pair, an open end reading the labels'
// "Present".
#let _period(obj, ctx) = (
  _date(_field(obj, "startDate"), ctx),
  _date(_field(obj, "endDate"), ctx),
)

// A location's parts, which `entry` joins in the theme's style.
#let _location(obj) = adapter.location-parts(obj.at("location", default: none))

// Highlights as a list, the entry's body.
#let _bullets(obj) = obj.at("highlights", default: ()).map(h => [- #h]).join()

// A `==` group heading led by its icon, in the heading's colour: the
// icon's box and the gap after it in the heading's own `em`.
#let _icon-heading(name, body) = [#context icon(name, fill: text.fill) #body]

// A section: its `=` heading, then `body`; nothing, not even the
// heading, when it has no entries.
#let _frame(title, entries, body) = if entries.len() > 0 {
  [= #title]
  body
}

// A section of one block per entry.
#let _section(title, entries, render) = _frame(
  title,
  entries,
  entries.map(render).join(),
)

// The sections, one function each, by the key the column preferences
// name it with (`sections`). Each takes the CV and `ctx`: the
// resolved `labels` and `prefs`, and the `owners` set apart among
// publication authors (`_resume`).

// work[] and volunteer[]: the same entry, the organisation under a
// different key; only work shows keywords.
#let _role(e, org, ctx, keywords: ()) = entry(
  title: _field(e, "position"),
  org: _field(e, org),
  org-url: _field(e, "url"),
  date: _period(e, ctx),
  location: _location(e),
  summary: _field(e, "summary"),
  keywords: keywords,
  _bullets(e),
)

#let work(cv, ctx) = _section(
  ctx.labels.work,
  adapter.entries(cv, "work"),
  e => _role(e, "name", ctx, keywords: e.at("keywords", default: ())),
)

#let volunteer(cv, ctx) = _section(
  ctx.labels.volunteer,
  adapter.entries(cv, "volunteer"),
  e => _role(e, "organization", ctx),
)

// The summary, else the `description`, which JSON Resume keeps as that
// field's deprecated alias.
#let _project(p, ctx) = {
  let summary = _field(p, "summary")
  entry(
    title: p.name,
    url: _field(p, "url"),
    org: _field(p, "entity"),
    roles: p.at("roles", default: ()),
    date: _period(p, ctx),
    summary: if summary != none { summary } else { _field(p, "description") },
    keywords: p.at("keywords", default: ()),
    _bullets(p),
  )
}

// Under a heading per `type`, in the order each first appears, only
// when some project has one; the untyped under "Other".
#let projects(cv, ctx) = {
  let (labels, prefs, ..) = ctx
  let projects = adapter.entries(cv, "projects")
  let project(p) = _project(p, ctx)
  if projects.all(p => adapter.entry-type(p) == none) {
    _section(labels.projects, projects, project)
  } else {
    _section(
      labels.projects,
      adapter.group-by-type(projects, untyped: labels.other-projects),
      ((kind, items)) => {
        let name = prefs.project-icons.at(lower(kind), default: "folder")
        [== #_icon-heading(name, kind)]
        items.map(project).join()
      },
    )
  }
}

#let _publication(p, ctx) = publication(
  title: p.name,
  url: _field(p, "url"),
  authors: p.at("authors", default: ()),
  owners: ctx.owners,
  source: _field(p, "publisher"),
  citation: (
    volume: _field(p, "volume"),
    issue: _field(p, "issue"),
    pages: _field(p, "pages"),
  ),
  date: _date(_field(p, "releaseDate"), ctx),
  identifiers: p.at("identifiers", default: (:)),
  _field(p, "summary"),
)

// Under a heading per `type` code, matched ignoring case, the untyped
// among the articles; a code with no label is headed as first written.
#let publications(cv, ctx) = {
  let (labels, prefs, ..) = ctx
  _section(
    labels.publications,
    adapter.group-by-type(
      adapter.entries(cv, "publications"),
      key: lower,
      untyped: "article",
    ),
    ((code, items)) => {
      let heading = if code in labels.publication-types {
        labels.publication-types.at(code)
      } else { adapter.entry-type(items.first()) }
      let name = prefs.publication-icons.at(code, default: "file")
      [== #_icon-heading(name, heading)]
      items.map(p => _publication(p, ctx)).join()
    },
  )
}

#let focus-areas(cv, ctx) = {
  let items = adapter.entries(cv, "focus-areas")
  _frame(ctx.labels.focus-areas, items, list(..items))
}

// The group's `custom.altacv.rating` as dots, else its level, a term
// `skill-row` rates as dots; `skill-level-display: "text"` keeps the
// level text, as content, which `skill-row` shows as written.
#let skills(cv, ctx) = _section(
  ctx.labels.skills,
  adapter.entries(cv, "skills"),
  g => {
    let level = _field(g, "level")
    skill-row(
      _field(g, "name"),
      g.keywords,
      level: if ctx.prefs.skill-level-display == "text" {
        if level != none [#level]
      } else { adapter.custom(g, "rating", default: level) },
      max: ctx.prefs.max-rating,
    )
  },
)

// Dots for a rated fluency, else the fluency as text; the rows spaced
// as entries are, without the rule: no block draws the divider's space
// alone, so the rule is hidden.
#let languages(cv, ctx) = {
  let max = ctx.prefs.max-rating
  let langs = adapter.entries(cv, "languages")
  _frame(ctx.labels.languages, langs, {
    show std.divider: none
    // Rows, not prose: a long name wraps unjustified.
    set par(justify: false)
    langs
      .map(l => {
        let value = adapter.fluency-rating(l, max: max)
        block(breakable: false, rating(
          l.language,
          if value != none { value } else { _field(l, "fluency") },
          max: max,
        ))
      })
      .join(divider())
  })
}

// The area leads the score when it isn't the title; the courses end
// the entry.
#let education(cv, ctx) = _section(
  ctx.labels.education,
  adapter.entries(cv, "education"),
  e => {
    let study-type = _field(e, "studyType")
    let area = _field(e, "area")
    entry(
      title: if study-type != none { study-type } else { area },
      org: _field(e, "institution"),
      org-url: _field(e, "url"),
      date: _period(e, ctx),
      location: _location(e),
      summary: _field(e, "summary"),
      keywords-lead: (
        (if study-type != none { area },),
        (_field(e, "score"),),
      ),
      keywords: e.at("courses", default: ()),
    )
  },
)

// Short rows: the spacing between them without the rule, hidden as
// the languages' is. A certificate without an expiry has no end, not
// "Present".
#let certificates(cv, ctx) = {
  show std.divider: none
  _section(ctx.labels.certificates, adapter.entries(cv, "certificates"), c => {
    let issued = _date(_field(c, "date"), ctx)
    let expiry = _field(c, "expiryDate")
    entry(
      title: c.name,
      url: _field(c, "url"),
      org: _field(c, "issuer"),
      details: (_field(c, "credentialId"),),
      date: if expiry != none { (issued, _date(expiry, ctx)) } else { issued },
      summary: _field(c, "summary"),
    )
  })
}

#let awards(cv, ctx) = _section(
  ctx.labels.awards,
  adapter.entries(cv, "awards"),
  a => entry(
    title: a.title,
    url: adapter.custom(a, "url"),
    org: _field(a, "awarder"),
    date: _date(_field(a, "date"), ctx),
    summary: _field(a, "summary"),
  ),
)

// One row per group, kept together as `alta()`'s one paragraph of
// them keeps its lines: the first row with the second (no orphan at a
// page's foot), the one before the last with the last (no widow at the
// top). `label-row` draws one row, so each is a block of its own.
#let interests(cv, ctx) = {
  let groups = adapter.entries(cv, "interests")
  let last = groups.len() - 1
  _frame(
    ctx.labels.interests,
    groups,
    groups
      .enumerate()
      .map(((i, g)) => {
        set block(sticky: i < last and (i == 0 or i == last - 1))
        label-row(_field(g, "name"), g.keywords)
      })
      .join(),
  )
}

// A quote under the referee's name and attribution; on request, the
// on-request line in its place, and when every reference is on
// request, that line alone. `references-available-on-request` stands
// for one such reference when none renders.
#let references(cv, ctx) = {
  let on-request = ctx.labels.references-available-on-request
  let requested(r) = r.at("availableOnRequest", default: false)
  let refs = adapter.entries(cv, "references")
  let title = ctx.labels.references
  if (
    refs.all(requested)
      and (refs.len() > 0 or ctx.prefs.references-available-on-request)
  ) {
    [= #title]
    entry(summary: on-request)
  } else {
    _section(title, refs, r => entry(
      title: _field(r, "name"),
      subtitle: (
        (_field(r, "relationship"), _field(r, "organization")),
        (_date(_field(r, "date"), ctx),),
      ),
      summary: if requested(r) { on-request } else { r.reference },
    ))
  }
}

// Every section by its key, as `left-column-sections` and
// `right-column-sections` name them: `alta()`'s sections, one for one.
#let sections = (
  work: work,
  volunteer: volunteer,
  focus-areas: focus-areas,
  skills: skills,
  languages: languages,
  education: education,
  certificates: certificates,
  awards: awards,
  projects: projects,
  publications: publications,
  interests: interests,
  references: references,
)

// The header: `basics.image` framed when it's set; the QR code
// `basics.url` when `auto`; its text aligned per `header-text-align`.
#let header(cv, ctx) = {
  let prefs = ctx.prefs
  // JSON Resume requires no field, `basics` included.
  let basics = cv.at("basics", default: (:))
  let name = _field(basics, "name")
  let image-src = _field(basics, "image")
  let header = cv-header(
    name: if name != none { name } else { auto },
    tagline: _field(basics, "label"),
    objective: _field(cv, "objective"),
    contacts: adapter.basics-contacts(
      basics,
      linked: prefs.link-contact-info,
      maps-provider: prefs.maps-provider,
      full-urls: prefs.print-full-urls,
      icons: prefs.profile-icons,
    ),
    photo: if image-src != none { image(image-src) },
    photo-position: prefs.photo-position,
    photo-size: prefs.photo-size,
    photo-shape: prefs.photo-shape,
    qr: if prefs.qr-code == auto { _field(basics, "url") } else {
      prefs.qr-code
    },
    uppercase: prefs.uppercase-name,
  )
  align(prefs.header-text-align, header)
}

// The intro: `basics.summary`, in a block the template spaces from the
// header and the columns (`show <alta-intro>: set block(..)`). The
// part label on a wrapper of its own, so a label the summary carries
// stays: no block takes the summary and leaves its label alone. Full
// width, so a justified summary stretches to the column rather than to
// its own widest line.
#let intro(cv, ctx) = {
  let summary = _field(cv.at("basics", default: (:)), "summary")
  if summary != none [#block(
    width: 100%,
    par[#[#summary#[]]<alta-summary>],
  )<alta-intro>]
}

// `resume` with the labels and preferences resolved, as `alta()` has
// them already.
//
// The prose (the intro, summaries, highlights and publications) takes
// the caller's `set par(justify: ..)`. An entry's rows of facts and
// keywords, and the skill and interest rows, set their own off; the
// languages, theirs.
#let _resume(cv, labels, prefs) = {
  // The names set apart among publication authors, as `alta()` sets
  // them apart: the CV's name and `owner-names`; with neither, `auto`,
  // the document's author.
  let name = _field(cv.at("basics", default: (:)), "name")
  let owners = (name,).filter(n => n != none) + prefs.owner-names
  let ctx = (
    labels: labels,
    prefs: prefs,
    owners: if owners.len() > 0 { owners } else { auto },
  )
  header(cv, ctx)
  intro(cv, ctx)
  // The columns: the left sections beside the right, the left taking
  // `column-ratio`; one column when no section is on the right.
  let column(keys) = keys.map(key => sections.at(key)(cv, ctx)).join()
  let right = prefs.right-column-sections
  cv-columns(
    column(prefs.left-column-sections),
    // Content, even when the sections are empty, as `alta()` keeps the
    // right column then.
    if right.len() > 0 [#column(right)],
    ratio: prefs.column-ratio,
  )
}

/// The CV as `alta(cv)` renders it in the template: the header, the
/// intro, then the column sections side by side. The labels are the
/// resolved ones (`adapter.labels()`), as the blocks read them: the
/// document language's, under the template's (`altacv.with(labels:
/// ..)`) and, through `alta(cv, labels: ..)`, that call's. The name is
/// `basics.name`, else the document's title; the owners set apart
/// among publication authors are it and `owner-names`, else the
/// document's author.
///
/// - cv (dictionary): The CV, validated JSON Resume (camelCase fields)
///   plus altacv's `custom.altacv` extensions: gairm-import's
///   `parse(path("resume.json"))`, or the CV `alta()` has checked. Its
///   field types aren't checked again here, so a wrong-typed field
///   fails inside the mapping rather than naming itself.
/// - preferences (dictionary): Settings, by `alta()`'s kebab-case
///   preference keys (`column-ratio`, `date-format`, …), merged over
///   its defaults and checked (`adapter.preferences()`).
/// -> content
#let resume(cv, preferences: (:)) = context _resume(
  cv,
  adapter.labels(),
  adapter.preferences(overrides: preferences),
)
