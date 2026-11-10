#import "hayagriva.typ"

#let citation(prefix, key, form: "normal", style: auto, supplement: auto) = {
  import "state.typ": *
  import "internal.typ": *

  assert(str(key).starts-with(prefix), message: "Can only refer to an entry with the given prefix.")

  let (index, group) = get-citation-info(prefix)
  add-citation(prefix, (
    key: str(key).slice(prefix.len()),
    form: form,
    ..if style != auto { (style: csl-to-string(style)) },
    supplement: supplement,
    locale: locale(),
  ))
  if not group {
    context {
      let (body, supplements) = get-citation(prefix, index)
      let (footnote, content) = body
      let citation = hayagriva.render(
        content,
        keys: (key,),
        ..supplements,
      )
      if footnote and form != none {
        citation = std.footnote(citation)
      }
      citation
    }
  }
}

/// This configuration function should be called as a _show rule_ at the beginning of the document.
/// It enables Alexandria's customized processing of the `ref()` and `cite()` commands.
///
/// ```typ
/// #show: alexandria(prefix: "x:", read: path => read(path))
/// ```
/// -> function
#let alexandria(
  /// a prefix that identifies citations from a specific Alexandria's bibliography.
  /// -> string
  prefix: none,
  /// the function to process the `path` and `style` parameters of @@bibliographyx() and
  /// @@load-bibliography() commands.
  /// Pass ```typc path => read(path)``` to read the contents of the bibliography and style files.
  /// -> function
  read: none,
) = body => {
  let read-value = read
  import "state.typ": *

  assert.ne(prefix, none, message: "usage without a prefix is not yet supported")
  // assert.ne(read-value, none, message: "read is required; provide a function `path => read(path)`")

  let match(key) = prefix == none or str(key).starts-with(prefix)

  set-read(read-value)
  register-prefix(prefix)

  show ref: it => {
    if not match(it.target) {
      return it
    }

    citation(
      prefix, it.target,
      form: cite.form, style: cite.style,
      supplement: if it.supplement != auto { it.supplement },
    )
  }

  show cite: it => {
    if not match(it.key) {
      return it
    }

    context citation(
      prefix, it.key,
      form: it.form, style: it.style,
      supplement: it.supplement,
    )
  }

  body
}

/// Creates a group of collapsed citations. The citations are given as regular content, e.g.
/// ```typ
/// #citegroup[@x:a @x:b]
/// ```
/// Only citations, references and spaces may appear in the body.
/// Mixing non-Alexandria references or references from different prefixes
/// in the same citation group is *not supported*.
///
/// -> content
#let citegroup(
  /// the optional prefix for the citations within a group.
  /// It only needs to be specified if more than one prefix was registered.
  /// -> string | auto
  prefix: auto,
  /// the body, containing one or more citations.
  /// -> content
  body,
) = {
  import "state.typ": *

  assert(
    type(body) == content and body.func() in ([].func(), ref, cite),
    message: "citegroup expected one or more citations in the form of content",
  )
  let children = if body.func() == [].func() {
    body.children
  } else {
    (body,)
  }.filter(x => x.func() != [ ].func())
  assert(
    children.all(x => x.func() in (ref, cite)),
    message: "citegroup expected a body consisting only of citations and references",
  )

  start-citation-group()
  // don't use the body since that may contain whitespace
  // the citations themselves won't render as anything, so they're fine
  children.join()
  context {
    let prefix = prefix
    if prefix == auto {
      prefix = get-only-prefix()
      assert.ne(prefix, none, message: "when using multiple custom bibliographies, you must specify the prefix for each")
    }

    let (index, ..) = get-citation-info(prefix)
    let (body, supplements) = get-citation(prefix, index)
    let (footnote, content) = body
    let citation = hayagriva.render(
      content,
      keys: children.map(x => {
        if x.func() == ref { x.target }
        else if x.func() == cite { x.key }
      }),
      ..supplements,
    )
    if footnote and children.any(x => x.at("form", default: "normal") != none) {
      citation = std.footnote(citation)
    }
    citation
  }
  end-citation-group()
}

