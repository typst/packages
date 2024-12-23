// This function gets your whole document as its `body` and formats
// it as an article in the style of the IEEE.
#let ieee(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),
  // CHANGE:
  // example (single or multiple authors):
  //   authors: (
  //   (
  //     name: "Name Surname",
  //     department: [Faculty XYZ],
  //     organization: [University of XYZ],
  //     location: [City, Country],
  //     email: "mail@example.com"
  //   ),
  //   (
  //     name: "Name Surname",
  //     department: [Faculty XYZ],
  //     organization: [University of XYZ],
  //     location: [City, Country],
  //     email: "mail@example.com"
  //   ),
  // ),

  // The paper's abstract. Can be omitted if you don't have one.
  // abstract: [This is an abstract.],
  abstract: none,
  // CHANGE: 
  // Abstract -> Abstrakt
  // default     ^
  // else use false -> english
  // or custom string [Abstrakt]
  abstract-name-slovak: true,

  // A list of index terms to display after the abstract.
  // index-terms: ["example_term1", "example_term2", "example_term3"],
  index-terms: (),
  // CHANGE:
  // Index Terms -> Kľúčové slová
  // default        ^
  // else use false -> english
  // or custom string [Index]
  index-terms-name-slovak: true,

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,
  // CHANGE:
  // use [Literatúra] / [Referencie]
  bib-name: [Literatúra],

  // How figures are referred to from within the text.
  // Use "Figure" instead of "Fig." for computer-related publications.
  // ORIGINALLY: 
  // figure-supplement: [Fig.],

  // CHANGE: 
  // Fig. -> Obr.
  // TABLE -> Tabuľka
  // Section -> Sekcia
  // 
  // When figure is shown, the string in caption to display is "Hardcoded"
  // meaning that you need to change the source of the template.
  // This supplement is used for references in the text.
  figure-reference-supplement: [Obr.],
  table-reference-supplement: [Tabuľka],
  section-reference-supplement: [Sekcia],

  // CHANGE:
  // For acknowledgments (Poďakovanie), just use 1st level heading with the said string
  // CHANGE:
  // underline_links == 3 --> underline all links
  // underline_links == 2 --> underline all links except for email of the authors
  // underline_links == 1 --> underline all links except for email of the authors and abstract / index terms
  // underline_links == 0 --> underline no links
  // default: 2
  underline_links: 2,

  // The paper's content.
  body
) = {
  // CHANGE:
    show link: it => {
    if underline_links == 3 {
      underline[#it]
    } else {
      it
    }
  }

  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  // Set the body font.
  // As of 2024-08, the IEEE LaTeX template uses wider interword spacing
  // - See e.g. the definition \def\@IEEEinterspaceratioM{0.35} in IEEEtran.cls
  set text(font: "TeX Gyre Termes", size: 10pt, spacing: .35em)

  // Enums numbering
  set enum(numbering: "1)a)i)")

  // Tables & figures
  show figure: set block(spacing: 15.5pt)
  show figure: set place(clearance: 15.5pt)

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set text(size: 8pt)
  // ORIGINALLY:
  // show figure.where(kind: table): set figure(numbering: "I")
  // show figure.where(kind: image): set figure(supplement: figure-supplement, numbering: "1")
  // CHANGE:
  show figure.where(kind: table): set figure(supplement: table-reference-supplement, numbering: "I")
  show figure.where(kind: image): set figure(supplement: figure-reference-supplement, numbering: "1")

  show figure.caption: set text(size: 8pt)
  show figure.caption: set align(start)
  show figure.caption.where(kind: table): set align(center)
  // CHANGE:
  show figure.caption.where(kind: image): set align(center)
  
  // Adapt supplement in caption independently from supplement used for
  // references.
  show figure: fig => {
    let prefix = (
      // ORIGINALLY:
      // if fig.kind == table [TABLE]
      // else if fig.kind == image [Fig.]
      // else [#fig.supplement]
      // CHANGE:
      if fig.kind == table [Tabuľka]
      else if fig.kind == image [Obr.]
      else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    show figure.caption: it => [#prefix~#numbers: #it.body]
    show figure.caption.where(kind: table): smallcaps
    fig
  }

  // Code blocks
  show raw: set text(
    font: "TeX Gyre Cursor",
    ligatures: false,
    size: 1em / 0.8,
    spacing: 100%,
  )

  // Configure the page and multi-column properties.
  set columns(gutter: 12pt)
  set page(
    columns: 2,
    paper: paper-size,
    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      (
        x: (50pt / 216mm) * 100%,
        top: (55pt / 279mm) * 100%,
        bottom: (64pt / 279mm) * 100%,
      )
    }
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  // ORIGINALLY:
  // set list(indent: 10pt, body-indent: 9pt)
  // CHANGE:
  // set marker for lists from LaTeX IEEE template
  set list(indent: 10pt, body-indent: 9pt, marker: ([•], [–], [∗]))

  // Configure headings.
  // ORIGINALLY:
  // set heading(numbering: "I.A.a)")
  // CHANGE:
  // set heading numbering from LaTeX IEEE template
  // ORIGINALLY:
  // set heading(numbering: "I.A.1)")
  // CHANGE:
  set heading(numbering: "I.A.1)", supplement: section-reference-supplement)
  
  show heading: it => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).get()
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(10pt, weight: 400)
    if it.level == 1 {
      // First-level headings are centered smallcaps.
      // We don't want to number the acknowledgment section.
      // ORIGINALLY:
      // let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements])
      // CHANGE:
      // also without diacritics
      let is-ack = it.body in ([Poďakovanie], [Poďakovania], [Podakovanie], [Podakovania])

      set align(center)
      set text(if is-ack { 10pt } else { 11pt })
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      show: smallcaps
      if it.numbering != none and not is-ack {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      it.body
    } else if it.level == 2 {
      // Second-level headings are run-ins.
      set par(first-line-indent: 0pt)
      set text(style: "italic")
      show: block.with(spacing: 10pt, sticky: true)
      if it.numbering != none {
        numbering("A.", deepest)
        h(7pt, weak: true)
      }
      it.body
    } else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        // ORIGINALLY:
        // numbering("a)", deepest)
        // CHANGE:
        numbering("1)", deepest)

        [ ]
      }
      _#(it.body):_
    ]
  }

  // Style bibliography.
  show std.bibliography: set text(8pt)
  show std.bibliography: set block(spacing: 0.5em)
  // ORIGINALLY:
  // set std.bibliography(title: text(10pt)[References], style: "ieee")
  // CHANGE:
  set std.bibliography(title: text(10pt)[#bib-name], style: "ieee")

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  place(
    top,
    float: true,
    scope: "parent",
    clearance: 30pt,
    {
      v(3pt, weak: true)
      align(center, par(leading: 0.5em, text(size: 24pt, title)))
      v(8.35mm, weak: true)

      // Display the authors list.
      set par(leading: 0.6em)
      for i in range(calc.ceil(authors.len() / 3)) {
        let end = calc.min((i + 1) * 3, authors.len())
        let is-last = authors.len() == end
        let slice = authors.slice(i * 3, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: 12pt,
          ..slice.map(author => align(center, {
            text(size: 11pt, author.name)
            if "department" in author [
              \ #emph(author.department)
            ]
            if "organization" in author [
              \ #emph(author.organization)
            ]
            if "location" in author [
              \ #author.location
            ]
            if "email" in author {
              if type(author.email) == str [
                \ #link("mailto:" + author.email)
              ] else [
                \ #author.email
              ]
            }
          }))
        )

        if not is-last {
          v(16pt, weak: true)
        }
      }
    }
  )

  // Configure paragraph properties.
  set par(spacing: 0.45em, justify: true, first-line-indent: 1em, leading: 0.45em)

  // CHANGE:
  show link: it => {
    if underline_links == 2 {
      underline[#it]
    } else {
      it
    }
  }

  // Display abstract and index terms.
  if abstract != none [
    #set text(9pt, weight: 700, spacing: 150%)
    // ORIGINALLY:
    // #h(1em) _Abstract_---#h(weak: true, 0pt)#abstract
    // CHANGE:
    // #emph[text] == italic same as using _text_
    #if abstract-name-slovak == true [
      #h(1em) _Abstrakt_---#h(weak: true, 0pt)#abstract
    ] else if abstract-name-slovak == false [
      #h(1em) _Abstract_---#h(weak: true, 0pt)#abstract
    ] else [
      #h(1em) #emph[#abstract-name-slovak]---#h(weak: true, 0pt)#abstract
    ]

    #if index-terms != () [
      // ORIGINALLY:
      // #h(.3em)_Index Terms_---#h(weak: true, 0pt)#index-terms.join(", ")
      // CHANGE:
      // #emph[text] == italic same as using _text_
      #if index-terms-name-slovak == true [
        #h(.3em)_Kľúčové slová_---#h(weak: true, 0pt)#index-terms.join(", ")
      ] else if index-terms-name-slovak == false [
        #h(.3em)_Index Terms_---#h(weak: true, 0pt)#index-terms.join(", ")
      ] else [
        #h(.3em)#emph[#index-terms-name-slovak]---#h(weak: true, 0pt)#index-terms.join(", ")
      ]
    ]
    #v(2pt)
  ]

  // CHANGE:
    show link: it => {
    if underline_links == 1 {
      underline[#it]
    } else {
      it
    }
  }

  // Display the paper's contents.
  set par(leading: 0.5em)
  body

  // Display bibliography.
  bibliography
}