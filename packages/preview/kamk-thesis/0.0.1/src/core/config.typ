#import "colors.typ": code-block-bg

#let lang-data = toml("../data/lang.toml")

// Document-wide defaults: metadata, base text/paragraph style. Applied once, at the very start.
// Takes `body` so the set/show rules stay in scope for the rest of the document, since Typst
// scopes them to the block they're defined in rather than leaking into the caller.
#let setup-document(title: "", authors: (), language: "fi", body) = {
  set document(title: title, author: authors)
  set text(size: 11pt, lang: language, font: "Carlito")
  set par(justify: true, leading: 1.5em)
  body
}

/*
  Equation numbering defaults, kept separate from setup-body-page so it can be
  applied and tested on its own (see tests/math-fi).
  Takes `body` for the same set-rule-scoping reason as setup-document.

  - Uses Typst's built-in equation numbering (no custom counters/layout)
  - Wraps the number in parentheses, e.g. "(1)", per KAMK conventions
  - Uses the localized "Kaava"/"Equation" supplement instead of Typst's default "Equation"
  */
#let setup-math(language: "fi", body) = {
  let lang-data = toml("../data/lang.toml")
  set math.equation(numbering: "(1)", supplement: lang-data.at(language).equation)
  body
}

/*
  Heading reference supplement, kept separate so it can be applied and tested
  on its own (see tests/ch-labels-fi). Takes `body` for the same set-rule-scoping
  reason as setup-document.

  - Uses the localized "Luku"/"Chapter" supplement for heading references
  - Heading numbering itself (e.g. "1.1") is enabled later, once the ToC has
    been rendered (see frontmatter.typ), so a reference reads as "Luku 2.3"
  */
#let setup-headings(language: "fi", body) = {
  let lang-data = toml("../data/lang.toml")
  set heading(supplement: lang-data.at(language).chapter)
  body
}


/*
  Automatically styles all code listings using standard Markdown syntax.
  - Short (< 10 lines): Rendered automatically with a side-counter (1).
  - Long (>= 10 lines): Renders with line numbers. Requires user to wrap it in a #figure().
*/
#let short-code-counter = counter("short-code")
#let setup-code(language: "fi", body) = {
  // 1. Set supplements globally for code figures
  show figure.where(kind: raw): set figure(supplement: lang-data.at(language).code)

  // 2. Style the raw block itself (background, padding, line numbers)
  show raw.where(block: true): it => {
    let is-long = it.text.split("\n").len() >= 10
    
    let styled = {
      set text(size: 10pt)
      set par(leading: 0.75em)
      show raw.line: line => {
        if is-long {
          box(width: 1.25em)[#align(right, text(size: 10pt, fill: gray, str(line.number)))] + h(1.5em) + line.body
        } else {
          line
        }
      }
      it
    }

    block(
      width: 100%,
      fill: code-block-bg,
      inset: 1em,
      radius: 4pt,
      breakable: true,
    )[#align(left)[#styled]]
  }

  // 3. Handle the Figure Layout (Short vs Long)
// 3. Handle the Figure Layout (Short vs Long)
  show figure.where(kind: raw): it => {
    // Safely extract the raw element, even if the user wrapped it in square brackets
    let raw-elem = it.body
    if raw-elem.func() != raw and raw-elem.has("children") {
      let found = raw-elem.children.find(e => e.func() == raw)
      if found != none {
        raw-elem = found
      }
    }

    // Determine line count safely
    let is-long = false
    if raw-elem != none and raw-elem.has("text") {
      is-long = raw-elem.text.split("\n").len() >= 10
    }

    if is-long {
      assert(
        it.caption != none,
        message: ">= 10 rivin koodilohko vaatii kuvatekstin (caption)."
      )
      // Long block: standard figure layout (caption below)
      it
    } else {
      // Short block layout: We intercept the figure and draw a custom grid.
      block(width: 100%)[
        #grid(
          columns: (1fr, auto),
          column-gutter: 1em,
          align: (left, right + horizon),
          it.body,
          context counter(figure.where(kind: raw)).display("(1)")
        )
      ]
    }
  }

  body
}

/*
  Table figure defaults.

  - Places table captions above the table
  - Applies only to figures whose kind is `table`
  - Does not affect image or raw/code figures
*/
#let setup-tables(language: "fi", body) = {
  // Place captions above table figures.
  show figure.where(kind: table): set figure.caption(position: top)

  // Render the first row of every table in bold. 
  // Can be overridden by the user with: set text(weight: "regular")
  show table.cell.where(y: 0): set text(weight: "bold")

  body
}

/*
  Page and body-content defaults for everything after the zero-margin title page.
  Takes `body` so that page settings and set/show rules remain in scope for the
  document body.

  - Sets the A4 page size and KAMK margins
  - Configures spacing above and below all headings
  - Starts each level-one heading on a new page
  - Sets spacing between body paragraphs
  - Overrides Typst's default heading style with regular-weight 11 pt text
  - Applies localized heading-reference supplements through setup-headings
  - Applies equation numbering and localized supplements through setup-math
  - Places table captions above tables through setup-tables
  - Applies code-block and code-figure styling through setup-code
*/
#let setup-body-page(language: "fi", body) = {
  set page(
    paper: "a4",
    margin: (top: 2cm, bottom: 2.5cm, left: 4.3cm, right: 1.5cm)
  )
  
  show heading: set block(above: 3.0em, below: 2.0em)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  set par(spacing: 3.0em)
  show heading: set text(size: 11pt, weight: "regular")
  
  // Cleanly apply all wrappers without nested parentheses
  show: setup-headings.with(language: language)
  show: setup-math.with(language: language)
  show: setup-tables.with(language: language)
  show: setup-code.with(language: language)

  body
}