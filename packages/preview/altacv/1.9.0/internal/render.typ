// `altacv`, `alta()` and `alta-from-json()`, re-exported from `lib.typ`: the
// render pipeline ARCHITECTURE.md describes. Not in `lib.typ`, which
// would then re-export every helper this imports.

#import "util/dates.typ": _format-date
#import "data/options.typ": _merge-options, _template-labels
#import "data/read.typ": _read-cv
#import "data/metadata.typ": _pdf-metadata
#import "data/json-resume.typ": from-json-resume
#import "data/defaults.typ": _default-preferences
#import "data/cv.typ": _owner-keys
#import "design/presets.typ": themes
#import "design/styles.typ": _justify, _level-headings
#import "design/theme.typ": _theme-for
#import "design/theme-checks.typ": _checked-theme
#import "context.typ": _labels-state, _max-rating-state
#import "document.typ": _document, _standalone
#import "registry.typ": _renderers
#import "components/columns.typ": _columns
#import "../sections/header.typ": _header
#import "../sections/intro.typ": _intro
#import "footers.typ": _cv-details, _footer-rule
#import "../sections/footer.typ": _footer
#import "../adapter/json-resume.typ": _resume

// The merged options, the read CV and the `ctx` every renderer takes
// with its data, in `context`: the labels follow `text.lang`, under
// the enclosing templates' (`_labels-state`).
// `format-date` formats a date per the preferences and labels; `owner`
// is the CV owner's name, and `owners` every spelling of it
// (`preferences.owner-names` too), trimmed and lowercased, to bold among
// publication authors. `details` is what a footer prints of the CV
// (`footers.typ`), for the `<alta-cv>` marker and the
// standalone footer alike. `json-resume` is the checked, canonical CV
// in JSON Resume's camelCase, for the template's mapping. `inside`
// the template, the options it replaces panic.
#let _prepare(cv, labels, preferences, inside: false) = {
  let (labels, prefs) = _merge-options(
    labels,
    preferences,
    lang: text.lang,
    template: _labels-state.get(),
    inside: inside,
  )
  let (cv, sections, json-resume) = _read-cv(cv, prefs)
  let ctx = (
    labels: labels,
    prefs: prefs,
    format-date: v => _format-date(v, prefs.date-format, labels.months),
    owner: cv.basics.name,
    owners: _owner-keys((cv.basics.name, ..prefs.owner-names)),
  )
  (
    cv: cv,
    sections: sections,
    json-resume: json-resume,
    ctx: ctx,
    details: _cv-details(cv, labels),
  )
}

// What `alta()` leaves for the content after it, in both forms: the
// public `rating()`'s scale, and what the footer helpers print, with
// the template `scope` it sits in (`altacv`'s, `none` standalone).
#let _cv-marks(prefs, details, scope) = {
  _max-rating-state.update(prefs.max-rating)
  [#metadata((details: details, scope: scope))<alta-cv>]
}

// The CV itself, from `_prepare`, as standalone `alta()` draws it with
// the section renderers. In `context`: its prose is justified as the
// paragraphs around the `alta()` call are (`_justify`).
#let _cv-content((cv, sections, ctx, details)) = {
  _cv-marks(ctx.prefs, details, none)
  show: _justify.with(par.justify)
  _header(cv, ctx)
  _intro(cv, ctx)
  // Renderers are width-agnostic, so any section fits either column.
  let render(key) = (_renderers.at(key))(sections.at(key), ctx)
  _columns(
    ctx.prefs.left-column-sections.map(render),
    ctx.prefs.right-column-sections.map(render),
    ctx.prefs.column-ratio,
  )
}

// `alta()` inside the template, rendered by `altacv`'s show rule: only
// the CV, drawn by the JSON Resume mapping (`adapter/json-resume.typ`)
// from the public blocks, so what it draws is what a user's copy of
// the mapping draws. At the next major (#239) `alta()` returns this
// directly.
#let _alta-content(cv, scope, labels: (:), preferences: (:)) = context {
  let (cv, sections, json-resume, ctx, details) = _prepare(
    cv,
    labels,
    preferences,
    inside: true,
  )
  // For `altacv` to set at the top level: `set document` fails inside a
  // container, where this may sit (`#block(alta(cv))`).
  [#metadata(_pdf-metadata(cv, sections, ctx.labels))<alta-internal-document>]
  // The mapping's prose takes the caller's `set par(justify: ..)`.
  _cv-marks(ctx.prefs, details, scope)
  // The caller's labels over the template's for this CV's blocks too
  // (an entry's "Present", its alt text), which read `_labels-state`.
  _labels-state.update(layers => layers + (labels,))
  _resume(json-resume, ctx.labels, ctx.prefs)
  _labels-state.update(layers => layers.slice(0, -1))
}

// `alta()` on its own (removed in the next major, #239): the template's
// body and the preferences that stand in for the set rules after it,
// the footer among them, around the CV.
#let _alta-standalone(cv, labels: (:), preferences: (:)) = context {
  let prepared = _prepare(cv, labels, preferences)
  let (cv, sections, ctx, details) = prepared
  set document(.._pdf-metadata(cv, sections, ctx.labels))
  show: _standalone.with(ctx.prefs, ctx.labels, _footer.with(
    details,
    ctx.prefs,
  ))
  // Standalone keeps today's levels: the sections one below the name.
  set heading(offset: 1)
  _cv-content(prepared)
}

