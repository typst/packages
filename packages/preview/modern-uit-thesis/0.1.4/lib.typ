// Modern UiT Thesis Template
//
// This is a modern thesis template for UiT The Arctic University of Norway.
// Requires parameters set in the `thesis.typ` file.
//

#import "@preview/subpar:0.2.1"
#import "@preview/physica:0.9.5": *
#import "@preview/glossarium:0.5.4": make-glossary, register-glossary
#import "@preview/codly:1.2.0": *
#import "@preview/ctheorems:1.1.3": *

#import "modules/frontpage.typ": frontpage
#import "modules/backpage.typ": backpage
#import "modules/supervisors.typ": supervisors-page
#import "modules/epigraph.typ": epigraph-page
#import "modules/abstract.typ": abstract-page
#import "modules/acknowledgements.typ": acknowledgements-page
#import "modules/abbreviations.typ": abbreviations-page

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography
#let std-smallcaps = smallcaps
#let std-upper = upper
#let std-pagebreak = pagebreak

// Overwrite the default `smallcaps` and `upper` functions with increased spacing between
// characters. Default tracking is 0pt.
#let smallcaps(body) = std-smallcaps(text(tracking: 0.6pt, body))
#let upper(body) = std-upper(text(tracking: 0.6pt, body))

// Colors used across the template.
#let stroke-color = luma(200)
#let fill-color = luma(250)
#let uit-teal-color = rgb("#0095b6")
#let uit-light-teal-color = rgb("#e6f7fc")
#let uit-gray-color = rgb("#48545e")

// Helper to display two pieces of content with space between.
#let fill-line(left-text, right-text) = [#left-text #h(1fr) #right-text]

// Definition and Theorems
#let theorem = thmbox("theorem", "Theorem", fill: uit-light-teal-color)
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong,
)
#let definition = thmbox(
  "definition",
  "Definition",
  inset: (x: 1.2em, top: 1em),
)
#let lemma = thmbox("lemma", "Lemma", fill: uit-gray-color.lighten(80%))
#let example = thmplain("example", "Example").with(numbering: none)
// Disable numbering of equations inside a proof block
#let custom-proof-bodyfmt(body) = {
  set math.equation(numbering: none)
  proof-bodyfmt(body)
}
#let proof = thmproof("proof", "Proof", bodyfmt: custom-proof-bodyfmt).with(
  numbering: none,
)

// Helper to display external codeblocks.
// Based on https://github.com/typst/typst/issues/1494
#let code-block(filename, content) = raw(
  content,
  block: true,
  lang: filename.split(".").at(-1),
)

// Helper to display CSV tables.
#let csv-table(
  tabledata: "",
  columns: 1,
  header-row: rgb(255, 231, 230),
  even-row: rgb(255, 255, 255),
  odd-row: rgb(228, 234, 250),
) = {
  let tableheadings = tabledata.first()
  let data = tabledata.slice(1).flatten()
  table(
    columns: columns, fill: (_, row) => if row == 0 {
      header-row // color for header row
    } else if calc.odd(row) {
      odd-row // each other row colored
    } else {
      even-row
    }, align: (col, row) => if row == 0 { center } else {
      left
    }, ..tableheadings.map(x => [*#x*]), // bold headings
    ..data,
  )
}

// `in-appendix` is for custom styling in the appendix section
#let in-appendix = state("in-appendix", false)

// The `in-outline` mechanism is for showing a short caption in the list of figures
// See https://sitandr.github.io/typst-examples-book/book/snippets/chapters/outlines.html#long-and-short-captions-for-the-outline
#let in-outline = state("in-outline", false)

// -- Styling rules for Front-Main-Back matter --

// Common styles for front matter
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

// Common styles for main matter
#let main-matter(body) = {
  set text(features: ("onum",))
  set page(
    numbering: "1",
    // Only show numbering in footer when no chapter header is present
    footer: context {
      let chapters = heading.where(level: 1)
      if query(chapters).any(it => it.location().page() == here().page()) {
        align(center, counter(page).display())
      } else {
        none
      }
    },
  )
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    it
    v(12%, weak: true)
  }
  body
}

