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

// This function gets your whole document as its `body` and formats it as a simple
// non-fiction paper.
#let ilm(
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

  // An abstract for your work. Can be omitted if you don't have one.
  abstract: none,

  // The contents for the preface page. This will be displayed after the cover page. Can
  // be omitted if you don't have one.
  preface: none,

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // Whether to start a chapter on a new page.
  chapter-pagebreak: true,

  // Whether to display an index of figures (images).
  figure-index: false,

  // Whether to display an index of tables
  table-index: false,

  // Whether to display an index of listings (code blocks).
  listing-index: false,

  // The content of your work.
  body,
) = {
  // Set the document's metadata.
  set document(title: title, author: author)

  // Set the body font.
  // Default is Linux Libertine at 11pt
  set text(font: "Linux Libertine", size: 12pt)

  // Set raw text font.
  // Default is Fira Mono at 8.8pt
  show raw: set text(font: ("Iosevka", "Fira Mono"), size: 9pt)

  // Configure page size and margins.
  set page(
    paper: paper-size,
    margin: (bottom: 1.75cm, top: 2.25cm),
  )

  // Cover page.
  page(align(left + horizon, block(width: 90%)[
      #let v-space = v(2em, weak: true)
      #text(3em)[*#title*]

      #v-space
      #text(1.6em, author)

      #if abstract != none {
        v-space
        block(width: 80%)[
          // Default leading is 0.65em.
          #par(leading: 0.78em, justify: true, linebreaks: "optimized", abstract)
        ]
      }

      #if date != none {
        v-space
        // Display date as MMMM DD, YYYY
        text(date.display("[month repr:long] [day padding:zero], [year repr:full]"))
      }
  ]))

  // Configure paragraph properties.
  // Default leading is 0.65em.
  set par(leading: 0.7em, justify: true, linebreaks: "optimized")
  // Default spacing is 1.2em.
  show par: set block(spacing: 1.35em)

  // Configure heading properties.
  set heading(numbering: "1.")
  show heading: it => {
    // Do not hyphenate headings.
    set text(hyphenate: false)
    // Start chapters on a new page except for bibliography and indices. We do a manual
    // pagebreak for bibliography and indices (see explanation down below).
    if chapter-pagebreak and it.level == 1 {
      let b-t = it.body.text
      if not b-t.starts-with("Index of") and b-t != "Bibliography" {
        pagebreak()
      }
    }
    it
    v(2%, weak: true)
  }

  // Show a small maroon circle next to external links.
  show link: it => {
    // Workaround for ctheorems package so that its labels keep the default link styling.
    if type(it.dest) == label { return it }
    it
    h(1.6pt)
    super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333"))))
  }

  // Display preface as the second page.
  if preface != none {
    // Do not number headings on the preface page.
    set heading(numbering: none)
    page(preface)
  }

  // Indent nested entires in the outline.
  set outline(indent: auto)

  // Display table of contents.
  outline(title: "Contents")

  // Configure page numbering and footer.
  set page(
    footer: context {
      // Get current page number.
      let i = counter(page).at(here()).first()

      // Align right for even pages and left for odd.
      let is-odd = calc.odd(i)
      let aln = if is-odd { right } else { left }

      // Are we on a page that starts a chapter?
      let target = heading.where(level: 1)
      if query(target).any(it => it.location().page() == i) {
        return align(aln)[#i]
      }

      // Find the chapter of the section we are currently in.
      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()
        let gap = 1.75em
        let chapter = upper(text(size: 0.68em, current.body))
        if current.numbering != none {
            if is-odd {
              align(aln)[#chapter #h(gap) #i]
            } else {
              align(aln)[#i #h(gap) #chapter]
            }
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
  show raw.where(block: true): block.with(
    inset: (x: 5pt),
  )

  // Break large tables across pages.
  show figure.where(kind: table): set block(breakable: true)
  set table(
    // Increase the table cell's padding
    inset: 7pt, // default is 5pt
    stroke: (0.5pt + stroke-color)
  )
  // Use smallcaps for table header row.
  show table.cell.where(y: 0): smallcaps

  body

  // Display bibliography.
  if bibliography != none {
    // Display bibliography on a new page regardless of whether `chapter-pagebreak` is
    // enabled or not.
    pagebreak()
    show std-bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bibliography
  }

  // Display indices of figures, tables, and listings.
  let fig-t(kind) = figure.where(kind: kind)
  let has-fig(kind) = counter(fig-t(kind)).get().at(0) > 0
  if figure-index or table-index or listing-index {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index and has-fig(image)
      let tbls = table-index and has-fig(table)
      let lsts = listing-index and has-fig(raw)
      if imgs or tbls or lsts {
        // Display Indices on a new page regardless of whether `chapter-pagebreak` is
        // enabled or not. Note that we pagebreak only once instead of each each
        // individual index. This is because for documents that only have a couple of
        // figures, starting each index on new page would result in superfluous
        // whitespace.
        pagebreak()
      }

      if imgs { outline(title: "Index of Figures", target: fig-t(image)) }
      if tbls { outline(title: "Index of Tables", target: fig-t(table)) }
      if lsts { outline(title: "Index of Listings", target: fig-t(raw)) }
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
    body
  )
}