/// The altacv template: `#show: altacv.with(theme: themes.navy)`, then
/// `#alta(cv)` and any other content. It sets the theme, the default
/// text and margins, and the heading and list rules; your own `set`
/// and `show` rules after it win (`set page(paper: ..)`,
/// `set text(lang: ..)`, `show heading: ..`).
///
/// - theme (dictionary): A built-in theme (`themes.teal`, …) or theme
///   tokens over the default one. See docs/reference.md's Theme
///   tokens.
/// - labels (dictionary): Display strings to override for everything
///   the template draws: `alta()`'s CVs, the markup blocks (`entry`'s
///   "Present", the date and location alt text) and the footers. The
///   keys `alta()`'s `labels:` takes, but the deprecated `lang` and
///   `publication-icons`, which panic; merged over the
///   defaults for the document's language (`text.lang`) where each is
///   read, and under an `alta(cv, labels: ..)`'s for that CV.
/// - body (content): The document.
/// -> content
#let altacv(theme: themes.teal, labels: (:), body) = {
  let built = _theme-for(_checked-theme(theme), (:))
  let labels = _template-labels(labels)
  show: _document.with(
    built,
    _default-preferences.body-size,
    _default-preferences.margin,
    labels: labels,
  )
  show: _level-headings.with(built)
  // The mapping's intro, spaced as `alta()`'s: a paragraph's spacing,
  // which merges with its neighbours', and the theme's `intro` inside
  // it, which adds to it; a later `show <alta-intro>: set block(..)`
  // wins.
  show <alta-intro>: set block(
    spacing: built.par.spacing,
    inset: (top: built.intro.above * 1em, bottom: built.intro.below * 1em),
  )
  // Picks `alta()`'s template form: the CV alone, from its metadata.
  show <alta-internal-standalone>: none
  // The first CV's PDF metadata (`_alta-content`): a `set document` in
  // a top-level `context` reaches the document, and one of the user's
  // own in `body` still wins.
  context {
    let info = query(<alta-internal-document>).at(0, default: none)
    if info != none { set document(..info.value) }
  }
  // The footer helpers' placeholders, drawn with this template's theme
  // and labels (`footers.typ`); `scope` tells this template's CVs from
  // others'.
  context {
    let scope = here()
    show <alta-internal-footer>: _footer-rule(built, labels, scope)
    show <alta-internal-cv>: it => _alta-content(
      it.value.cv,
      scope,
      labels: it.value.labels,
      preferences: it.value.preferences,
    )
    body
  }
}

/// Draws a CV from a JSON Resume dictionary, under
/// `#show: altacv.with(..)`. Every input is checked before anything
/// renders. The labels follow the document's language:
/// `#set text(lang: "ga")` before `alta()` renders them in Irish.
/// Inside the template, the document-level preferences (`font`,
/// `body-size`, `paper`, `margin`, the footers) panic, naming the set
/// rule that replaces each. On its own, without the template, it
/// applies one itself: deprecated (#239), add `#show: altacv` above
/// it.
///
/// - cv (dictionary): The CV, in the JSON Resume schema plus altacv's
///   `custom.altacv` extensions. Unknown keys and wrong types panic,
///   naming the field.
/// - labels (dictionary): Display strings to override for this CV,
///   merged over the template's and the defaults for the document's
///   language (`text.lang`). See docs/reference.md's Labels.
/// - preferences (dictionary): Settings to override (the columns, the
///   date format, the photo, …), merged over the defaults. See
///   docs/reference.md's Preferences.
/// -> content
#let alta(
  cv,
  labels: (:),
  preferences: (:),
) = {
  // Both forms; `altacv`'s show rules pick one. Through the style chain
  // rather than state, so the choice holds on the first layout pass
  // (standalone's `set page` would fail inside a container) and ends
  // where the template's scope does. Without the template the metadata
  // renders nothing.
  [#_alta-standalone(
    cv,
    labels: labels,
    preferences: preferences,
  )<alta-internal-standalone>]
  [#metadata((
    cv: cv,
    labels: labels,
    preferences: preferences,
  ))<alta-internal-cv>]
}

// `..rest` forwards future `alta` kwargs without an edit here. Extra
// positionals (`alta-from-json(p, my-prefs)`) panic with a
// wrapper-aware message rather than an `alta`-level one.
/// Renders a CV from a `resume.json`, validated against the JSON Resume
/// schema first: `alta(from-json-resume(data), ..)`. Deprecated
/// (#239): `alta(parse(path("resume.json")), ..)`, with gairm-import's
/// `parse`.
///
/// - data (path, dictionary): The `resume.json`, as for
///   `from-json-resume`.
/// - ..rest (arguments): `labels:` and `preferences:`, as for `alta`.
/// -> content
#let alta-from-json(data, ..rest) = {
  if rest.pos().len() > 0 {
    panic(
      "alta-from-json takes one positional (`data`); pass labels/preferences as named arguments. Got extra positionals: "
        + repr(rest.pos()),
    )
  }
  alta(from-json-resume(data), ..rest)
}