// Common styles for back matter
#let back-matter(body) = {
  set heading(numbering: "A.1.1", supplement: [Appendix])
  // Make sure headings start with 'A'
  counter(heading.where(level: 1)).update(0)
  counter(heading).update(0)
  body
}

// -- Template entrypoint --

// This function gets your whole document as its `body` and formats it
#let thesis(
  // The title for your work.
  title: [Your Title],
  // Subtitle for your work.
  subtitle: none,
  // Author.
  author: "Author",
  // The supervisor(s) for your work. Takes an array of "Title", "Name", [Affiliation]
  supervisors: (
    (
      title: "Your Supervisor",
      name: "Supervisor Name",
      affiliation: [UiT The Arctic University of Norway, \
        Faculty of Science and Technology, \
        Department of Computer Science],
    )
  ),
  // The paper size to use.
  paper-size: "a4",
  // The degree you are working towards
  degree: "INF-3983 Capstone",
  // What field you are majoring in
  major: "Computer Science",
  // The faculty and department at which you are working
  faculty: "Faculty of Science and Technology",
  department: "Department of Computer Science",
  // Date that will be displayed on cover page.
  // The value needs to be of the 'datetime' type.
  // More info: https://typst.app/docs/reference/foundations/datetime/
  date: datetime(year: 2025, month: 6, day: 1),
  // Format in which the date will be displayed on cover page.
  // More info: https://typst.app/docs/reference/foundations/datetime/#format
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  // The contents for the epigraph page. This will be displayed after the acknowledgements.
  // Can be omitted if you don't have one
  epigraph: none,
  // An abstract for your work. Can be omitted if you don't have one.
  abstract: none,
  // The contents for the acknowledgements page. This will be displayed after the
  // abstract. Can be omitted if you don't have one.
  acknowledgements: none,
  // An appendix after the bibliography.
  appendix: [],
  // The contents for the preface page. This will be displayed after the cover page. Can
  // be omitted if you don't have one.
  preface: none,
  // The result of a call to the `bibliography` function or `none`.
  // Example: bibliography("refs.bib", title: "Bibliography", style: "ieee")
  // More info: https://typst.app/docs/reference/model/bibliography/
  bibliography: none,
  // Display an index of figures (images).
  figure-index: true,
  // Display an index of tables
  table-index: true,
  // Display an index of listings (code blocks).
  listing-index: true,
  // List of abbreviations
  abbreviations: none,
  // The content of your work.
  body,
) = {
  // Set the document's metadata.
  set document(
    title: title,
    author: author,
    date: if date != none {
      date
    } else {
      auto
    },
  )

  // Required init for packages
  show: make-glossary
  register-glossary(abbreviations)
  show: codly-init

  // Optimize numbers with superscript
  // especially nice for bibliography entries
  show regex("\d?\dth"): w => {
    // 26th, ...
    let b = w.text.split(regex("th")).join()
    [#b#super([th])]
  }
  show regex("\d?\dst"): w => {
    // 1st
    let b = w.text.split(regex("st")).join()
    [#b#super([st])]
  }
  show regex("\d?\d[nr]d"): w => {
    // 2nd, 3rd, ...
    let s = w.text.split(regex("\d")).last()
    let b = w.text.split(regex("[nr]d")).join()
    [#b#super(s)]
  }

  // If we find in bibentries some ISBN, we add link to it
  show "https://doi.org/": w => {
    // handle DOIs
    [DOI:] + str.from-unicode(160) // 160 A0 nbsp
  }
  show regex("ISBN \d+"): w => {
    let s = w.text.split().last()
    link(
      "https://isbnsearch.org/isbn/" + s,
      w,
    ) // https://isbnsearch.org/isbn/1-891562-35-5
  }

  // Hanging indent for footnote
  show footnote.entry: set par(hanging-indent: 1.5em)

  // Set the body font.
  // Default is XCharter at 11pt
  set text(font: ("XCharter", "Charter"), size: 11pt)

  // Set raw text font.
  // Default is JetBrains Mono at 9tp with DejaVu Sans Mono as fallback
  show raw: set text(font: ("JetBrains Mono", "DejaVu Sans Mono"), size: 9pt)

  // Configure page size and margins.
  set page(
    paper: "a4",
    margin: (
      bottom: 5cm,
      top: 4cm,
      inside: 26.2mm,
      outside: 37mm,
    ),
    numbering: "1",
    number-align: center,
  )

  // Configure paragraph properties.
  // Default leading is 0.7em.
  // Default spacing is 1.35em.
  set par(
    leading: 0.7em,
    justify: true,
    linebreaks: "optimized",
    spacing: 1.35em,
  )

  // Configure reference supplement for headings
  set ref(
    supplement: it => context {
      if it.func() == heading {
        if in-appendix.get() {
          [Appendix]
        } else {
          [Chapter]
        }
      } else {
        it.supplement
      }
    },
  )

  // Add some vertical spacing for all headings
  show heading: it => {
    let body = if it.level > 1 {
      box(width: 12pt * it.level, counter(heading).display())
      it.body
    } else {
      it
    }
    v(2.5em, weak: true)
    body
    v(1.5em, weak: true)
  }

  // Style chapter headings
  show heading.where(level: 1): it => {
    set text(font: ("Open Sans", "Noto Sans"), weight: "bold", size: 24pt)

    let heading-number = if heading.numbering == none {
      []
    } else {
      text(
        counter(heading.where(level: 1)).display(),
        features: ("lnum",),
        size: 62pt,
      )
    }

    // Reset figure numbering on every chapter start
    for kind in (image, table, raw) {
      counter(figure.where(kind: kind)).update(0)
      // Also reset equation numbering
      counter(math.equation).update(0)
    }

    // Start chapter headings on a new page
    pagebreak(weak: true)

    v(16%)
    if heading.numbering != none {
      stack(
        dir: ltr,
        move(
          dy: 54pt,
          polygon(
            fill: uit-teal-color,
            stroke: uit-teal-color,
            (0pt, 0pt),
            (5pt, 0pt),
            (40pt, -90pt),
            (35pt, -90pt),
          ),
        ),
        heading-number,
      )
      v(1.0em)
      it.body
      v(-1.5em)
    } else {
      it.body
    }
  }

  // Configure heading numbering.
  set heading(numbering: "1.1")


  // Do not hyphenate headings.
  show heading: set text(
    font: ("Open Sans", "Noto Sans"),
    weight: "bold",
    hyphenate: false,
  )

  set page(
    // Set page header
    header-ascent: 30%,
    header: context {
      // Get current page number
      let page-number = here().page()

      // If the current page is the start of a chapter, don't show a header
      let chapters = heading.where(level: 1)
      if query(chapters).any(it => it.location().page() == page-number) {
        return []
      }

      // Find the chapter of the section we are currently in
      let chapters-before = query(chapters.before(here()))
      if chapters-before.len() > 0 {
        let current-chapter = chapters-before.last()


        // If a new subsecion starts on this page, select that subsection.
        // Otherwise, select the last subsection
        let current-subsection = {
          let subsections = heading.where(level: 2)
          let subsections-after = query(subsections.after(here()))

          if subsections-after.len() > 0 {
            let next-subsection = subsections-after.first()

            if next-subsection.location().page() == page-number {
              (next-subsection)
            } else {
              let subsections-before = query(subsections.before(here()))

              if subsections-before.len() > 0 {
                (subsections-before.last())
              } else {
                // No subsections in this chapter
                none
              }
            }
          }
        }

        let colored-slash = text(fill: uit-teal-color, "/")
        let spacing = h(3pt)

        // Content to display subsection count and heading
        let subsection-text = if current-subsection != none {
          let subsection-numbering = current-subsection.numbering
          let location = current-subsection.location()
          let subsection-count = numbering(
            subsection-numbering,
            ..counter(heading).at(location),
          )

          [#subsection-count #spacing #colored-slash #spacing #current-subsection.body]
        } else {
          // No subsections in chapter, display nothing
          []
        }

        // Content to display chapter count and heading
        let chapter-text = {
          let chapter-title = current-chapter.body
          let chapter-number = counter(heading.where(level: 1)).display()
          let prefix = if in-appendix.get() { [APPENDIX] } else { [CHAPTER] }

          [#prefix #chapter-number #spacing #colored-slash #spacing #chapter-title]
        }

        if current-chapter.numbering != none {
          // Show current chapter on odd pages, current subsection on even
          let (left-text, right-text) = if calc.odd(page-number) {
            (counter(page).display(), chapter-text)
          } else {
            (
              subsection-text,
              counter(page).display(),
            )
          }
          text(
            weight: "thin",
            font: ("Open Sans", "Noto Sans"),
            size: 8pt,
            fill: uit-gray-color,
            fill-line(upper(left-text), upper(right-text)),
          )
        }
      }
    },
  )

  // -- Equations --

  // Configure equation numbering.
  set math.equation(
    numbering: n => {
      set text(font: ("XCharter", "Charter"))
      let h1 = counter(heading).get().first()
      numbering("(1.1)", h1, n)
    },
  )

  show math.equation.where(block: true): it => {
    set align(center)
    // Indent
    pad(left: 2em, it)
  }

  // -- Figures --

  // Set figure numbering to follow chapter
  set figure(
    numbering: n => {
      let h1 = counter(heading).get().first()
      numbering("1.1", h1, n)
    },
  )

  set figure.caption(separator: [ -- ])

  show figure.caption: c => {
    if c.numbering == none {
      c
    } else {
      text(weight: "bold")[
        #c.supplement #context c.counter.display(c.numbering)
      ]
      c.separator
      c.body
    }
  }

  // -- Tables --

  // Break large tables across pages.
  show figure.where(kind: table): it => {
    set block(breakable: true)
    it
  }

  // Use lighter gray color for table stroke
  set table(
    inset: 7pt,
    stroke: (0.5pt + stroke-color),
  )
  // Show table header in small caps
  show table.cell.where(y: 0): smallcaps

  // Display inline code in a small box that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: fill-color.darken(2%),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // -- Links --

  // Show a small maroon circle next to external links.
  show link: it => {
    it
    // NOTE: Avoid linebreak before link indicators by using a word-joiner unicode character.
    if type(it.dest) == str {
      sym.wj
      h(1.6pt)
      sym.wj
      super(
        box(
          height: 3.8pt,
          circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333")),
        ),
      )
    }
  }

  // -- Definitions and Theorems --
  show: thmrules.with(qed-symbol: $qed$)

  // -- Lists --

  let list-spacing = 18pt
  let nested-list-spacing = 12pt
  set enum(indent: list-spacing, spacing: list-spacing)
  set list(indent: list-spacing, spacing: list-spacing)
  let show-list-enum(it) = {
    // Reduce spacing for nested list
    set enum(indent: nested-list-spacing, spacing: nested-list-spacing)
    set list(indent: nested-list-spacing, spacing: nested-list-spacing)
    // Reduce top and bottom padding for nested list
    let padding-y = {
      if it.spacing == list-spacing {
        v(list-spacing / 2)
      } else {
        v(1pt)
      }
    }
    padding-y
    it
    padding-y
  }
  show enum: it => {
    show-list-enum(it)
  }
  show list: it => {
    show-list-enum(it)
  }

  // -- Front matter --

  // Display front page
  frontpage(
    title: title,
    subtitle: subtitle,
    author: author,
    degree: degree,
    faculty: faculty,
    department: department,
    major: major,
    date: date,
  )

  // Use front matter stylings
  show: front-matter

  // List of Supervisors
  supervisors-page(supervisors)

  // Epigraph
  epigraph-page()[#epigraph]

  // Abstract
  abstract-page()[#abstract]

  // Acknowledgements
  acknowledgements-page()[#acknowledgements]

  // -- Outlines --

  // Display outlines (table of content, table of figures, etc...)
  context {
    // Helper to target figure kinds
    let fig-t(kind) = figure.where(kind: kind)

    // The `in-outline` is for showing a short caption in the list of figures
    // See https://sitandr.github.io/typst-examples-book/book/snippets/chapters/outlines.html#long-and-short-captions-for-the-outline
    show outline: it => {
      in-outline.update(true)
      // Show table of contents, list of figures, list of tables, etc. in the table of contents
      set heading(outlined: true)
      it
      in-outline.update(false)
    }

    // Increase distance between dots on all outline fill
    set outline.entry(fill: box(width: 1fr, repeat([#h(2.5pt) . #h(2.5pt)])))

    pagebreak()

    // Common padding to use on outline entries
    let entry-spacing-left = 0.25em
    let entry-spacing-right = 22pt

    [

      #show outline.entry: it => context {
        // Calculate relative spacing, to line up fill regardless of page number width
        let page-number-spacing = entry-spacing-right - measure(it.page()).width
        link(
          it.element.location(),
          it.indented(
            it.prefix() + h(entry-spacing-left),
            it.body()
              + h(entry-spacing-left)
              + box(width: 1fr, it.fill)
              + h(page-number-spacing)
              + it.page(),
          ),
        )
      }

      #show outline.entry.where(level: 1): it => {
        set text(weight: "bold")
        set block(above: 1.5em)
        link(
          it.element.location(),
          it.indented(
            it.prefix(),
            it.body() + box(width: 1fr, none) + it.page(),
          ),
        )
      }

      #outline(title: "Contents")
    ]

    show outline.entry: it => context {
      let prefix = {
        show "Figure": ""
        show "Table": ""
        show "Listing": ""
        set text(weight: "bold")
        it.prefix()
      }
      // Calculate relative spacing, to line up fill regardless of page number width
      let page-number-spacing = entry-spacing-right - measure(it.page()).width
      link(
        it.element.location(),
        it.indented(
          prefix + h(entry-spacing-left),
          it.body()
            + h(entry-spacing-left)
            + box(width: 1fr, it.fill)
            + h(page-number-spacing)
            + it.page(),
        ),
      )
    }

    // Remaining outlines are all optional
    if figure-index {
      outline(title: "List of Figures", target: fig-t(image))
    }
    if table-index {
      outline(title: "List of Tables", target: fig-t(table))
    }
    if listing-index {
      outline(title: "List of Listings", target: fig-t(raw))
    }
    // TODO: Add (optional) outline for definitions, when upstream issue is fixed:
    // https://github.com/sahasatvik/typst-theorems/issues/46
    // outline(title: "List of Definitions", target: figure.where(kind: "thmenv"))
  }

  // List of Abbreviations
  if abbreviations != none {
    abbreviations-page(abbreviations)
  }

  // -- Main matter --

  // Use main matter stylings
  show: main-matter

  // Thesis content
  body

  // -- Back matter --

  // Use back matter stylings
  show: back-matter

  // Style bibliography
  if bibliography != none {
    pagebreak()
    // show std-bibliography: set text(0.95em)
    show std-bibliography: set text(12pt)
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(
      leading: 0.65em,
      justify: false,
      linebreaks: auto,
    )
    bibliography
  }

  // Display appendix after the bibilography
  in-appendix.update(true)
  appendix

  // Display back page
  backpage()
}
