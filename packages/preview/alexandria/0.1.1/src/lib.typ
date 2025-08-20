#import "hayagriva.typ"


#let citation(prefix, key, form: "normal", style: auto) = {
  import "state.typ": *
  import "internal.typ": *

  assert(str(key).starts-with(prefix), message: "Can only refer to an entry with the given prefix.")

  let index = get-citation-index(prefix)
  context add-citation(prefix, (
    key: str(key).slice(prefix.len()),
    form: form,
    ..if style != auto { (style: csl-to-string(style)) },
    locale: locale(),
  ))
  context link(key, hayagriva.render(get-citation(prefix, index)))
}

/// This configuration function should be called as a show rule at the beginning of the document.
/// The function makes sure that `ref()` and `cite()` commands can refer to Alexandria's custom
/// bibliography entries and stores configuration for use by @@load-bibliography().
///
/// ```typ
/// #show: alexandria(prefix: "x-", read: path => read(path))
/// ```
///
/// -> function
#let alexandria(
  /// a prefix that identifies labels referring to Alexandria bibliographies. Bibliography entries
  /// will automatically get that prefix prepended.
  /// -> string
  prefix: none,
  /// pass ```typc path => read(path)``` into this parameter so that Alexandria can read your
  /// bibliography files.
  /// -> function
  read: none,
) = body => {
  import "state.typ": *

  assert.ne(prefix, none, message: "usage without a prefix is not yet supported")
  assert.ne(read, none, message: "read is required; provide a function `path => read(path)`")

  let match(key) = prefix == none or str(key).starts-with(prefix)

  set-read(read)
  register-prefix(prefix)

  show ref: it => {
    if not match(it.target) {
      return it
    }

    citation(prefix, it.target, form: cite.form, style: cite.style)
  }

  show cite: it => {
    if not match(it.key) {
      return it
    }

    context citation(prefix, it.key, form: it.form, style: it.style)
  }

  body
}

/// Loads an additional bibliography. This reads the relevant bibliography file(s) and stores the
/// extracted data in a state for later retrieval via @@get-bibliography(), but does not render
/// anything yet. For simple use cases, @@bibliographyx() can be used directly.
///
/// Even though this only loads the bibliography, this function already requires knowledge of the
/// citations that appear in the document, both to know which references to include (for non-`full`
/// bibliographies) and in what styles, forms and languages these citations should be rendered.
///
/// The interface is similar to the built-in
/// #link("https://typst.app/docs/reference/model/bibliography/")[`bibliography()`], but not all
/// features are supported (yet). In particular, the default values reflect `bibliography()`, but
/// some of these are not supported yet and need to be set manually. Also, the title parameter (only
/// needed for rendering) is skipped.
///
/// -> content
#let load-bibliography(
  /// The path to the bibliography file.
  /// -> string | array
  path,
  /// The prefix for which reference labels should be provided and citations should be processed.
  /// -> string | auto
  prefix: auto,
  /// Whether to render the full bibliography or only the references that are used in the document.
  /// -> boolean
  full: false,
  /// The style of the bibliography. Either a #link("https://typst.app/docs/reference/model/bibliography/#parameters-style")[built-in style]
  /// or a file name that is read by the `read()` function registered via @@alexandria().
  /// -> string
  style: "ieee",
) = {
  import "state.typ": *
  import "internal.typ": *

  let path = path
  if type(path) != array {
    path = (path,)
  }

  context {
    let read = get-read()
    assert.ne(read, none, message: "Alexandria is not configured. Make sure to use `#show: alexandria(...)`")

    let prefix = prefix
    if prefix == auto {
      prefix = get-only-prefix()
      assert.ne(prefix, none, message: "when using multiple custom bibliographies, you must specify the prefix for each")
    }

    let style = csl-to-string(style)
    if style in hayagriva.names {
      style = (built-in: style)
    } else {
      style = (custom: read(style))
    }

    let locale = locale()
    set-bibliography(prefix, citations => hayagriva.read(
      path.map(path => (path: path, content: read(path))),
      full,
      style,
      locale,
      citations,
    ))
  }
}

