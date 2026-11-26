#let __retrofit = plugin("retrofit.wasm")
#let __bib-counter = counter("bib-counter")
#let __cited-pages(format, key) = context {
  let pages = query(<__cite>).filter(m => m.value == key).map(r => r.location())
  let links = pages.dedup(key: p => p.page()).map(p => link(p, str(counter(page).at(p).first())))
  if pages.len() > 0 { format(links) }
}

/// Using `backrefs` in a show-rule enables backreferences for each entry.
///
/// It does this by looking for all instances of a citation, collecting the pages
/// it is on and correctly assigns them to each bibliography entry. In order to read
/// the entries, a custom `read`-closure must be provided when using relative path strings.
///
/// If the entries are provided using the `path` type, or via `bytes`, this parameter
/// may be omitted entirely. This also applies to the citation style.
///
///
/// === Example
/// ```typ
/// #show: backrefs.with(
///   format: p => [Cited on page(s) #p.join(", ")],
///   read: path => read(path),
/// )
/// ```
///
/// - format (function): The formatting function for page links. Expects an array of `link` as input and `content` as output.
/// - read (function): The read closure for resolving relative paths of path strings.
///
/// -> content
#let backrefs(
  format: links => [*(#links.join(", "))*],
  read: none,
  doc,
) = {
  assert.eq(
    type(format),
    function,
    message: "found " + str(type(format)) + ", expected formatting function (array => content)",
  )

  show cite: it => [#metadata(it.key)<__cite>] + it
  show bibliography: bib => {
    let keys = query(<__cite>).map(m => str(m.value)).dedup()
    if keys.len() == 0 {
      return bib
    }
    
    // Convert sources to stringified variant for all possible types.
    let sources = bib.sources.map(s => {
      if type(s) == str {
        read(s)
      } else if type(s) == path {
        std.read(s)
      } else {
        str(s)
      }
    })

    // Read in CSL content if necessary.
    let (style, style-format) = if type(bib.style) == str {
      if bib.style.ends-with(".csl") {
        (read(bib.style), "csl")
      } else {
        (bib.style, "text")
      }
    } else if type(bib.style) == path {
      (std.read(bib.style), "csl")
    } else {
      (bib.style, "text")
    }

    let sorted-keys = str(__retrofit.sorted_bib_keys(
      bytes(sources.join("%%%")),
      bytes(if bib.full { "true" } else { "false" }),
      bytes(style),
      bytes(style-format),
      bytes(text.lang),
      bytes(keys.join(",")),
    )).split()

    // --- GRID-BASED --- //

    // Grid-based styles, such as IEEE.
    show grid.cell.where(x: 1): it => {
      __bib-counter.step()

      let citations = context {
        let idx = __bib-counter.get().first() - 1
        __cited-pages(format, label(sorted-keys.at(idx)))
      }

      it + " " + citations
    }

    // --- BLOCK-BASED --- //

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

        __bib-counter.step()
        let modified-body = (
          it.body
            + " "
            + context {
              let idx = __bib-counter.get().first() - 1
              __cited-pages(format, label(sorted-keys.at(idx)))
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
