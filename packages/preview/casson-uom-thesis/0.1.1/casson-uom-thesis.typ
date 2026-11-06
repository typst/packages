// Alex Casson
//
// Aim
// Typst template in-line with the University of Manchester presentation of theses policy
//
// Versions
// 04.05.25 - v2 - added fixes for Typst 0.13 compatability. outline command changed, and some header spacing changed.
// 30.12.24 - v1 - initial version. Fundamentally complete, but with a number of non-ideal and/or to-do items. Lots of items are hard coded.
//
// TODO
// Space under Contents heading is too small, not like others
// URL style
// Indent on quotes
// Fix table bottom row
// Equation no. in text in wrong mode
// Remove table/fig from LOT/LOF?
// Add support for short captions for LOT/LOF
// Improve code display
// Add backref if feasible
// Check on heading spacings
// Page breaks before headers automatically
// Add terms list for terms and abbreviations
// Add ability to overrule declaration of originality
// Find nicer way to enter abstract etc
// Add in subfigure example
// Add XMP copyright when can
// Look into heading spacing after the heading. There are a number of manual fixes in the below



// ------ ADD PACKAGES --------------------------------------------------
#import "@preview/wordometer:0.1.4": word-count, total-words



// ------ DEFINE ARGUMENTS ----------------------------------------------
#let uom-thesis(
  title: "",
  abstract: [],
  publications: none,
  termsandabbreviations: none,
  layabstract: none,
  acknowledgements: none,
  theauthor: none,
  author: "",
  faculty: none,
  year: none,
  school: none,
  departmentordivision: none,
  font: "TeX Gyre Termes",
  fontsize: 12pt,
  body,
) = {
  

  
// ------ SETUP DOCUMENT ------------------------------------------------
  
  // Document meta-data
  state("maincontent").update(true)
  set document(author: author, title: title)

  // Page size and numbering
  set page(
    paper: "a4",
    margin: (left: 40mm, right: 25mm, top: 15mm, bottom: 15mm),
    number-align: end,
  )

  // Fonts
  // Note the guidelines say "a font type and size which ensures readability must be used ... in a font such as Arial, Verdana, Tahoma,Trebuchet, Calibri, Times, Times New Roman, Palatino or Garamond". Only Times and Palatino are built in to Typst online. Roboto and Noto sans are added as options here which should satisfy this
  let roboto = "Roboto"
  let times = "TeX Gyre Termes"
  let palatino = "TeX Gyre Pagella"
  let noto_sans = "Noto Sans"
  let font_actual = times
  if font == "roboto" {
    font_actual = roboto
  } else if font == "palatino" {
    font_actual = palatino
  } else if font == "noto_sans" {
    font_actual = noto_sans
  }
  
  // Basic formatting
  set text(
    font: font_actual, 
    size: fontsize,
    lang: "en", // doesn't support en-GB yet
  )
  set heading(numbering: "1.1")
  set par(leading: 1.2em) // line spacing
  set par(spacing: 2em) // space between paragraphs

  
  
// ------ HEADING STYLES ------------------------------------------------

  // Level 1 for Chapters
  show heading.where(level: 1): it => {
    v(2*2.26em)
    set align(left)
    set text(2.26em, weight: "bold")
    if it.numbering != none {
      text("Chapter " + counter(heading).display("1") + "\n" + it.body)
      v(-0.5em)
    } else {
      text(it.body)
      v(1em)
    }
    //v(1em)
  }
  show heading.where(level: 1): set heading(supplement: [Chapter])

  // Level 2 for Sections
  show heading.where(level: 2): it => {
    v(1.3em)
    set align(left)
    set text(1.3em, weight: "bold")
    if it.numbering != none {
      text(counter(heading).display("1.1") + " " + it.body)
    } else {
      text(it.body)
    }    
    //v(0.77em)
  }

  // Level 3 for Sub-sections
  show heading.where(level: 3): it => {
    v(1.1em)
    set align(left)
    set text(1.1em, weight: "bold")
    text(counter(heading).display("1.1") + " " + it.body)
  }

  // Not numbered below level 3
  show heading.where(level: 4): it =>[
    #block(it.body)
  ]
  show heading.where(level: 5): it =>[
    #parbreak()
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 6): it =>[
    #text(style: "italic", weight: "bold", it.body)
  ]



// ------ FIGURES, TABLES, AND EQUATIONS --------------------------------

  // Reset counters each chapter to allow Ch.Sect type references
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }
  
  // All display item formatting
  show figure.caption: set text(size: 0.9em)
  show figure.caption: set align(center)
  
  // Table captions
  // Only the top line of a table is added at the moment. Should do under the header and the last line of the table to be in IEEE style
  show figure.where(kind: table): set figure.caption(position: top)  
  set table(stroke: (_, y) => if y == 0 { 
    (top: 1.5pt) // should do bottom too 
  } else if y == 0 { // doesn't work atm
    (bottom: 1.5pt) 
  })

  // Figure captions
  let figure-supplement = [Fig.]
  show figure: set block(spacing: 2em)
  show figure: set place(clearance: 1em)
  show figure.where(kind: image): set figure(supplement: figure-supplement)
  set figure(numbering: num =>
    numbering("1.1", counter(heading).get().first(), num)
  )

  // Set both the caption and references to use the custom settings
  show figure: fig => {
    let prefix = (
      if fig.kind == table [Table]
      else if fig.kind == image [#figure-supplement]
      else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    show figure.caption: it => [#text(prefix + " " +  numbers + ".", weight: "bold") #it.body]
    fig
  }

  // Equation numbering
  set math.equation(supplement: none)
  set math.equation(numbering: num =>
    numbering("(1.1)", counter(heading).get().first(), num)
  )


  
// ------ QUOTE FORMATTING ----------------------------------------------

  show quote.where(block: false): it => {
    ["] + h(0pt, weak: true) + emph(it.body) + h(0pt, weak: true) + ["]
    if it.attribution != none [ #it.attribution]
  }
  show quote.where(block: true): it => {
    set pad(x: 10em)  
    ["] + h(0pt, weak: true) + emph(it.body) + h(0pt, weak: true) + ["]
    if it.attribution != none [ #it.attribution]
  }


// ------ START OF DISPLAYED ITEMS --------------------------------------



// ------ TTILE PAGE ----------------------------------------------------

  place(dx: -40mm+14.279mm, dy:-15mm+14.279mm,
    image("uom_logo.svg", width: 40.006mm)
  )
  v(2fr)
  set align(center)
  text(1.44em, weight: "bold", title)
  v(1fr)
  text(1em, "A thesis submitted to the University of Manchester for the degree of \n Doctor of Philosophy \n in the Faculty of ")
  text(1em, faculty)
  v(1fr)
  text(1em, year)
  v(1fr)  
  text(1em, author)
  v(1em, weak: true)
  text(1em, school)
  v(1em, weak: true)
  text(1em, departmentordivision)
  v(1fr)
  set align(left)
  pagebreak()
  set page(numbering: "1")


  
// ------ LISTS OF CONTENTS ---------------------------------------------

  // Set contents formatting
  show outline.entry.where(level: 1): it => {
    if it.element.func() != heading {
      it
    }
    else {
      show repeat: none
      v(1.2em, weak: true)
      strong(it)
    }
  }

  // Contents
  show outline: set heading(outlined: true, numbering: none, level: 1)
  // outline(depth: 3, indent: true)
  outline(depth: 3, indent: auto)

  // Add word count
  show: word-count
  align(right, block[
    #text("Word count: ",  weight: "bold")
    #text(total-words)
  ])

  // List of figures
  pagebreak()
  outline(
    depth: 3, indent: auto,
    title: [List of figures],
    target: figure.where(kind: image),
  )

  // List of tables
  pagebreak()
  outline(
    depth: 3, indent: auto,
    title: [List of tables],
    target: figure.where(kind: table),
  )

  // List of publications
  if publications != none {
    pagebreak()
    heading(outlined: true, numbering: none, level: 1, [List of publications])
    v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
    text(1em, publications)
  }

  // Terms and abbreviations
  if termsandabbreviations != none {
    pagebreak()
    heading(outlined: true, numbering: none, level: 1, [Terms and abbreviations])
    v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
    text(1em, termsandabbreviations)
  }
   
  // Abstract
  pagebreak()
  heading(outlined: true, numbering: none, level: 1, [Abstract])
  v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
  abstract

  if layabstract != none {
    pagebreak()
    heading(outlined: true, numbering: none, level: 1,[Lay abstract])
    v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
    layabstract
  }
  
  // Declaration of originality
  pagebreak()
  heading(outlined: true, numbering: none, level: 1,[Declaration of originality])
  v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
  "I hereby confirm that no portion of the work referred to in the thesis has been submitted in support of an application for another degree or qualification of this or any other university or other institute of learning."
  
  // Copyright statement
  pagebreak()
  heading(outlined: true, numbering: none, level: 1,[Copyright statement])
  v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
  set enum(numbering: "i.")
  enum[The author of this thesis (including any appendices and/or schedules to this thesis) owns certain copyright or related rights in it (the "Copyright") and s/he has given The University of Manchester certain rights to use such Copyright, including for administrative purposes.][Copies of this thesis, either in full or in extracts and whether in hard or electronic copy, may be made _only_ in accordance with the Copyright, Designs and Patents Act 1988 (as amended) and regulations issued under it or, where appropriate, in accordance with licensing agreements which the University has from time to time. This page must form part of any such copies made.][The ownership of certain Copyright, patents, designs, trademarks and other intellectual property (the "Intellectual Property") and any reproductions of copyright works in the thesis, for example graphs and tables ("Reproductions"), which may be described in this thesis, may not be owned by the author and may be owned by third parties. Such Intellectual Property and Reproductions cannot and must not be made available for use without the prior written permission of the owner(s) of the relevant Intellectual Property and/or Reproductions.][Further information on the conditions under which disclosure, publication and commercialisation of this thesis, the Copyright and any Intellectual Property and/or Reproductions described in it may take place is available in the University IP Policy (see #link("http://documents.manchester.ac.uk/DocuInfo.aspx?DocID=24420")), in any relevant Thesis restriction declarations deposited in the University Library, The University Library’s regulations (see #link("http://www.library.manchester.ac.uk/about/regulations/")) and in The University’s policy on Presentation of Theses.]
  pagebreak()

  if acknowledgements != none {
    heading(outlined: true, numbering: none, level: 1,[Acknowledgements])
    v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
    acknowledgements
    pagebreak()
  }

  if theauthor != none {
    heading(outlined: true, numbering: none, level: 1,[The author])
    v(-5em) // added for Typst 0.13. Somewhat hacky. Not clear why spacing doesn't come from the heading correct without this. Will look at at some point
    theauthor
    pagebreak()
  }


  
// ------ MAIN BODY ---------------------------------------------

  set text(hyphenate: true)
  body
}



// ------ APPENDIX FORMATTING -------------------------------------------

#let uom-appendix(body) = {
  state("appendix").update(true)

  // Change figure numbering to use a letter
  set figure(numbering: it => {
    let alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let hdr = counter(heading).get().at(0)
    [#alph.at(hdr - 1).#it]
  })

  // Reset counters for the per-chapter references
  show heading.where(level: 1): hdr => {
    counter(figure.where(kind:image)).update(0)
    counter(figure.where(kind:table)).update(0)
    hdr
  }

  // Set headings to use Appendix letters
  // This can probably be tidied up, is largely a copy of what is above
  set heading(numbering: "A.1", supplement: [Appendix])
  counter(heading).update(0)
  state("appendix").update(true)

  show heading.where(level: 1): it => {
    v(2*2.26em)
    set align(left)
    set text(2.26em, weight: "bold")
    if it.numbering != none {
      text("Appendix " + counter(heading).display("A") + "\n" + it.body)
    } else {
      text(it.body)
    }  
    v(0.22em)
  }
    show heading.where(level: 2): it => {
    v(1.3em)
    set align(left)
    set text(1.3em, weight: "bold")
    if it.numbering != none {
      text(counter(heading).display("A.1") + " " + it.body)
    } else {
      text(it.body)
    }    
    v(0.77em)
  }

  show heading.where(level: 3): it => {
    v(1.1em)
    set align(left)
    set text(1.1em, weight: "bold")
    text(counter(heading).display("A.1") + " " + it.body)
    v(0.9em)
  }

  // Add appendicies heading and then add the content
  heading(outlined: true, numbering: none, level: 1,[Appendices])
  pagebreak()
  body
}