/// Loads the bibliography for a given prefix.
/// The function reads the bibliography from the given file(s), which is used later by
/// @@get-bibliography(). It does not render any content.
/// For simple cases, @@bibliographyx() can be used directly.
///
/// Even though this function only loads the bibliography, it requires knowledge of the
/// citations that appear in the document, both to know which references to include (for non-`full`
/// bibliographies) and in what styles, forms and languages these citations should be rendered.
///
/// The interface is similar to the built-in
/// #link("https://typst.app/docs/reference/model/bibliography/")[`bibliography()`], but not all
/// features are supported (yet). In particular, the default values reflect `bibliography()`, but
/// some of these are not supported yet and need to be set manually.
/// Some parameters, like `title`, have to be specified when calling @@render-bibliography(), which
/// actually renders the bibliography.
///
/// -> content
#let load-bibliography(
  /// the path(s) to the bibliography file(s), which is passed to the `read` function
  /// registered via @@alexandria(), or its binary contents if no `read` function provided.
  /// -> string | bytes | array
  path,
  /// the optional prefix for which the bibliography is loaded.
  /// It only needs to be specified if more than one prefix was registered.
  /// -> string | auto
  prefix: auto,
  /// whether the bibliography for the given prefix should include all bibliographical entries
  /// from `path` or only the ones cited in the document.
  /// -> boolean
  full: false,
  /// the style of the bibliography. Either a #link("https://typst.app/docs/reference/model/bibliography/#parameters-style")[built-in style],
  /// a path to a CSL file passed to `read()` registered via @@alexandria(), or its binary
  /// contents.
  /// -> string | bytes
  style: "ieee",
) = {
  import "state.typ": *
  import "internal.typ": *

  let path = path
  if type(path) != array {
    path = (path,)
  }

  context {
    let prefix = prefix
    if prefix == auto {
      prefix = get-only-prefix()
      assert.ne(prefix, none, message: "when using multiple custom bibliographies, you must specify the prefix for each")
    }

    let sources = path.map(path => read(path))

    let style = csl-to-string(style)
    if style in hayagriva.names {
      style = (built-in: style)
    } else {
      style = (custom: read(style).data)
    }

    let locale = locale()
    set-bibliography(prefix, citations => hayagriva.read(
      sources,
      full,
      style,
      locale,
      citations.map(group => group.map(((supplement, ..citation)) => {
        let supplement = if supplement != none { repr(supplement) }
        (..citation, supplement: supplement)
      })),
    ))
  }
}

/// Collects all references that have to be rendered.
/// This function is called by @@bibliographyx() and when rendering Alexandria citations.
/// It can also be directly called by the user for more complex use cases.
/// Before calling this function, you must call @@load-bibliography() to load the bibliography data.
/// To actually render the bibliographical list, the result of @@get-bibliography() has to be passed to
/// @@render-bibliography().
///
/// The result is a dictionary with the following keys:
/// - `prefix`: the unique string prefix that identifies this Alexandria bibliography.
/// - `references`: an array of reference dictionaries which can be rendered into a bibliography.
///   The array is sorted by the appearance of references according to the style used.
/// - `citations`: an array of citations dictionaries which can be rendered into the various
///   citations in the document. The array is sorted by the appearance of citations in the document.
/// - `hanging-indent`: a boolean indicating whether the citation style uses a hanging indent for
///   its entries.
///
/// The elements of the `references` array have the following fields:
/// - `key`: the original bibliography key (without Alexandria's prefix).
/// - `content`: a Typst representation of the bibliographical entry; used by
///   @@render-bibliography() for rendering bibliographical items.
/// - optional `first-field`: Typst content for certain bibliography styles. For example,
///   in IEEE style it represents "[1]", "[2]", etc.
/// - `details`: a dictionary containing information about this reference, including
///   `type`, `title`, `author`, and `date` fields. The full list can be found in the
///   #link("https://github.com/typst/hayagriva/blob/main/docs/file-format.md")[Hayagriva docs].
///
/// The `citations` are representations of the Typst content that should be rendered at their
/// respective citation sites.
///
/// This function is contextual.
///
/// -> dict
#let get-bibliography(
  /// the optional prefix for which the bibliography should be retrieved.
  /// It only needs to be specified if more than one prefix was registered.
  /// -> string | auto
  prefix,
) = {
  import "state.typ": *

  if prefix == auto {
    prefix = get-only-prefix()
    assert.ne(prefix, none, message: "when using multiple custom bibliographies, you must specify the prefix for each")
  }
  get-bibliography(prefix)
}

