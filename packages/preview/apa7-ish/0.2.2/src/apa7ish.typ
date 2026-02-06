#import "utils.typ": *
#import "definitions.typ": *

#let conf(
  title: "An Intriguing Title",
  subtitle: none,
  abstract: none,
  authors: (),
  date: none,
  documenttype: none,
  keywords: none,
  disclosure: none,
  funding: none,
  anonymous: false,
  language: "en",
  papersize: "a4",
  fontfamily: "Libertinus Serif",
  text-number-type: "old-style",
  text-number-width: "proportional",
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(
    numbering: "1",
    paper: papersize,
    number-align: top + right,
    margin: 33mm,
    header: {
      context if counter(page).get().at(0) > 1 [
        #smallcaps(lower(title))
        #h(1fr)
        #here().page()
      ]
    },
  )

  set text(
    font: fontfamily,
    lang: language,
    size: normal-size,
    number-type: text-number-type,
    number-width: text-number-width,
  )

  // Set paragraph spacing and leading.
  // Using Bringhurst's definition of "leading" which is from baseline to baseline
  // In his terms, the default setting is equivalent to 11/13
  // Caveat of changing Typst's "leading" definition is that all default settings
  // have to be set again (that's why there are so many definitions necessary below)
  set text(top-edge: "baseline", bottom-edge: "baseline")
  set par(spacing: 1.25em, leading: 1.25em)

  /////////////////////
  // Style Definitions
  /////////////////////

  // Set Heading styles
  show heading: it => {
    if it.level == 1 {
      v(1em)
      align(center, text(it, size: normal-size))
    } else {
      let wght = "bold"
      if it.level > 2 {
        wght = "regular"
      }
      v(0.5em)
      align(emph(text(it, size: normal-size, weight: wght)))
    }
    v(1.2em, weak: true)
  }

  // Lists
  set list(indent: 1em)
  show list: self => {
    v(0.5em)
    self
    v(0.5em)
  }

  // Bibliography
  set bibliography(title: "References", style: "american-psychological-association")

  // Figures
  show figure: set block(above: 2em, below: 2em)

  // Tables
  set table(stroke: 0pt)
  show table: tbl => {
    set block(spacing: 1.5em)
    set text(top-edge: "cap-height", bottom-edge: "baseline", number-type: "lining", number-width: "tabular")
    tbl
  }
  set figure.caption(position: top)
  show figure.caption: self => [
    #align(left)[
      *#self.supplement*
      #context [*#self.counter.display(self.numbering)*] \ #emph(self.body)
    ]
    #v(6pt)
  ]

  // Footnotes
  set footnote.entry(gap: 0.8em)
  show footnote.entry: it => {
    set par(leading: 1.05em)
    set text(size: footnote-size)
    it
  }

  // Block Quotes
  show quote.where(block: true): it => {
    set pad(x: 3em)
    set par(leading: 1.1em)
    it
  }

  // Links
  show link: set text(number-type: "lining", number-width: "tabular")


  /////////////////
  // Make Title Page
  /////////////////

  align(center)[
    #if documenttype != none [
      #smallcaps(lower(documenttype)) \ #v(0.2em)
    ]
    #text(1.5em, title) #v(0.4em, weak: true) \
    #if subtitle != none [
      #text(1.2em, subtitle) \
    ]
    #v(3em, weak: true)
  ]

  let authors-parsed = parse-authors(authors)

  // List Authors
  if not anonymous {
    pad(
      top: 0.3em,
      bottom: 0.3em,
      x: 2em,
      grid(
        columns: (1fr,) * calc.min(3, authors-parsed.authors.len()),
        gutter: 1em,
        ..authors-parsed.authors.map(author => align(center)[
          #author.name#super[#author.affiliation-parsed.map(pos => number2letter(pos)).sorted().join(", ")] \
        ]),
      ),
    )

    v(1em)

    let affiliation-counter = counter("affiliation-counter")
    affiliation-counter.update(1)

    align(center)[
      #for affiliation in authors-parsed.affiliations [
        #context super(affiliation-counter.display("a"))#h(1pt)#emph(affiliation) #affiliation-counter.step() \
      ]
      #v(1em)
      #date
      #v(2em, weak: true)
    ]
  } else {
    align(center)[
      #date
    ]
  }


  set par(justify: true)
  // Abstract & Keywords
  if abstract != none {
    heading(outlined: false, numbering: none, text(normal-size, weight: "regular", [Abstract]))
    align(center)[
      #block(
        width: 90%,
        [
          #align(left)[
            #abstract \
            #v(0.5em)
            #if keywords != none [
              #emph("Keywords: ") #keywords
            ]
          ]
        ],
      )
    ]
  }

  // Author Note
  if not anonymous {
    heading(outlined: false, numbering: none, text(normal-size, weight: "bold", [Author Note]))

    // ORCID IDs
    for author in authors-parsed.authors {
      set par(spacing: 0.4em)
      if "orcid" in author [
        #author.name #orcid(author.orcid) \
      ]
    }

    // Disclosures and Acknowledgements
    v(0.5em)
    if disclosure != none [
      #disclosure \
    ] else [
      We have no conflicts of interest to disclose. \
    ]

    if funding != none [
      #funding \
    ]

    // Contact Information
    [Correspondence concerning this article should be addressed to
      #authors-parsed.corresponding.name,]
    if "postal" in authors-parsed.corresponding [ #authors-parsed.corresponding.postal, ]
    if (
      "email" in authors-parsed.corresponding
    ) [Email: #link("mailto:" + authors-parsed.corresponding.email, authors-parsed.corresponding.email)]
  }

  pagebreak()

  // Main body.
  set par(first-line-indent: 2em)

  body
}
