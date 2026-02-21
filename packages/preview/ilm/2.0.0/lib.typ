// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography
#let std-smallcaps = smallcaps
#let std-upper = upper

// Overwrite the default `smallcaps` and `upper` functions with increased spacing between
// characters. Default tracking is 0pt.
#let smallcaps(body) = std-smallcaps(text(tracking: 0.6pt, body))
#let upper(body) = std-upper(text(tracking: 0.6pt, body))

// Colors used across the template.
#let stroke-color = luma(200)
#let fill-color = luma(250)

// This function gets your whole document as its `body`.
#let ilm(
  // The title for your work.
  title: [Your Title],
  // Author's name.
  // TODO: Deprecated. Use `authors` instead. Will be removed in a future version.
  author: "Author",
  // Author(s) of your work. Can be a string or an array of strings.
  // If an array is provided, authors will be displayed on separate lines on the cover page.
  authors: none,
  // Cover page customization.
  // Set to "use-ilm-default" to use Ilm's default cover page,
  // set to `none` to skip the cover page entirely,
  // or provide custom content to create your own cover page.
  cover-page: "use-ilm-default",
  // The paper size to use.
  paper-size: "a4",
  // Date that will be displayed on cover page.
  // The value needs to be of the 'datetime' type.
  // More info: https://typst.app/docs/reference/foundations/datetime/
  // Example: datetime(year: 2024, month: 03, day: 17)
  date: none,
  // Format in which the date will be displayed on cover page.
  // More info: https://typst.app/docs/reference/foundations/datetime/#format
  // The default format will display date as: MMMM DD, YYYY
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  // An abstract for your work. Can be omitted if you don't have one.
  abstract: none,
  // The contents for the preface page. This will be displayed after the cover page. Can
  // be omitted if you don't have one.
  preface: none,
  // The result of a call to the `outline` function or `none`.
  // Set this to `none`, if you want to disable the table of contents.
  // More info: https://typst.app/docs/reference/model/outline/
  table-of-contents: outline(),
  // Display an appendix after the body but before the bibliography.
  appendix: (
    enabled: false,
    title: "",
    heading-numbering-format: "",
    body: none,
  ),
  // The result of a call to the `bibliography` function or `none`.
  // Example: bibliography("refs.bib")
  // More info: https://typst.app/docs/reference/model/bibliography/
  bibliography: none,
  // Whether to start a chapter on a new page.
  chapter-pagebreak: true,
  // Whether to display a maroon circle next to external links.
  external-link-circle: true,
  // Footer style for page numbering.
  // Set to `none` to disable footer entirely.
  // Available styles:
  // - "page-number-alternate-with-chapter": alternating sides with chapter name (default)
  // - "page-number-left-with-chapter": left-aligned with chapter name
  // - "page-number-right-with-chapter": right-aligned with chapter name
  // - "page-number-center": centered page number only
  // - "page-number-left": left-aligned page number only
  // - "page-number-right": right-aligned page number only
  footer: "page-number-alternate-with-chapter",
  // Raw text customization.
  // Set to "use-typst-default" to use Typst's default raw text styling,
  // or provide a dictionary to customize font and size.
  raw-text: (
    font: ("Iosevka", "Fira Mono"),
    size: 9pt,
  ),
  // Display an index of figures (images).
  figure-index: (
    enabled: false,
    title: "",
  ),
  // Display an index of tables
  table-index: (
    enabled: false,
    title: "",
  ),
  // Display an index of listings (code blocks).
  listing-index: (
    enabled: false,
    title: "",
  ),
  // The content of your work.
  body,
) = {
  // Determine the final authors to use (new `authors` parameter takes precedence over
  // deprecated `author`). Normalize to array for simpler processing.
  let final-authors = if authors != none {
    if type(authors) == str {
      (authors,)
    } else {
      authors
    }
  } else {
    (author,)
  }

  // Set the document's metadata.
  set document(title: title, author: final-authors.join(", "))

  // Set the body font.
  set text(size: 12pt) // default is 11pt

  // Customize raw text formatting.
  show raw: it => {
    // TODO: Remove backwards compatibility for `use-typst-defaults` in future version
    let use-defaults = (
      (type(raw-text) == str and raw-text == "use-typst-default") or
      (type(raw-text) == dictionary and raw-text.at("use-typst-defaults", default: false))
    )

    if use-defaults {
      it
    } else if type(raw-text) == dictionary {
      set text(
        // Reference: Typst's default is Fira Mono at 8.8pt
        // TODO: Remove backwards compatibility for `custom-font` and `custom-size` in future version
        font: raw-text.at("font", default: raw-text.at("custom-font", default: ("Iosevka", "Fira Mono"))),
        size: raw-text.at("size", default: raw-text.at("custom-size", default: 9pt)),
      )
      it
    } else {
      it
    }
  }

  // Configure page size and margins.
  set page(
    paper: paper-size,
    margin: (bottom: 1.75cm, top: 2.25cm),
  )

  // Cover page.
  if cover-page == none {
    // Skip cover page
  } else if type(cover-page) == content {
    // Custom cover page content
    page(cover-page)
  } else if type(cover-page) == str and cover-page == "use-ilm-default" {
    // Default Ilm cover page
    page(
      align(
        left + horizon,
        block(width: 90%)[
          #let v-space = v(2em, weak: true)
          #text(3em)[*#title*]

          #v-space
          // Display author(s)
          #let author-count = final-authors.len()
          #let author-size = if author-count == 1 {
            1.6em
          } else if author-count == 2 {
            1.4em
          } else if author-count == 3 {
            1.2em
          } else {
            1.1em
          }

          #for (i, auth) in final-authors.enumerate() {
            text(author-size, auth)
            if i < author-count - 1 {
              linebreak()
            }
          }

          #if abstract != none {
            v-space
            block(width: 80%)[
              // Default leading is 0.65em.
              #par(leading: 0.78em, justify: true, linebreaks: "optimized", abstract)
            ]
          }

          #if date != none {
            v-space
            text(date.display(date-format))
          }
        ],
      ),
    )
  }

  // Configure paragraph properties.
  // Default leading is 0.65em.
  // Default spacing is 1.2em.
  set par(leading: 0.7em, spacing: 1.35em, justify: true, linebreaks: "optimized")

  // Add vertical space after headings.
  show heading: it => {
    it
    v(2%, weak: true)
  }
  // Do not hyphenate headings.
  show heading: set text(hyphenate: false)

  // Show a small maroon circle next to external links.
  show link: it => {
    it
    // Workaround for ctheorems package so that its labels keep the default link styling.
    if external-link-circle and type(it.dest) != label {
      sym.wj
      h(1.6pt)
      sym.wj
      super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333"))))
    }
  }

  // Display preface as the second page.
  if preface != none {
    page(preface)
  }

  // Display table of contents.
  if table-of-contents != none {
    table-of-contents
  }

  // Configure page numbering and footer.
  set page(
    footer: if footer != none {
      context {
        // Get current page number.
        let i = counter(page).at(here()).first()
        
        // Only get chapter info if needed
        let chapter = none
        let on-chapter-page = false
        
        if footer.ends-with("with-chapter") {
          // Are we on a page that starts a chapter?
          let target = heading.where(level: 1)
          on-chapter-page = query(target).any(it => it.location().page() == i)
          
          // Find the chapter of the section we are currently in.
          if not on-chapter-page {
            let before = query(target.before(here()))
            if before.len() > 0 {
              let current = before.last()
              if current.numbering != none {
                chapter = upper(text(size: 0.68em, current.body))
              }
            }
          }
        }
        
        let gap = 1.75em
        
        // Apply footer style
        if footer == "page-number-alternate-with-chapter" {
          let is-odd = calc.odd(i)
          let aln = if is-odd { right } else { left }
          
          if chapter != none {
            if is-odd {
              align(aln)[#chapter #h(gap) #i]
            } else {
              align(aln)[#i #h(gap) #chapter]
            }
          } else {
            align(aln)[#i]
          }
        } else if footer == "page-number-left-with-chapter" {
          if chapter != none {
            align(left)[#i #h(gap) #chapter]
          } else {
            align(left)[#i]
          }
        } else if footer == "page-number-right-with-chapter" {
          if chapter != none {
            align(right)[#chapter #h(gap) #i]
          } else {
            align(right)[#i]
          }
        } else if footer == "page-number-center" {
          align(center)[#i]
        } else if footer == "page-number-left" {
          align(left)[#i]
        } else if footer == "page-number-right" {
          align(right)[#i]
        } else {
          // Fallback to default behavior
          let is-odd = calc.odd(i)
          let aln = if is-odd { right } else { left }
          align(aln)[#i]
        }
      }
    },
  )

  // Configure equation numbering.
  set math.equation(numbering: "(1)")

  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: fill-color.darken(2%),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Display block code with padding.
  show raw.where(block: true): block.with(inset: (x: 5pt))

  // Break large tables across pages.
  show figure.where(kind: table): set block(breakable: true)
  set table(
    // Increase the table cell's padding
    inset: 7pt, // default is 5pt
    stroke: (0.5pt + stroke-color),
  )
  // Use smallcaps for table header row.
  show table.cell.where(y: 0): smallcaps

  // Wrap `body` in curly braces so that it has its own context. This way show/set rules
  // will only apply to body.
  {
    // Configure heading numbering.
    set heading(numbering: "1.")

    // Start chapters on a new page.
    show heading.where(level: 1): it => {
      if chapter-pagebreak {
        pagebreak(weak: true)
      }
      it
    }
    body
  }

  // Display appendix before the bibliography.
  if appendix.enabled {
    pagebreak()
    heading(level: 1)[#appendix.at("title", default: "Appendix")]

    // For heading prefixes in the appendix, the standard convention is A.1.1.
    let num-fmt = appendix.at("heading-numbering-format", default: "A.1.1.")

    counter(heading).update(0)
    set heading(
      outlined: false,
      numbering: (..nums) => {
        let vals = nums.pos()
        if vals.len() > 0 {
          let v = vals.slice(0)
          return numbering(num-fmt, ..v)
        }
      },
    )

    appendix.body
  }

  // Display bibliography.
  if bibliography != none {
    pagebreak()
    show std-bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bibliography
  }

  // Display indices of figures, tables, and listings.
  let fig-t(kind) = figure.where(kind: kind)
  let has-fig(kind) = counter(fig-t(kind)).get().at(0) > 0
  if figure-index.enabled or table-index.enabled or listing-index.enabled {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index.enabled and has-fig(image)
      let tbls = table-index.enabled and has-fig(table)
      let lsts = listing-index.enabled and has-fig(raw)
      if imgs or tbls or lsts {
        // Note that we pagebreak only once instead of each each individual index. This is
        // because for documents that only have a couple of figures, starting each index
        // on new page would result in superfluous whitespace.
        pagebreak()
      }

      if imgs {
        outline(
          title: figure-index.at("title", default: "Index of Figures"),
          target: fig-t(image),
        )
      }
      if tbls {
        outline(
          title: table-index.at("title", default: "Index of Tables"),
          target: fig-t(table),
        )
      }
      if lsts {
        outline(
          title: listing-index.at("title", default: "Index of Listings"),
          target: fig-t(raw),
        )
      }
    }
  }
}

// This function formats its `body` (content) into a blockquote.
#let blockquote(body) = {
  block(
    width: 100%,
    fill: fill-color,
    inset: 2em,
    stroke: (y: 0.5pt + stroke-color),
    body,
  )
}