/// Renders the given list of bibliographical references.
/// For simple use cases, @@bibliographyx() can be called directly.
///
/// You will only need to call this function directly if you want to postprocess the results of
/// @@get-bibliography(), e.g. by filtering out the `references` entries that should appear in
/// another bibliography elsewhere in the document.
/// Note that, to avoid unresolved citations, all references generated by @@get-bibliography()
/// have to appear in some @@render-bibliography() call.
///
/// -> content
#let render-bibliography(
  /// the bibliography data prepared by the @@get-bibliography() call.
  /// -> dict
  bib,
  /// the title of the bibliography. Note that `auto` is currently not supported.
  /// -> none | content | auto
  title: auto,
) = {
  assert.ne(title, auto, message: "automatic title is not yet supported")

  if title != none {
    [= #title]
  }

  set par(hanging-indent: 1.5em) if bib.hanging-indent

  if bib.references.any(e => e.first-field != none) {
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
            if e.first-field != none {
              hayagriva.render(e.first-field)
            }
          },
          hayagriva.render(e.content),
        )
      },
    )
  } else {
    let gutter = v(par.spacing, weak: true)
    for (i, e) in bib.references.enumerate() {
      if i != 0 { gutter }
      [#metadata(none)#label(bib.prefix + e.key)]
      hayagriva.render(e.content)
    }
  }
}

/// Renders the bibliography for a given prefix. The interface is similar to the built-in
/// #link("https://typst.app/docs/reference/model/bibliography/")[`bibliography()`], but not all
/// features are supported (yet). In particular, the default values reflect `bibliography()`, but
/// some of these are not supported yet and need to be set manually.
///
/// ```typ
/// #bibliographyx(
///   "bibliography.bib",
///   prefix: "x:",
///   title: "Bibliography",
///   full: true,
///   style: "ieee",
/// )
/// ```
///
/// This convenience function calls @@load-bibliography(), @@get-bibliography(), and
/// @@render-bibliography() to reproduce the behavior of the built-in ```typc bibliography()```
/// call.
///
/// -> content
#let bibliographyx(
  /// the path(s) to the bibliography file(s), which is passed to the `read` function
  /// registered via @@alexandria(), or its binary contents if no `read` function provided.
  /// -> string | bytes | array
  path,
  /// the optional prefix for which the bibliography is generated.
  /// It only needs to be specified if more than one prefix was registered.
  /// -> string | auto
  prefix: auto,
  /// the title of the bibliography. Note that `auto` is currently not supported.
  /// -> none | content | auto
  title: auto,
  /// whether to render all bibliographical entries from `path` or only the ones
  /// cited in the document.
  /// -> boolean
  full: false,
  /// the style of the bibliography. Either a #link("https://typst.app/docs/reference/model/bibliography/#parameters-style")[built-in style],
  /// a path to a CSL file passed to `read` registered via @@alexandria(), or its binary
  /// contents.
  /// -> string | bytes
  style: "ieee",
) = {
  load-bibliography(path, prefix: prefix, full: full, style: style)

  context {
    let bib = get-bibliography(prefix)
    render-bibliography(bib, title: title)
  }
}
