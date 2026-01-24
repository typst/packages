// amcis.typ
#let author-card(a) = [
    #text(font: "Georgia", size: 13pt, weight: "bold")[#a.at(0)]
    #linebreak()
    #text(font: "Georgia", size: 13pt)[#a.at(1)]
    #linebreak()
    #text(font: "Georgia", size: 13pt)[#a.at(2)]
  ]

#let authors-table(authors) = {
  if authors.len() == 0 { return }

  let authors-list = for i in range(0, authors.len()) {
        if i == authors.len() - 1 and calc.rem(authors.len(), 2) == 1 {
          (grid.cell(colspan: 2)[
            #author-card(authors.at(i))
          ], )
        } else {
          (grid.cell()[#author-card(authors.at(i))], )
        }
      }
  
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    align: (center, center),
    ..authors-list
  )
  
}



#let amcis(
  // Header/footer
  short-title: [Short title (up to 8 words)],
  conference-line: [Thirty-second Americas Conference on Information Systems, Reno, 2026],

  
  title: [Paper Submission Title],
  paper-type: "Full Paper",
  // Front matter (required only for camera-ready)
  abstract: none,
  keywords: (),
  acknowledgements: [], // Optional
  authors: (),
  bib: [],
  camera-ready: false,

  doc
) = {
  // Page layout
  set page(
    paper: "us-letter",
    margin: (x: 1in, bottom: 1in, top: 0.75in),
    numbering: "1",

    header: align(right)[
      #text(size: 9pt)[#emph(short-title)]
    ],

    footer: context [
      #set align(right)
      #text(size: 8pt)[
        #emph(conference-line) #h(1em) #counter(page).display()
      ]
    ],
  )

  // Body text
  set text(font: "Georgia", size: 10pt)
  set par(justify: true)

  // Headings: unnumbered
  set heading(numbering: none)
  show heading.where(level: 1): set text(size: 13pt, weight: "bold")
  show heading.where(level: 2): set text(size: 11pt, weight: "bold", style: "italic")
  show heading.where(level: 3): set text(size: 10pt, weight: "bold")

  // Figure/table captions (centered, bold, 10pt)
  show figure.caption: it => align(center)[
    #text(size: 10pt, weight: "bold")[#it]
  ]

  // Link formatting
  show link: underline


  block(width: 100%, spacing: 6pt)[
    #align(center)[
      #text(font: "Georgia", weight: "bold", size: 20pt)[#title]
    ]
  ]

  if paper-type != none {
    align(center)[
      #text(style: "italic", size: 12pt)[#paper-type]
    ]
  }

    
    
  // Optional front matter (often OFF for initial submission)
  if camera-ready {

      if authors.len() > 0 {
        authors-table(authors)
      parbreak()
    }

    
    if abstract != none {
      parbreak()
      heading([Abstract])
      abstract
    }

    if keywords.len() > 0 {
      heading([Keywords], level: 2)
      // join keywords with commas
      for (i, k) in keywords.enumerate() {
        k
        if i < keywords.len() - 1 { [, ] }
      }
    }
    
    parbreak()
  }

  // Render the actual document
  doc

  if camera-ready {
    if acknowledgements != none {
      heading([Acknowledgements])
      acknowledgements
    }
  }

  if bib != none {
    heading("REFERENCES")
    set bibliography(title: none, style: "apa")

    bib
  }
// bibliography(bib, style: "apa", title: "REFERENCES")
}
