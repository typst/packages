#let _wasm-bib = plugin("retrofit.wasm")
#let _bib-counter = counter("bib-counter")
#let _cited-pages(format, key) = context {
  let pages = query(ref.where(target: key)).map(r => r.location())
  let links = pages.dedup(key: p => p.page()).map(p => link(p, str(counter(page).at(p).first())))
  if pages.len() > 0 { format(links) }
}

/// Using `backrefs` in a show-rule enables backreferences for each entry.
///
/// It does this by looking for all instances of a citation, collecting the pages
/// it is on and correctly assigns them to each bibliography entry.
///
/// === Example
/// ```typ
/// #show: backrefs.with(
///   format: l => [Cited on page(s) #l.join(", ")],
///   read: path => read(path),
/// )
/// ```
/// -> content
#let backrefs(
  /// Specifies how the links to the pages should be styled.
  /// The function takes an array of `link` as input and expects some markup as output.
  ///
  /// -> function
  format: links => [*(#links.join(", "))*],
  /// Specifies a function to process the `path` and `style` parameters of `#bibliography`.
  /// Pass ```typc path => read(path)``` to read the contents of the bibliography.
  ///
  /// _(This is currently needed for correctly resolving relative paths!)_
  /// -> function
  read: none,
  doc,
) = {
  assert.eq(
    type(format),
    function,
    message: "Please specify a function to turn the backreferences into markup!",
  )

  show bibliography: bib => {
    let keys = query(ref.where(element: none)).dedup().map(r => str(r.target))
    let formats = bib.sources.map(s => {
      // @typstyle off
      if type(s) == bytes { "bytes" }
      else if s.ends-with(regex("ya?ml")) { "yml" }
      else { "bib" }
    })

    let sources = bib.sources.map(s => {
      if type(s) == str {
        read(s)
      } else {
        str(s)
      }
    })

    // Read in CSL content if necessary.
    let (style, style-format) = if bib.style.ends-with(".csl") {
      (read(bib.style), "csl")
    } else {
      (bib.style, "text")
    }

    let sorted-keys = str(_wasm-bib.sorted_bib_keys(
      bytes(sources.join("%%%")),
      bytes(formats.join(",")),
      bytes(if bib.full { "true" } else { "false" }),
      bytes(style),
      bytes(style-format),
      bytes(text.lang),
      bytes(keys.join(",")),
    )).split()

    // Grid-based styles, such as IEEE.
    show grid: it => {
      if not it.has("label") {
        // Modify every second child which represents the entry itself.
        let modified-children = it
          .children
          .enumerate()
          .map(((i, c)) => {
            if calc.odd(i) {
              _bib-counter.step()
              (
                c
                  + " "
                  + context {
                    let idx = _bib-counter.get().first() - 1
                    _cited-pages(format, label(sorted-keys.at(idx)))
                  }
              )
            } else {
              c
            }
          })

        let fields = it.fields()
        let _ = fields.remove("children")

        [#grid(..fields, ..modified-children)<grid>]
      } else {
        it
      }
    }

    // Provide bibliography heading body via metadata.
    show heading: it => [#it#metadata(it.body)<bib-heading>]
    // Non-grid based styles (blocks with v-spacing), such as APA.
    show block: it => {
      if it.body == auto { return it }
      if not it.has("label") {
        // If we detected the bibliography heading, skip styling.
        if query(<bib-heading>).first().value == it.body {
          return it
        }

        _bib-counter.step()
        let modified-body = (
          it.body
            + " "
            + context {
              let idx = _bib-counter.get().first() - 1
              _cited-pages(format, label(sorted-keys.at(idx)))
            }
        )

        let fields = it.fields()
        let _ = fields.remove("body")

        [#block(..fields, modified-body)<block>]
      } else {
        it
      }
    }

    bib
  }

  doc
}
