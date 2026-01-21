//***************************************************************
// AIAA TYPST TEMPLATE
// 
// The author of this work hereby waives all claim of copyright
// (economic and moral) in this work and immediately places it 
// in the public domain; it may be used, distorted or 
// in any manner whatsoever without further attribution or notice
// to the creator. The author is not responsible for any liability 
// from the usage or dissemination of this code.
//
// Author: Isaac Weintraub, Alexander Von Moll
// Date: 06 NOV 2023
// BAMDONE!
//***************************************************************

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

// This function gets your whole document as its `body` and formats
// it as an article in the style of the AIAA.
#let aiaa(
  // The paper's title.
  title: (),

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors-and-affiliations: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // The paper's content.
  body,
) = {




  // Set document metdata.
  set document(
    title: title, 
    author: authors-and-affiliations.filter(a => "name" in a).map(a => a.name)
  )

  // Set the body font.
  set text(
    font: "Times New Roman",
    top-edge: 5pt,
  )


  // Configure the page.
  set page(
    paper: paper-size,

    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      ( 
        x: (72pt / 216mm) * 100%,
        top: (72pt / 279mm) * 100%,
        bottom: (72pt / 279mm) * 100%,
      )
    }
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)", supplement: [Eq.])
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      link(
        el.label,
        [#el.supplement #numbering(
          el.numbering,
          ..counter(eq).at(el.location())
        )]
      )
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  
  // Configure headings.
  set heading(
    numbering: "I.A.1."
    )
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }
 
    set text(11pt, weight: "bold", font: "Times New Roman")
    
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
      #v(1.65em, weak: true)
      #set align(center)
      #set text(size: 11pt, weight: "bold", font: "Times New Roman")
      // #show: smallcaps
      
      // #v(20pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering("I.", deepest)
        // h(7pt, weak: true)
      }
      #it.body
      #v(0.65em, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #v(1.65em, weak: true)
      #set par(first-line-indent: 0pt)
      // #v(16pt, weak: true)
      #set text(weight: "bold", size: 10pt)
      // #v(11pt, weak: true)
      #if it.numbering != none {
        numbering("A.", deepest)
        h(7pt, weak: true)
      }
      #it.body

    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering( "1)" , deepest)
        [ ]
      }
      _#(it.body):_
    ]
  })

  // Display the paper's title.
  v(3pt, weak: true)
  align(center, text(weight: "bold", 24pt, font: "Times New Roman", title))
  v(8.35mm, weak: true)

  // Display the authors and affiliations list.
  {
    set align(center)
    for author-or-affil in authors-and-affiliations {
      // entry is an author
      if "name" in author-or-affil {
        set text(16pt, top-edge:16pt)
        let author-footer = {
          if "job" in author-or-affil [#author-or-affil.job]
          if "department" in author-or-affil [, #author-or-affil.department]
          if "aiaa" in author-or-affil [, #author-or-affil.aiaa]
          [.]
        }
        [#author-or-affil.name #footnote[#author-footer] ]
      // the entry is an affiliation
      } else {  
          set text(12pt, top-edge: 10pt, style:"italic")
          [\ #author-or-affil.institution]
          if "city" in author-or-affil [, #author-or-affil.city]
          if "state" in author-or-affil [, #author-or-affil.state]
          if "zip" in author-or-affil [, #author-or-affil.zip]
          if "country" in author-or-affil [, #author-or-affil.country]
          [\ ]
      }
    }
  }
  
  // Configure Figures
  show figure.caption: strong
  set figure.caption(separator:"   ")
  set figure(numbering: "1", supplement: [Fig.])

  // Configure Tables
  show figure.where(kind: table): {
    set figure.caption(position: top)
    set figure(supplement: [Table])
  }

  // Configure paragraph properties.
  show: columns.with(1, gutter: 0pt)
  set par(justify: true, first-line-indent: 1.5em)
  show par: set block(spacing: 0.65em)

  // Display abstract and index terms.
  if abstract != none [
    #text(10pt, weight: "bold",
      table(
        stroke: none,
        align: left,
        gutter: 0pt,
        columns: (36pt, auto, 36pt),
        [],[ #h(1.5em) #abstract], []
      )
    )
  ]

  // Display the paper's contents.
  body

  // Display bibliography.
  if bibliography != none {
    show std-bibliography: set text(8pt)
    set std-bibliography(title: text(10pt)[References], style: "american-institute-of-aeronautics-and-astronautics")
    bibliography
  }

}

#let b-equation = it => { 
    [#set math.equation(numbering: "(1)", supplement: "Equation")
      #show math.equation: set block(spacing: 0.65em)
      // Configure appearance of equation references
      #show ref: it => {
        let eq = math.equation
        let el = it.element
        if el != none and el.func() == eq {
          // Override equation references.
          link(
            el.label,
            [Equation #numbering(
            el.numbering,
            ..counter(eq).at(el.location())
          )]
        )
      } else {
      // Other references as usual.
      it
    }
  }
#it ]
}

#let nomenclature(..quantities) = {
  let q = quantities.pos()
  [= Nomenclature

  #table(
    stroke: none,
    row-gutter: -3pt,
    columns: (auto, auto, auto),
    align: left,
    ..q.map(
      ((k,v)) => ([#k], [$=$], v)
    ).flatten()
  )
  ] 
}

  