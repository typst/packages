// The template's page footers, `cv-footer` and `cv-updated-footer`,
// for the user's own `set page(footer: ..)`: what they print of the CV
// (`_cv-details`), read from the `<alta-cv>` marker `alta()` leaves,
// else from the document. Standalone `alta()` maps the same details
// onto its footer in `sections/footer.typ`.
//
// Each helper returns a placeholder that `altacv` draws with a show
// rule (`_footer-rule`) holding its theme and labels, not from state:
// a footer is laid out after its page's body, so state there has
// already left a template that ends on the page (a nested template's
// last page, the blank page a trailing `#pagebreak()` adds), while the
// page's styles, the show rules among them, are those of the
// template the page starts in.

#import "util/fields.typ": _field, _string-at
#import "util/checks.typ": _check-type
#import "components/footer.typ": (
  _auto-page-footer, _updated-footer, _updated-line,
)
#import "design/styles.typ": _part
#import "data/options.typ": _resolve-labels
#import "context.typ": _theme

// What a footer prints of the CV: the standalone footer's input, and
// the `<alta-cv>` marker's value that the template's helpers read.
// `meta.version` is verbatim: the schema's own example already carries
// the "v".
#let _cv-details(cv, labels) = (
  owner: cv.basics.name,
  last-modified: _field(cv.meta, "last-modified"),
  version: _string-at(cv.meta, "version"),
  page-number: labels.page-number,
  last-modified-label: labels.last-modified,
)

// The marker of the CV this footer's page shows: the nearest before
// it, else the first, so a footer set before the CV still finds it;
// `none` with no CV placed.
#let _placed-cv() = {
  let before = query(selector(<alta-cv>).before(here()))
  if before != () { before.last() } else {
    query(<alta-cv>).at(0, default: none)
  }
}

// What the template's footers print: the placed CV's `_cv-details`,
// else, in a CV written in markup, the document's: its author (or
// title) for the name and the labels in its language, with no date.
// The CV's labels (its call's over its templates') hold under the
// template `scope` it sits in; under others (a nested
// `altacv.with(labels: ..)` after it), the template's label `layers`
// replace them, the name and date still the CV's.
#let _footer-details(layers, scope) = {
  let cv = _placed-cv()
  let labels = _resolve-labels(text.lang, ..layers)
  let label-details = (
    page-number: labels.page-number,
    last-modified-label: labels.last-modified,
  )
  if cv != none {
    let (details, scope: cv-scope) = cv.value
    return if cv-scope == scope { details } else { details + label-details }
  }
  (
    owner: if document.author != () { document.author.join(", ") } else {
      document.title
    },
    last-modified: none,
    version: none,
    ..label-details,
  )
}

// A footer helper's `args` drawn with a template's `theme`, label
// `layers` and `scope` (`none` outside every template), in `context`.
#let _draw-footer(args, theme, layers, scope) = {
  let details = _footer-details(layers, scope)
  if args.kind == "page" {
    _part("footer", _auto-page-footer(details.owner, details.page-number))
  } else {
    let details = if args.date != none {
      details + (last-modified: args.date)
    } else { details }
    if details.last-modified != none {
      _part("footer", _updated-footer(
        details.last-modified-label,
        _updated-line(details, args.version),
        theme.separator.label,
      ))
    }
  }
}

// A footer helper's placeholder: a `layout` whose function hands back
// its `args` when called with `none` and otherwise
// draws them with the theme, label layers and `scope` the templates
// around it add (`_footer-rule`), else, outside every template, with
// the theme where it's read. The args ride in a closure rather than a
// `metadata`, which would stay in the drawn footer for
// `query(metadata)` to find on every page.
#let _footer-mark(args) = [#layout(size => if size == none { args } else {
  _draw-footer(
    args,
    args.at("theme", default: _theme()),
    args.at("layers", default: ()),
    args.at("scope", default: none),
  )
})<alta-internal-footer>]

// For each `altacv`'s `show <alta-internal-footer>: ..`: the mark again,
// with the template's label layer under those of the templates inside
// it, and its `theme` and `scope` unless one inside set them. The
// innermost template's rule applies first, and each template's once
// (`seen`); the mark the outermost leaves draws the footer.
#let _footer-rule(theme, labels, scope) = it => {
  let args = (it.func)(none)
  let seen = args.at("seen", default: ())
  if scope in seen { return it }
  _footer-mark(
    (theme: theme, scope: scope)
      + args
      + (
        layers: (labels,) + args.at("layers", default: ()),
        seen: seen + (scope,),
      ),
  )
}

/// A page footer for `set page(footer: ..)` inside the altacv template:
/// your name on the left, the page number (`labels.page-number`) on the
/// right, on documents of more than one page. The name is the CV's
/// `basics.name`; in a CV written in markup, the document's author
/// (`set document(author: ..)`), else its title. It counts pages with
/// Typst's page counter, so a `counter(page).update(..)` that restarts
/// it changes what counts as one page.
/// -> content
#let cv-footer() = _footer-mark((kind: "page"))

/// A page footer for `set page(footer: ..)` inside the altacv template:
/// `labels.last-modified: meta.lastModified`, right-aligned. Nothing
/// when there's no date: in a CV written in markup, pass `date`.
///
/// - version (bool): Append `(meta.version)`.
/// - date (str, content, none): The date shown, as written, in place
///   of the CV's `meta.lastModified`.
/// -> content
#let cv-updated-footer(version: false, date: none) = {
  _check-type(
    "cv-updated-footer() date",
    date,
    (str, content, type(none)),
    "a string or content",
  )
  _footer-mark((kind: "updated", version: version, date: date))
}
