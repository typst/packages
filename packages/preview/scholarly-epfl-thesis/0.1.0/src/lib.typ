#let fill-line(left-text, right-text) = [#left-text #h(1fr) #right-text]

// The `in-outline` mechanism is for showing a short caption in the list of figures
// See https://sitandr.github.io/typst-examples-book/book/snippets/chapters/outlines.html#long-and-short-captions-for-the-outline
#let in-outline = state("in-outline", false)

#let flex-caption(long, short) = context { if in-outline.get() { short } else {
long } }

// ---

#let front-matter(body) = {
  set page(numbering: "i")
  counter(page).update(1)
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    it
    v(6%, weak: true)
  }
  body
}

#let main-matter(body) = {
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    it
    v(12%, weak: true)
  }
  body
}

#let back-matter(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  // Without this, the header says "Chapter F"
  counter(heading.where(level: 1)).update(0)
  // Without this, the table of contents line says "Chapter F"
  counter(heading).update(0)
  body
}

// ---

// This function gets your whole document as its `body` and formats it
#let template(
  // The title for your work.
  title: [Your Title],
  // Author's name.
  author: "Author",
  // The paper size to use.
  paper-size: "a4",
  // Date that will be displayed on cover page.
  // The value needs to be of the 'datetime' type.
  // More info: https://typst.app/docs/reference/foundations/datetime/
  // Example: datetime(year: 2024, month: 03, day: 17)
  date: none,
  // Format in which the date will be displayed on cover page.
  // More info: https://typst.app/docs/reference/foundations/datetime/#format
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  // The content of your work.
  body,
) = {
  // Set the document's metadata.
  set document(
    title: title, author: author, date: if date != none { date } else { auto },
  )

  // Set the body font.
  set text(font: ("Utopia LaTeX"), size: 11pt)

  // Configure page size and margins.
  set page(
    paper: paper-size, margin: (
      bottom: 5cm, top: 4cm,
      // The original LaTeX template references something called "hoffset", not sure what that is yet
      inside: 26.2mm, outside: 37mm,
    ), numbering: "1", number-align: right,
  )

  // Configure paragraph properties.
  // Default leading is 0.65em.
  set par(leading: 0.7em, justify: true, linebreaks: "optimized")
  // Default spacing is 1.2em.
  show par: set block(spacing: 1.35em)

  show heading: it => {
    v(2.5em, weak: true)
    it
    v(1.5em, weak: true)
  }

  // Style chapter headings.
  show heading.where(level: 1): it => {
    set text(size: 22pt)

    // Has no effect, still shows "Section"
    set heading(supplement: [Chapter])

    let black_rectangle = place(
      dx: -page.margin.outside, dy: -1em, rect(fill: black, width: page.margin.outside - 5pt, height: 2em),
    )

    let heading_number = if heading.numbering == none { [] } else { counter(heading.where(level: 1)).display() }
    let white_heading_number = place(dx: -1em, text(fill: white, heading_number))

    // Start chapters on even pages
    // FIXME: `pagebreak(to: "even")` replicates the behaviour seen in the
    // original template, except for an important detail: the resulting empty
    // pages still show the header and page number. This is not great and is the
    // subject of https://github.com/typst/typst/issues/2722.
    // pagebreak(to: "even")
    pagebreak()

    v(16%)
    rect(
      stroke: none, inset: 0em, black_rectangle + white_heading_number + it.body,
    )
  }

  // Configure heading numbering.
  set heading(numbering: "1.1")

  // Do not hyphenate headings.
  show heading: set text(hyphenate: false)

  // Set page header
  set page(
    header-ascent: 30%, header: context{
      // Get current page number.
      let page-number = here().page()

      // [ #repr(query(<disable_header>).map(el => el.location().page()).slice(0, 5)) ]
      // If the current page is the start of a chapter, don't show a header
      let target = heading.where(level: 1)
      if query(target).any(it => it.location().page() == page-number) {
        // return [New chapter! page #here().page(), #i]
        return []
      }

      // Find the chapter of the section we are currently in.
      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()

        let chapter-title = current.body
        let chapter-number = counter(heading.where(level: 1)).display()
        // let chapter-number-text = [#current.supplement Chapter #chapter-number]
        let chapter-number-text = [Chapter #chapter-number]

        if current.numbering != none {
          let (left-text, right-text) = if calc.odd(page-number) {
            (chapter-number-text, chapter-title)
          } else {
            (chapter-title, chapter-number-text)
          }
          text(weight: "bold", fill-line(left-text, right-text))
          v(-1em)
          line(length: 100%, stroke: 0.5pt)
        }
      }
    },
  )

  // The `in-outline` is for showing a short caption in the list of figures
  // See https://sitandr.github.io/typst-examples-book/book/snippets/chapters/outlines.html#long-and-short-captions-for-the-outline
  show outline: it => {
    in-outline.update(true)
    // Show table of contents, list of figures, list of tables, etc. in the table of contents
    set heading(outlined: true)
    it
    in-outline.update(false)
  }

  // Indent nested entries in the outline.
  set outline(indent: auto, fill: repeat([#h(2.5pt) . #h(2.5pt)]))

  show outline.entry: it => {
    // Only apply styling if we're in the table of contents (not list of figures or list of tables, etc.)
    if it.element.func() == heading {
      if it.level == 1 {
        v(1.5em, weak: true)
        strong(it)
      } else {
        it
      }
    } else {
      it
    }
  }

  // Configure equation numbering.
  set math.equation(numbering: n => {
    let h1 = counter(heading).get().first()
    numbering("(1.1)", h1, n)
  })

  show math.equation: it => {
    set align(left)
    // Indent
    pad(left: 2em, it)
  }

  // FIXME: Has no effect?
  set place(clearance: 2em)

  set figure(numbering: n => {
    let h1 = counter(heading).get().first()
    numbering("1.1", h1, n)
  }, gap: 1.5em)
  set figure.caption(separator: [ -- ])

  show figure.caption: it =>{
    if it.kind == table {
      align(center, it)
    } else {
      align(left, it)
    }
  }
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    // Break large tables across pages.
    set block(breakable: true)
    it
  }
  set table(stroke: none)

  // Set raw text font.
  show raw: set text(font: ("Iosevka", "Fira Mono"), size: 9pt)

  // Display inline code in a small box that retains the correct baseline.
  // show raw.where(block: false): box.with(
  //   fill: luma(250).darken(2%), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt,
  // )

  // Display block code with padding.
  show raw.where(block: true): block.with(inset: (x: 5pt))

  // Show a small maroon circle next to external links.
  show link: it => {
    // Workaround for ctheorems package so that its labels keep the default link styling.
    if type(it.dest) == label { return it }
    it
    h(1.6pt)
    super(
      box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333"))),
    )
  }

  body
}
