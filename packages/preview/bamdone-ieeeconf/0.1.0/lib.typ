// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

// This function gets your whole document as its `body` and formats
// it as an article in the style of the IEEE.
#let ieee(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a `given` name,
  // `surname`, `email` prefix, and `affiliation` number. 
  authors: (
    (
      given: "Albert",
      surname: "Author",
      email: [albert.author],
      affiliation: 1
    ),
    (
      given: "Bernard D.",
      surname: "Researcher",
      email: [b.d.researcher],
      affiliation: 2
    )
  ),
  affiliations: (
    (
      name: [Faculty of Electrical Engineering, Mathematics and Computer Science, University of Twente],
      address: [7500 AE Enchede, The Netherlands],
      email-suffix: [papercept.net],
    ),
    (
      name: [Department of Electrical Engineering, Wright State University],
      address: [Dayton, OH 45435, USA],
      email-suffix: [ieee.org]
    )
  ),
  disclaimer: [This work was not supported by any organization.],
  
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  draft: false,
  
  // The paper's content.
  body
) = {
  // Set document metadata.
  set document(title: title, author: authors.map(author => author.surname))
 
  // Set the body font.
  set text(font: "TeX Gyre Termes", size: 10pt)

  // Enums numbering
  set enum(numbering: "1)a)i)")

  // Tables & figures
  set figure(placement: top)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set text(size: 8pt)
  show figure.caption.where(kind: table): smallcaps
  show figure.where(kind: table): set figure(numbering: "I")

  show figure.where(kind: image): set figure(supplement: [Fig.#h(0.2em)], numbering: "1")
  show figure.caption: cap => {
    // set align(left) //[cap]
    // cap
    align(left, cap)
  }
  set figure.caption(separator: [. #h(1em)])
  show figure.caption: set text(size: 8pt)
  show figure.caption: set par(justify: true, first-line-indent: 0em)
  
  

  // Code blocks
  show raw: set text(font: "TeX Gyre Cursor", size: 1em / 0.8)

  // Configure the page.
  set page(
    paper: paper-size,
    numbering:
      if draft {
      (..it) => strong(text(red, [DRAFT, #numbering("1 / 1", it.at(0)) of #numbering("1 / 1", it.at(1))]))
    } else {none},
    header: if draft {
      align(center, strong(text(red, "DRAFT")))
    },
    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      (
        left: 0.75in,
        right: 0.76in,
        top: 0.75in,
        bottom: 0.78in,
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
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "I.A.a)")
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
      let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements],[Appendix])
      set align(center)
      set text(if is-ack { 10pt } else { 11pt })
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      // show: smallcaps
      show: upper
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
        numbering("a)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  }


  
  
  // Style bibliography made up by Isaac
  show std-bibliography: set block(spacing: 0.65em)
  show std-bibliography: set par(leading: 0.5em)
  // Style bibliography as designed
  show std-bibliography: set text(8pt)
  set std-bibliography(title: text(8pt)[References], style: "ieee")

  // Display the paper's title.
  v(0.25in)
  align(center, text(16pt, strong(title)))
  v(8.35mm, weak: true)

  // Display the authors list.
  let author-name-affil =  authors.map(author => [#author.given #author.surname#super[#author.affiliation]]).join(", ", last: ", and ")

  align(center)[#text(11pt)[#author-name-affil]]
  
  v(40pt, weak: true)

  // Start two column mode and configure paragraph properties.
  show: columns.with(2, gutter: 12pt)
  set par(justify: true, first-line-indent: 1em, spacing: 0.65em)
  
  // Display abstract and index terms.
  if abstract != none [
    #set text(9pt, weight: 700)
    #h(1em) _Abstract_---#h(weak: true, 0pt)#abstract

    #if index-terms != () [
      #h(1em)_Index terms_---#h(weak: true, 0pt)#index-terms.join(", ")
    ]
    #v(2pt)
  ]

  figure(placement: bottom, align(left)[
    #block(width: 100%, height: auto, stroke: none)[#text(8.5pt)[
      #h(1em) #disclaimer
    
      #for i in range(affiliations.len()) {
        let affiliation = affiliations.at(i)
        let authors-for-this-affiliation = authors.filter(author => author.affiliation - 1 == i)
        let multi-author = authors-for-this-affiliation.len() > 1
        let author-surname = [#authors-for-this-affiliation.map(author => author.surname).join(", ")]
        let joiner = if multi-author [are] else [is]
        let author-email-prefix = [#authors-for-this-affiliation.map(author => author.email).join(", ")]

        [#super[#{i + 1}]#author-surname #joiner with #affiliation.name, #affiliation.address, #text(weight: 100, font:"New Computer Modern Mono")[#if multi-author [{]#author-email-prefix#if multi-author [}]\@#affiliation.email-suffix.   #parbreak()]]
      }

    // #footnote(par()[#v(-1.5em)0018-9251 © 2020 IEEE], numbering: it => "",)
    ]]  
  ])
  
  // Display the paper's contents.
  body

  // Display bibliography.
  bibliography
}