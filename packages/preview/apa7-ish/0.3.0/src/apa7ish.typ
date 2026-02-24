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
  set text(top-edge: 1em, bottom-edge: "baseline")
  set par(spacing: 2pt, leading: 2pt)

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
    v(1em, weak: true)
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

  // Tables
  set table(stroke: 0pt)
  show table: tbl => {
    set block(spacing: 0.5em)
    set text(number-type: "lining", number-width: "tabular")
    tbl
  }

  // Figures
  show figure: set block(above: 2em, below: 2em)
  set figure.caption(position: top)
  show figure.caption: self => [
    #align(left)[
      *#self.supplement*
      #context [*#self.counter.display(self.numbering)*] \ #emph(self.body)
    ]
    #v(0.5em, weak: true)
  ]

  // Footnotes
  set footnote.entry(gap: 2pt)
  show footnote.entry: it => {
    set par(leading: 1pt)
    set text(size: footnote-size)
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
    let chunked = authors-parsed.authors.chunks(3)
    pad(
      top: 0.3em,
      bottom: 0.3em,
      x: 2em,
      {
        for chunk in chunked {
          stack(dir: ltr,
                spacing: 3em, 
                ..chunk.map(author => align(center)[#author.name#super[#h(1pt)#author.affiliation-parsed.map(pos => number2letter(pos)).sorted().join(", ")]]))
          v(1.5em)
        }
      },
    )

    v(1em)

    align(center)[
      #for (idx, affiliation) in authors-parsed.affiliations.enumerate() [
        #context super(number2letter(idx))#h(1pt)#emph(affiliation) \
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

  // Abstract & Keywords
  set par(justify: true)
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
      #authors-parsed.corresponding.name, ]
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
