// ============================================
// IIT Kharagpur Thesis/Report Template (Typst)
// ============================================

#import "@preview/hydra:0.6.2": hydra

#let iitkgp-thesis(
  // Metadata
  title: "",
  author: "",
  rollno: "",
  supervisor: "",
  department: "",
  degree: "",
  institution: "Indian Institute of Technology Kharagpur",
  location: "Kharagpur",
  pincode: "721302",
  // Customizable Parameters
  report-type: "M.Tech. Project–II (CH57004)",
  date: "April 17, 2026",
  logo: none,
  // Certificate and declaration text
  certificate-text: [],
  declaration-text: [],
  // Front matter
  abstract: [],
  acknowledgment: none,
  // Options
  figures-outline: true,
  tables-outline: false,
  abbreviations: (),
  body,
) = {
  // ============================================
  // GLOBAL TEXT / PARAGRAPH STYLE
  // ============================================
  set text(font: "New Computer Modern", size: 12pt, lang: "en")
  set par(
    leading: 1.4em,
    justify: true,
    first-line-indent: 1.5em,
    spacing: 1.6em,
  )

  // ============================================
  // TITLE PAGE
  // ============================================
  set page(
    paper: "a4",
    margin: (
      top: 1.4in,
      bottom: 1.6in,
      left: 1.25in,
      right: 1.0in,
    ),
    number-align: center,
    numbering: none,
  )

  {
    set par(first-line-indent: 0em, spacing: 0.5em)

    v(1fr)
    align(center)[
      // Title
      #text(size: 1.4em, weight: "bold", hyphenate: false)[#title]
      #v(2.5em)

      // Report Type & Standard text block
      #report-type \
      A report submitted to \
      #institution \
      in partial fulfilment of the requirements for the award of the

      #v(0.8em)

      // Degree
      #text(size: 1.3em, weight: "bold")[#degree]

      #v(1.0em)

      _by_
      #v(0.8em)

      #text(size: 1.3em, weight: "bold")[
        #author \
        (#rollno)
      ]

      #v(1.2em)

      Under the guidance of
      #v(0.8em)

      #text(size: 1.2em, weight: "bold")[Prof. #supervisor]

      #v(1.4em)

      // Insert Logo Object
      #if logo != none {
        logo
      }

      #v(1.4em)

      #text(weight: "bold")[DEPARTMENT OF #upper(department)]
      #v(0.5em)

      #text(weight: "bold")[#upper(institution)]
    ]
    v(1fr)
  }
  pagebreak()

  // ============================================
  // CERTIFICATE PAGE
  // ============================================
  set page(
    paper: "a4",
    margin: (
      left: 1.0in,
      right: 1.0in,
      top: 1.4in,
      bottom: 1.4in,
    ),
    numbering: "i",
    number-align: center,
  )
  counter(page).update(1)

  {
    set par(first-line-indent: 0em, spacing: 1.2em, justify: true)

    align(center)[
      #text(weight: "bold", size: 1em)[DEPARTMENT OF #upper(department)] \
      #text(weight: "bold", size: 1em)[#upper(institution)] \
      #text(weight: "bold", size: 1em)[#upper(location) - #pincode, INDIA]

      #v(1.5em)

      // Insert Logo Object
      #if logo != none {
        logo
      }

      #v(1.5em)

      #text(size: 1.3em, weight: "bold", style: "italic")[CERTIFICATE]
    ]

    v(1.5em)

    certificate-text

    v(1fr)

    grid(
      columns: (1fr, 2fr),
      column-gutter: 2em,
      align(left + top)[
        *Date:* #date \
        *Place:* #location
      ],
      align(right + top)[
        #emph[Prof. #supervisor] \
        Department of #department \
        #institution \
        #location - #pincode, India
      ],
    )
  }
  pagebreak()

  // ============================================
  // DECLARATION PAGE
  // ============================================
  {
    set par(first-line-indent: 0em, spacing: 1.2em)

    v(1.2cm)

    align(center)[
      #text(size: 1.3em, weight: "bold")[DECLARATION]
    ]

    v(2em)

    [I certify that]

    v(0.5em)

    set par(first-line-indent: 1.5em)

    declaration-text

    v(1fr)

    grid(
      columns: (1fr, 1fr),
      column-gutter: 2em,
      align(left)[
        *Date:* #date \
        *Place:* #location
      ],
      align(right)[
        (#author) \
        (#rollno)
      ],
    )
  }
  pagebreak()

  // ============================================
  // ACKNOWLEDGEMENTS
  // ============================================
  if acknowledgment != none {
    pagebreak(weak: true)
    {
      set text(size: 1.1em)
      set par(
        leading: 1.4em,
        first-line-indent: 1.5em,
        spacing: 1.6em,
      )

      v(1.2cm)
      align(center)[
        #text(size: 1.8em, style: "italic")[Acknowledgements]
      ]
      v(0.5cm)
      acknowledgment
    }
    pagebreak()
  }

  // ============================================
  // ABSTRACT
  // ============================================
  if abstract != none and abstract != [] {
    set text(size: 1.1em)
    set par(
      leading: 1.4em,
      first-line-indent: 1.5em,
      spacing: 1.6em,
    )

    pagebreak(weak: true)
    v(1.2cm)
    align(center)[
      #text(size: 1.8em, style: "italic")[Abstract]
    ]
    v(0.5cm)
    abstract
    pagebreak()
  }

  // ============================================
  // MAIN TEMPLATE WITH HEADERS
  // ============================================
  set page(
    margin: (
      inside: 1.25in,
      outside: 0.9in,
      top: 1.2in,
      bottom: 1.0in,
    ),
    binding: left,
    header: context {
      set text(9pt)
      let hdr = hydra(1, skip-starting: true)
      if hdr != none {
        block[
          #hdr
          #v(-0.4em)
          #line(length: 100%, stroke: 0.5pt)
        ]
      }
    },
    footer-descent: 1.5em,
    header-ascent: 1.5em,
  )

  set text(size: 1.1em)
  set par(
    leading: 1.4em,
    first-line-indent: 1.5em,
    spacing: 1.6em,
  )
  set heading(numbering: "1.1", supplement: [Chapter])

  // ============================================
  // HEADING STYLES
  // ============================================
  show heading: it => {
    if it.level != 1 {
      set text(1.1em, weight: "semibold")
      set par(first-line-indent: 0em)
      v(0.8em)
      [#numbering(it.numbering, ..counter(heading).at(it.location())) #h(0.5em)]
      it.body
      v(0.4em)
      set par(first-line-indent: 1.5em)
    }
  }

  show heading.where(level: 1): it => {
    set text(1.5em, weight: "medium")
    set par(first-line-indent: 0em)

    pagebreak(weak: true)
    block(height: 0.6cm)

    if it.numbering != none {
      [#it.supplement #numbering(it.numbering, counter(heading).get().at(0))]
      v(0.2cm)
    }
    it.body
    v(0.6cm)
  }

  // ============================================
  // FRONT MATTER SECTIONS
  // ============================================
  heading(level: 1, numbering: none, outlined: false)[Contents]

  show outline.entry.where(level: 1): it => {
    set block(above: 1.4em)
    strong(it)
  }
  set block(above: 1.0em)

  outline(title: none, depth: 3, indent: auto)

  if figures-outline {
    heading(level: 1, numbering: none)[List of Figures]
    outline(title: none, target: figure.where(kind: image))
  }

  if tables-outline {
    heading(level: 1, numbering: none)[List of Tables]
    outline(title: none, target: figure.where(kind: table))
  }

  if abbreviations.len() > 0 {
    heading(level: 1, numbering: none)[Abbreviations]
    v(0.8em)
    for (abbr, full) in abbreviations {
      grid(
        columns: (15%, 85%),
        abbr, full,
      )
      v(0.3em)
    }
  }

  // ============================================
  // MAIN CONTENT
  // ============================================
  set page(numbering: "1")
  counter(page).update(1)

  body
}
