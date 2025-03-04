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

/// This configuration function should be called as a function at the beginning of the document.
/// The function makes sure that `ref()` and `cite()` commands can refer to Alexandria's custom
/// bibliography entries and stores configuration for use by @@bibliographyx().
///
/// ```typ
/// #show: alexandria(prefix: "x-", read: path => read(path))
/// ```
///
/// - prefix (string): a prefix that identifies labels referring to Alexandria bibliographies.
///   Bibliography entries will automatically get that prefix prepended.
/// - read (function): pass ```typc path => read(path)``` into this parameter so that Alexandria can
///   read your bibliography files.
///
/// -> function
#let alexandria(
  prefix: none,
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
/// - path (string, array): The path to the bibliography file.
/// - prefix (string, auto): The prefix for which reference labels should be provided and citations
///   should be processed.
/// - title (none, content, auto): The title of the bibliography. Note that `auto` is currently not
///   supported.
/// - full (boolean): Whether to render the full bibliography or only the references that are used
///   in the document. Note that `true` is currently not supported.
/// - style (string): The style of the bibliography.
///
/// -> content
#let bibliographyx(
  path,
  prefix: auto,
  title: auto,
  full: false,
  style: "ieee",
) = {
  import "state.typ": *
  import "internal.typ": *

  assert.ne(title, auto, message: "automatic title is not yet supported")

  let path = path
  if type(path) != array {
    path = (path,)
  }

  if title != none {
    [= #title]
  }

  context {
    let read = get-read()
    assert.ne(read, none, message: "Alexandria is not configured. Make sure to use `#show: alexandria(...)`")

    let prefix = prefix
    if prefix == auto {
      prefix = get-only-prefix()
      assert.ne(prefix, none, message: "when using multiple custom bibliographies, you must specify the prefix for each")
    }

    let locale = locale()
    set-bibliography(prefix, citations => {
      hayagriva.read(
        path.map(path => (path: path, content: read(path))),
        full,
        csl-to-string(style),
        locale,
        citations,
      )
    })

    context {
      let (references, hanging-indent) = get-bibliography(prefix)

      set par(hanging-indent: 1.5em) if hanging-indent

      if references.any(e => e.prefix != none) {
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
          ..for e in references {
            (
              {
                [#metadata(none)#label(prefix + e.key)]
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
        for (i, e) in references.enumerate() {
          if i != 0 { gutter }
          [#metadata(none)#label(prefix + e.key)]
          hayagriva.render(e.reference)
        }
      }
    }
  }
}