/// Returns a previously loaded bibliography. This is used implicitly by @@bibliographyx() and
/// Alexandria citations to retrieve rendered data, and can be used directly for more complex use
/// cases. Usually, the returned data will be ultimately rendered using @@render-bibliography().
///
/// The result is a dictionary with the following keys:
/// - `prefix`: the string prefix used by Alexandria to identify this bibliography (and passed to
///   this function), used as a prefix for all labels rendered by Alexandria.
/// - `references`: an array of reference dictionaries which can be rendered into a bibliography.
///   The array is sorted by the appearance of references according to the style used.
/// - `citations`: an array of citations dictionaries which can be rendered into the various
///   citations in the document. The array is sorted by the appearance of citations in the document.
/// - `hanging-indent`: a boolean indicating whether the citation style uses a hanging indent for
///   its entries.
///
/// The `references` in turn each contain
/// - `key`: the reference key without prefix.
/// - `reference`: a representation of the Typst content that should be rendered; this is processed
///   by @@render-bibliography() to produce the actual context.
/// - optionally `prefix`: this is _not_ the Alexandria prefix but another Typst content
///   representation for styles that require it. For example, in IEEE style this would represent
///   "[1]" and so on.
/// - `details`: a dictionary containing several fields of structured data about the reference.
///   Among these are `type`, `title`, `author`, `date`, etc. A full list can be found in the
///   #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva docs].
///
/// The `citations` are representations of the Typst content that should be rendered at their
/// respective citation sites.
///
/// This function is contextual.
///
/// -> dict
#let get-bibliography(
  /// The prefix for which the bibliography should be retrieved.
  /// -> string
  prefix,
) = {
  import "state.typ": *

  get-bibliography(prefix)
}

/// Renders the provided bibliography data (as returned by @@get-bibliography();) with the given
/// title. For simple use cases, @@bibliographyx() can be used directly, which also handles the data
/// retrieval.
///
/// You will usually only need to call this directly if you _don't_ pass the exact return value of
/// @@get-bibliography() as an argument. Instead, you'll want to preprocess that data, e.g. by
/// filtering out some `references` entries that should appear elsewhere in the document. Note that
/// generally, you'll need to ultimately render all references, or you'll get unresolved citations.
///
/// -> content
#let render-bibliography(
  /// The bibliography data
  /// -> dict
  bib,
  /// The title of the bibliography. Note that `auto` is currently not supported.
  /// -> none | content | auto
  title: auto,
) = {
  assert.ne(title, auto, message: "automatic title is not yet supported")

  if title != none {
    [= #title]
  }

  set par(hanging-indent: 1.5em) if bib.hanging-indent

  if bib.references.any(e => e.prefix != none) {
    grid(
      columns: 2,
      // rows: (),
      column-gutter: 0.65em,
      // row-gutter: 13.2pt,
      row-gutter: par.spacing,
      // fill: none,
      // align: auto,
      // stroke: (:),
      // inset: (:),
      ..for e in bib.references {
        (
          {
            [#metadata(none)#label(bib.prefix + e.key)]
            if e.prefix != none {
              hayagriva.render(e.prefix)
            }
          },
          hayagriva.render(e.reference),
        )
      },
    )
  } else {
    let gutter = v(par.spacing, weak: true)
    for (i, e) in bib.references.enumerate() {
      if i != 0 { gutter }
      [#metadata(none)#label(bib.prefix + e.key)]
      hayagriva.render(e.reference)
    }
  }
}

/// Renders an additional bibliography. The interface is similar to the built-in
/// #link("https://typst.app/docs/reference/model/bibliography/")[`bibliography()`], but not all
/// features are supported (yet). In particular, the default values reflect `bibliography()`, but
/// some of these are not supported yet and need to be set manually.
///
/// ```typ
/// #bibliographyx(
///   "bibliography.bib",
///   title: "Bibliography",
///   full: true,
///   style: "ieee",
/// )
/// ```
///
/// This function is based on @@load-bibliography(), @@get-bibliography(), and
/// @@render-bibliography() and simply reproduces the rendering of the built-in bibliography without
/// modification.
///
/// -> content
#let bibliographyx(
  /// The path to the bibliography file.
  /// -> string | array
  path,
  /// The prefix for which reference labels should be provided and citations should be processed.
  /// -> string | auto
  prefix: auto,
  /// The title of the bibliography. Note that `auto` is currently not supported.
  /// -> none | content | auto
  title: auto,
  /// Whether to render the full bibliography or only the references that are used in the document.
  /// -> boolean
  full: false,
  /// The style of the bibliography.
  /// -> string
  style: "ieee",
) = {
  import "state.typ": *

  load-bibliography(path, prefix: prefix, full: full, style: style)

  context {
    let prefix = prefix
    if prefix == auto {
      prefix = get-only-prefix()
      assert.ne(prefix, none, message: "when using multiple custom bibliographies, you must specify the prefix for each")
    }

    let bib = get-bibliography(prefix)
    render-bibliography(bib, title: title)
  }
}
