// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let serif-font = ("Times New Roman", "Liberation Serif")
#let sans-serif-font = ("Helvetica", "Liberation Sans")
#let mono-font = ("Liberation Mono") // LaTeX uses txtt

// This function gets your whole document as its `body` and formats
// it as a VGTC conference paper.
#let conference(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email.
  // Everything but the name is optional.
  authors: (),

  // The paper's abstract.
  abstract: none,

  // Teaser image path and caption
  teaser: (),

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // Review mode - hides authors and shows submission info
  review: false,

  // Submission ID (for review mode)
  submission-id: 0,

  // Category (for review mode)
  category: none,

  // Paper type (for review mode)
  paper-type: none,

  // Custom manuscript note (appears in footer of first page)
  manuscript-note: none,

  // The paper's content.
  body
) = {
  // Set document metadata.
  if review {
    set document(title: title, author: "Anonymous")
  } else {
    set document(title: title, author: authors.map(author => author.name))
  }

  set text(font: serif-font, size: 9pt)

  // Custom small caps with dual sizing (hack for fonts without small caps)
  // TODO: Remove when Typst implements synthetic small caps: https://github.com/typst/typst/issues/7009
  let render-smallcaps(body) = {
    if body.has("text") {
      for letter in body.text {
        if letter == upper(letter) {
          text(size: 9pt, letter)
        } else {
          text(size: 7pt, upper(letter))
        }
      }
    } else {
      smallcaps(body)
    }
  }

  // Configure links
  show link: it => {
    set text(fill: rgb("#000080"))
    if type(it.dest) == str {
      set text(font: mono-font, size: 8pt)
      it
    } else {
      it
    }
  }

  // Configure page
  set page(
    paper: paper-size,
    margin: (
      top: 51pt,
      bottom: 54pt,
      left: 54pt,
      right: 54pt
    ),
    header: if review {
      context {
        if calc.odd(counter(page).get().first()) {
          align(center, emph([Online Submission ID: #submission-id]))
        }
      }
    }
  )

  // Configure equations
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure references
  show ref: it => {
    set text(fill: rgb("#000080"))
    if it.element != none and it.element.func() == math.equation {
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      it
    }
  }

  // Configure lists
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure figures
  set figure(gap: 10pt)
  show figure.caption: it => {
    set text(font: sans-serif-font, size: 8pt)
    it
  }

  // Configure headings
  set heading(numbering: "1.1.1")
  show heading: set text(font: sans-serif-font, size: 9pt, weight: "bold")

  show heading.where(level: 1): it => {
    let is-ack = it.body in ([Acknowledgments], [Acknowledgements])

    set par(first-line-indent: 0pt)
    block(above: 12pt, below: 7.2pt)[
      #if it.numbering != none and not is-ack {
        numbering("1", ..counter(heading).get())
        h(7pt, weak: true)
      }
      #render-smallcaps(it.body)
    ]
  }

  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt)
    block(above: 12pt, below: 7.2pt, it)
  }

  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt)
    text(style: "italic", weight: "normal")[
      #numbering("1.1.1)", ..counter(heading).get())
      #it.body:
    ]
  }

  // Conference-specific: center captions and add spacing below figures
  show figure.caption: set align(center)
  show figure: it => {
    it
    v(8pt)
  }

  // Title
  v(42pt, weak: true)
  align(center, text(14pt, weight: "bold", title, font: sans-serif-font))
  v(18pt, weak: true)

  // Authors
  if review {
    align(center, text(10pt, font: sans-serif-font, [
      Category: #category
      #v(-0.2em)
      Paper Type: #paper-type
    ]))
  } else {
    set par(leading: 0.4em)
    align(center)[
      #grid(
        columns: authors.len(),
        gutter: 1.5em,
        ..authors.map(author => [
          #text(10pt, font: sans-serif-font)[
            #author.name
            #if "orcid" in author and author.orcid != "" {
              link("https://orcid.org/" + author.orcid)[#box(height: 1.1em, baseline: 13.5%)[#pdf.artifact[#image("assets/orcid.svg")]]]
            }
            #if "email" in author {
              footnote[#author.email]
            }
          ]\
          #text(8pt, font: sans-serif-font)[#author.organization]
        ])
      )
    ]
  }

  v(18pt, weak: true)

  // Teaser
  if teaser != () {
    [#figure(
      teaser.image,
      caption: teaser.caption,
    ) <teaser>]
    v(10pt, weak: true)
  }

  // Two-column layout
  show: columns.with(2, gutter: 24pt)
  set par(justify: true, first-line-indent: 1em, leading: 0.55em, spacing: 0.55em)
  set text(font: serif-font, size: 9pt)

  // Abstract
  if abstract != none {
    heading(level: 1, numbering: none)[Abstract]
    set par(justify: true)
    abstract

    if index-terms != () {
      parbreak()
      set par(first-line-indent: 0pt)
      text(weight: "bold")[Index Terms: ]
      index-terms.join(", ")
    }

    v(10pt)
  }

  body

  // Bibliography
  if bibliography != none {
    show std-bibliography: set text(8pt)
    set std-bibliography(
      title: text(font: sans-serif-font, size: 9pt, weight: "bold")[#render-smallcaps([References])],
      style: "ieee"
    )
    bibliography
  }
}

// This function gets your whole document as its `body` and formats
// it as a TVCG journal article.
#let journal(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email.
  // Everything but the name is optional.
  authors: (),

  // The paper's abstract.
  abstract: none,

  // Teaser image path and caption
  teaser: (),

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // Review mode - hides authors and shows submission info
  review: false,

  // Submission ID (for review mode)
  submission-id: 0,

  // Category (for review mode)
  category: none,

  // Paper type (for review mode)
  paper-type: none,

  // Custom manuscript note (appears in footer of first page)
  manuscript-note: none,

  // The paper's content.
  body
) = {
  // Set document metadata.
  if review {
    set document(title: title, author: "Anonymous")
  } else {
    set document(title: title, author: authors.map(author => author.name))
  }

  // Set the body font.
  set text(font: serif-font, size: 9pt)

  // Custom small caps with dual sizing (hack for fonts without small caps)
  // TODO: Remove when Typst implements synthetic small caps: https://github.com/typst/typst/issues/7009
  let render-smallcaps(body) = {
    if body.has("text") {
      for letter in body.text {
        if letter == upper(letter) {
          text(size: 9pt, letter)
        } else {
          text(size: 7pt, upper(letter))
        }
      }
    } else {
      smallcaps(body)
    }
  }

  // Configure links to use NavyBlue color and monospace font (matching LaTeX hyperref/url settings)
  show link: it => {
    set text(fill: rgb("#000080")) // NavyBlue (SVG color)
    // URLs should use monospace font like LaTeX \url{}
    if type(it.dest) == str {
      set text(font: mono-font, size: 8pt)
      it
    } else {
      it
    }
  }

  // Configure the page.
  set page(
    paper: paper-size,
    margin: (
      top: 54pt, // 0.75in
      bottom: 45pt, // 0.625in
      inside: 54pt, // 0.75in
      outside: 45pt // 0.625in
    ),
    header: if review {
      context {
        if calc.odd(counter(page).get().first()) {
          align(center, emph([Online Submission ID: #submission-id]))
        }
      }
    }
  )

  // Configure equations
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure references
  show ref: it => {
    set text(fill: rgb("#000080"))
    if it.element != none and it.element.func() == math.equation {
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      it
    }
  }

  // Configure lists
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure figures
  set figure(gap: 10pt)
  show figure.caption: it => {
    set text(font: sans-serif-font, size: 8pt)
    it
  }

  // Configure headings
  set heading(numbering: "1.1.1")
  show heading: set text(font: sans-serif-font, size: 9pt, weight: "bold")

  show heading.where(level: 1): it => {
    let is-ack = it.body in ([Acknowledgments], [Acknowledgements])

    set par(first-line-indent: 0pt)
    block(above: 12pt, below: 7.2pt)[
      #if it.numbering != none and not is-ack {
        numbering("1", ..counter(heading).get())
        h(7pt, weak: true)
      }
      #render-smallcaps(it.body)
    ]
  }

  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt)
    block(above: 12pt, below: 7.2pt, it)
  }

  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt)
    text(style: "italic", weight: "normal")[
      #numbering("1.1.1)", ..counter(heading).get())
      #it.body:
    ]
  }

  // Display the paper's title.
  v(3pt, weak: true)
  align(center, text(18pt, title, font: sans-serif-font))
  v(23pt, weak: true)

  // Display the authors list or submission info (if review mode).
  if review {
    align(center, text(10pt, font: sans-serif-font, [
      Category: #category
      #v(-0.2em)
      Paper Type: #paper-type
    ]))
  } else {
    let and-comma = if authors.len() == 2 {" and "} else {", and "}

    align(center,
      text(10pt, font: sans-serif-font, authors.map(author => {
          author.name
          if "orcid" in author and author.orcid != "" {
            link("https://orcid.org/" + author.orcid)[#box(height: 1.1em, baseline: 13.5%)[#pdf.artifact[#image("assets/orcid.svg")]]]
          }
        } ).join(", ", last: and-comma)
      )
    )
  }

  v(6pt, weak: true)
  block(inset: (left: 24pt, right: 24pt), [
    
      // Insert teaser image
      #figure(
          teaser.image,
          caption: teaser.caption,
        ) <teaser>

      #v(10pt, weak: true)

      // Display abstract and index terms.
      // LaTeX uses \scriptsize (8pt with 9.5pt leading)
      #(if abstract != none [
          #set par(justify: true, leading: 0.65em)
          #set text(font: sans-serif-font, size: 8pt)
          #[*Abstract*---#abstract]

          #if index-terms != () [
            *Index terms*---#index-terms.join(", ")
          ]
        ]
      )
    ]
  )

  v(10pt, weak: true)
  align(center, pdf.artifact[#image("assets/diamondrule.svg", width: 40%)])
  v(15pt, weak: true)

  // Start two column mode and configure paragraph properties.
  show: columns.with(2, gutter: 12.24pt) // 0.17in

  // LaTeX uses 9pt font with 10pt baseline skip
  set par(justify: true, first-line-indent: 1em, leading: 0.55em, spacing: 0.65em)


  // Footer with author info
  if not review {
    place(left+bottom, float: true, block(
        width: 100%,[
          #align(center, line(length: 50%, stroke: 0.4pt))

          #set text(style: "italic", size: 7.5pt, font: serif-font)
          #set list(indent: 0pt, body-indent: 5pt, spacing: 0.5em)
          #for author in authors [
            - #author.name is with #author.organization. #box(if "email" in author [E-mail: #author.email.])
          ]
          #v(4pt)
          #if manuscript-note != none [
            #manuscript-note
          ] else [
            Manuscript received DD MMM. YYYY; accepted DD MMM. YYYY.
            Date of Publication DD MMM. YYYY; date of current version DD MMM. YYYY.
            For information on obtaining reprints of this article, please send e-mail to: reprints`@`ieee.org.
            Digital Object Identifier: xx.xxxx/TVCG.YYYY.xxxxxxx
          ]
        ]
      )
    )
  }

  set text(font: serif-font, size: 9pt)

  body

  if bibliography != none {
    show std-bibliography: set text(8pt)
    set std-bibliography(
      title: text(font: sans-serif-font, size: 9pt, weight: "bold")[#render-smallcaps([References])],
      style: "ieee"
    )
    bibliography
  }
}
