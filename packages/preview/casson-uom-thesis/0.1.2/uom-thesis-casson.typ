// Alex Casson
//
// Aim
// Typst template in-line with the University of Manchester presentation of theses policy
//
// Versions
// 03.10.26 - v3 - accessibility fixes so the PDF passes Typst's PDF/UA-1 check (Typst 0.14 and later): the contents entries are styled with set rules so they stay valid outline entries, and the logo has alt text.
//                 Also fixes for figures with no number, appendix numbering, labelled footnotes, and the word count, which now counts the main text only and sits at the bottom of the contents page. Chapters start on a new page, block quotes are indented, sub-figures are supported through uom-subfigures, and the language is British English.
//                 Updated for version 12 of the Presentation of Theses Policy (March 2026): The University on the title page, a degree option, the COVID-19 impact statement, both forms of the declaration, the copyright wording, and pages for the list of thesis revisions, AI declaration and content notification.
//                 Drafting tools: draft mode with DRAFT across each page, uom-todo and uom-missing-figure, and a check that none are left outside draft mode. Short captions for the lists of figures and tables (uom-flex-caption).
//                 Report types: theses, MSc by Research dissertations and taught dissertations, each worded as in its own University document (uom-reports).
// 04.05.25 - v2 - added fixes for Typst 0.13 compatability. outline command changed, and some header spacing changed.
// 30.12.24 - v1 - initial version. Fundamentally complete, but with a number of non-ideal and/or to-do items. Lots of items are hard coded.
//
// TODO
// Space under Contents heading is too small, not like others
// URL style
// Fix table bottom row
// Equation no. in text in wrong mode
// Remove table/fig from LOT/LOF?
// Improve code display
// Add backref if feasible
// Check on heading spacings
// Add terms list for terms and abbreviations
// Find nicer way to enter abstract etc
// Add XMP copyright when can
// Look into heading spacing after the heading. There are a number of manual fixes in the below
// Allow use of subpar directly for subfigures rather than needing a custom command


// ------ VARIABLES -------------------------------------------------------
#let uom-figure-supplement = [Fig.]
#let uom-table-supplement = [Table]
#let uom-caption-size = 0.9em

#let uom-title-size = 1.44em
#let uom-l1-header-size = 2.26em
#let uom-l1-header-space-front = 0.5 
#let uom-l1-header-space = 2
#let uom-l2-header-size = 1.3em
#let uom-l3-header-size = 1.1em

// These sizes assume A4 paper
#let uom-logo-pad = 14.279mm
#let uom-logo-width = 40.006mm

#let uom-margin-left = 20mm
#let uom-margin-left-print = 40mm
#let uom-margin-right = 20mm
#let uom-margin-top = 20mm
#let uom-margin-bottom = 20mm



// ------ ADD PACKAGES --------------------------------------------------
#import "@preview/wordometer:0.1.6": word-count, total-words
#import "@preview/subpar:0.2.2"



// ------ SHORT CAPTIONS ------------------------------------------------

// A caption with a short form for the lists of figures and tables, like
// \caption[short]{long} in LaTeX:
//   caption: uom-flex-caption([Short version for list of figures], [The full caption under the figure.])
// The word count can't see inside a context block, so it gets a copy of the
// long caption that is never shown.
#let uom-in-outline = state("uom-in-outline", false)
#let uom-flex-caption(short, long) = [#block(long)<uom-count-only>#context if uom-in-outline.get() { short } else { long }]



// ------ DRAFTING TOOLS ------------------------------------------------

// Notes and placeholders for while the thesis is being written. They are
// allowed in draft mode, uom-thesis(draft: true), which also puts DRAFT across
// every page and a list of what is left at the end. Outside draft mode they
// stop the build, so none are left in the version that is handed in.

// Something still to do, shown in red, e.g: #uom-todo[Check this value]
// It is only noted for the list once, not again where a heading or caption is
// repeated in the contents or the list of figures.
#let uom-todo(body) = [#context if not uom-in-outline.get() [#metadata(body)<uom-todo>]#text(fill: rgb("#c00000"), weight: "bold")[To do: #body]]

// A placeholder for a figure that hasn't been made yet. It is numbered and
// listed like any other figure, so references to it work.
#let uom-missing-figure(caption) = figure(
  rect(width: 60%, height: 4cm, stroke: (paint: luma(40%), dash: "dashed"), {
    [#metadata(caption)<uom-missing-figure>]
    align(center + horizon, text(fill: luma(40%))[Missing figure])
  }),
  alt: "Placeholder for a figure that is still to be made",
  caption: caption,
)



// ------ REPORT TYPES --------------------------------------------------

// The wording that changes with the kind of report, picked with the report
// option of uom-thesis. Each follows its own University document:
//   thesis: PhD, MPhil, MD, EngD and the other doctorates. https://documents.manchester.ac.uk/display.aspx?DocID=7420
//   research-dissertation: MSc by Research. https://documents.manchester.ac.uk/display.aspx?DocID=7441
//   taught-dissertation: undergraduate and taught masters dissertations, such
//     as BEng and MEng project reports and MSc dissertations. https://documents.manchester.ac.uk/display.aspx?DocID=2863
#let uom-reports = (
  thesis: (
    statement: "A thesis submitted to The University of Manchester for the degree of",
    degree: "Doctor of Philosophy",
    declaration: "I hereby confirm that no portion of the work referred to in the thesis has been submitted in support of an application for another degree or qualification of this or any other university or other institute of learning.",
    rights-title: [Copyright statement],
    rights: (
      [The author of this thesis (including any appendices and/or schedules to this thesis) owns certain copyright or related rights in it (the "Copyright") and they have given the University of Manchester certain rights to use such Copyright, including for administrative purposes.],
      [Copies of this thesis, either in full or in extracts and whether in hard or electronic copy, may be made only in accordance with the Copyright, Designs and Patents Act 1988 (as amended) and regulations issued under it or, where appropriate, in accordance with licensing agreements which the University has from time to time. This page must form part of any such copies made.],
      [The ownership of certain Copyright, patents, designs, trademarks and other intellectual property (the "Intellectual Property") and any reproductions of copyright works in the thesis, for example graphs and tables ("Reproductions"), which may be described in this thesis, may not be owned by the author and may be owned by third parties. Such Intellectual Property and Reproductions cannot and must not be made available for use without the prior written permission of the owner(s) of the relevant Intellectual Property and/or Reproductions.],
      [Further information on the conditions under which disclosure, publication and commercialisation of this thesis, the Copyright and any Intellectual Property and/or Reproductions described in it may take place is available in the #link("https://documents.manchester.ac.uk/DocuInfo.aspx?DocID=24420")[University IP Policy], in any relevant Thesis restriction declarations deposited in the University Library, the #link("https://www.library.manchester.ac.uk/about/regulations/")[University Library's regulations] and in the University's policy on the Presentation of Theses.],
    ),
    revisions-title: [List of thesis revisions],
  ),
  continuation-report: (
    statement: "Nine month progress report",
    degree: none,
    declaration: none,
    rights-title: none,
    rights: none,
    revisions-title: none,
  ),
  research-dissertation: (
    statement: "A dissertation submitted to The University of Manchester for the degree of",
    degree: "Master of Science by Research",
    declaration: "I hereby confirm that no portion of the work referred to in the dissertation has been submitted in support of an application for another degree or qualification of this or any other university or other institute of learning.",
    rights-title: [Copyright statement],
    rights: (
      [The author of this dissertation (including any appendices and/or schedules to this dissertation) owns certain copyright or related rights in it (the "Copyright") and they have given the University of Manchester certain rights to use such Copyright, including for administrative purposes.],
      [Copies of this dissertation, either in full or in extracts and whether in hard or electronic copy, may be made only in accordance with the Copyright, Designs and Patents Act 1988 (as amended) and regulations issued under it or, where appropriate, in accordance with licensing agreements which the University has from time to time. This page must form part of any such copies made.],
      [The ownership of certain Copyright, patents, designs, trademarks and other intellectual property (the "Intellectual Property") and any reproductions of copyright works in the dissertation, for example graphs and tables ("Reproductions"), which may be described in this dissertation, may not be owned by the author and may be owned by third parties. Such Intellectual Property and Reproductions cannot and must not be made available for use without the prior written permission of the owner(s) of the relevant Intellectual Property and/or Reproductions.],
      [Further information on the conditions under which disclosure, publication and commercialisation of this dissertation, the Copyright and any Intellectual Property and/or Reproductions described in it may take place is available in the #link("https://documents.manchester.ac.uk/DocuInfo.aspx?DocID=24420")[University IP Policy], in any relevant Dissertation restriction declarations deposited in the University Library, the #link("https://www.library.manchester.ac.uk/about/regulations/")[University Library's regulations] and in the University's policy on the Presentation of Dissertations.],
    ),
    revisions-title: [List of dissertation revisions],
  ),
  taught-dissertation: (
    statement: "A dissertation submitted to The University of Manchester for the degree of",
    degree: none, // has to be given, such as Bachelor of Engineering
    declaration: "I hereby confirm that this dissertation is my own original work unless referenced clearly to the contrary, and that no portion of the work referred to in the dissertation has been submitted in support of an application for another degree or qualification of this or any other university or other institute of learning.",
    rights-title: [Intellectual property statement],
    rights: (
      [The author of this dissertation (including any appendices and/or schedules to this dissertation) owns certain copyright or related rights in it (the "Copyright") and they have given The University of Manchester certain rights to use such Copyright, including for administrative purposes.],
      [Copies of this dissertation, either in full or in extracts and whether in hard or electronic copy, may be made only in accordance with the Copyright, Designs and Patents Act 1988 (as amended) and regulations issued under it or, where appropriate, in accordance with licensing agreements which the University has entered into. This page must form part of any such copies made.],
      [The ownership of certain Copyright, patents, designs, trademarks and other intellectual property (the "Intellectual Property") and any reproductions of copyright works in the dissertation, for example graphs and tables ("Reproductions"), which may be described in this dissertation, may not be owned by the author and may be owned by third parties. Such Intellectual Property and Reproductions cannot and must not be made available for use without the prior written permission of the owner(s) of the relevant Intellectual Property and/or Reproductions.],
      [Further information on the conditions under which disclosure, publication and commercialisation of this dissertation, the Copyright and any Intellectual Property and/or Reproductions described in it may take place is available in the #link("https://documents.manchester.ac.uk/DocuInfo.aspx?DocID=24420")[University IP Policy]y, in any relevant Dissertation restriction declarations deposited in the University Library, and The #link("https://www.library.manchester.ac.uk/about/regulations/")[University Library's regulations].],
    ),
    revisions-title: [List of dissertation revisions],
  ),
)



// ------ DEFINE ARGUMENTS ----------------------------------------------
// The text of a chapter, section or sub-section heading. It is a block rather
// than a paragraph, because tagged PDF 2.0 (and so PDF/UA-2) does not allow a
// paragraph inside a heading. With above and below set to auto the block is
// spaced like a paragraph, where a block in a heading would otherwise take the
// heading's own spacing and stick to what follows, so nothing moves.
#let uom-heading-text(body) = block(above: auto, below: auto, sticky: true, body)


#let uom-thesis(
  title: none,
  abstract: none,
  keywords: (),
  publications: none,
  termsandabbreviations: none,
  layabstract: none,
  acknowledgements: none,
  theauthor: none,
  chapterbreak: true,
  author: none,
  faculty: none,
  year: none,
  school: none,
  departmentordivision: none,
  report: "thesis",
  continuationyear: none,
  studentid: none,
  degree: auto,
  covidstatement: none,
  declaration: none,
  revisions: none,
  aideclaration: none,
  contentnotification: none,
  font: "TeX Gyre Termes",
  fontsize: 12pt,
  draft: false,
  printmargins: false,
  body,
) = {
  

  
// ------ CHECK OPTIONS ------------------------------------------------
  
  // Report type
  assert(
    report in uom-reports, message: "report should be one of " + uom-reports.keys().join(", ")
  )
  let kind = uom-reports.at(report)
  let degree = if degree == auto { kind.degree } else { degree }
  let taught = report == "taught-dissertation"
  let continuation = report == "continuation-report"

  // Check title
  assert(
    title != none,
    message: "a thesis title must be provided",
  )

  // Check author
  assert(taught or author != none, message: "an author name is required")


  // Check abstract
  assert(
    author != none or studentid != none,
    message: "a thesis title must be provided",
  )
  
  // Check degree is given when UGT/PGT
  assert(continuation or degree != none,
    message: "for all except a continuation report you must give the degree in full for the title page, such as degree: \"Bachelor of Engineering\". For a continuation report, no degree should be given"
  )

  
  // Check student ID is given when UGT/PGT
  assert(not taught or studentid != none, message: "a taught dissertation gives the student ID on the title page instead of the name, so give studentid")
  
  // Check font size for UGT
  // assert(not taught or fontsize >= 12pt, message: "a taught dissertation needs a font size of at least 12pt") // maybe add back in later. Some courses use 11pt still

  // Check continuation year is given if a continuation report
  assert(
    not continuation or continuationyear in (1, 2, 3),
    message: "for a continuation report, continuationyear must be 1, 2, or 3",
  )
  assert(
    continuation or continuationyear == none,
    message: "continuationyear can only be used with report: \"continuation-report\"",
  )

  

// ------ SETUP DOCUMENT ------------------------------------------------

  // Document meta-data. A taught dissertation leaves the name out, as it goes by student ID
  state("maincontent").update(true)
  show <uom-count-only>: none // copies of text that only the word count sees (see uom-flex-caption and uom-subfigures)
  set document(
    author: if taught { (studentid) } else { author }, 
    title: if draft { "DRAFT: " + title } else { title },
    keywords: keywords,
    description: none,
    date: datetime.today(),
  )

  
  // Page size and numbering
  let left-margin = if printmargins { uom-margin-left-print } else { uom-margin-left }
  let right-margin = uom-margin-right
  let top-margin = uom-margin-top
  let bottom-margin = uom-margin-bottom

  set page(
    paper: "a4",
    margin: (
      left: left-margin,
      right: right-margin,
      top: top-margin,
      bottom: bottom-margin,
    ),
    number-align: bottom + center,
  )

  
  // DRAFT across each page in draft mode, marked as decoration so screen
  // readers skip it
  set page(background: if draft {
    pdf.artifact(rotate(-45deg, text(100pt, fill: luma(90%), weight: "bold")[DRAFT]))
  })

  
  // Fonts
  // For theses the guidelines say "a font type and size which ensures readability must be used ... in a font such as Arial, Verdana, Tahoma, Trebuchet, Calibri, Times, Times New Roman, Palatino or Garamond". Not all of these are built-in to Typst online, you might need to add the font. Roboto and Noto sans are also options here which should satisfy this
  // For UGT dissertations the policy doesn't set the font, so users need to check requirements with their local handbook.
  // Defaults to Libertinus Serif and New Computer Modern respectiviely as these are guaranteed to be avaiable in Typst
  let fonts = (
    arial: "Arial",
    calibri: "Calibri",
    garamond: "Garamond",
    helvetica: "TeX Gyre Heros",
    libertinus-serif: "Libertinus Serif",
    new-computer-modern: "New Computer Modern",
    noto-sans: "Noto Sans",
    palatino: "TeX Gyre Pagella",
    roboto: "Roboto",
    tahoma: "Tahoma",
    times: "TeX Gyre Termes",
    trebuchet: "Trebuchet",
    verdana: "Verdana",
  )
 
  let default-font = if report == "taught-dissertation" {
    fonts.at("libertinus-serif")
  } else {
    fonts.at("new-computer-modern")
  }
 
  let font-actual = fonts.at(font, default: default-font)

  
  // Basic formatting
  set text(
    font: font-actual, 
    size: fontsize,
    lang: "en",
    region: "GB", // British Engli
  )
  set heading(numbering: "1.1")
  set par(leading: 1.2em) // line spacing
  set par(spacing: 2em) // space between paragraphs

  show link: it => {
    if type(it.dest) == str {
      underline(it)
    } else {
      it
    }
  }


  let continuation-statement = if continuation {
    (
      1: "Nine month progress report",
      2: "End of second year report",
      3: "End of third year report",
    ).at(continuationyear)
  }


  
// ------ HEADING STYLES ------------------------------------------------

  // Level 1 for Chapters, each on a new page
  show heading.where(level: 1): it => {
    if chapterbreak { pagebreak(weak: true) }
    v(uom-l1-header-size)
    set align(left)
    set text(uom-l1-header-size, weight: "bold")
    if it.numbering != none {
      uom-heading-text("Chapter " + counter(heading).display("1") + "\n" + it.body)
    } else {
      uom-heading-text(it.body)
    }
  }
  show heading.where(level: 1): set heading(supplement: [Chapter])

  
  // Level 2 for Sections
  show heading.where(level: 2): it => {
    v(uom-l2-header-size)
    set align(left)
    set text(uom-l2-header-size, weight: "bold")
    if it.numbering != none {
      uom-heading-text(counter(heading).display("1.1") + " " + it.body)
    } else {
      uom-heading-text(it.body)
    }    
  }

  
  // Level 3 for Sub-sections
  show heading.where(level: 3): it => {
    v(uom-l3-header-size)
    set align(left)
    set text(uom-l3-header-size, weight: "bold")
    uom-heading-text(counter(heading).display("1.1") + " " + it.body)
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

  // PDF bookmarks only up to level 3
  show heading.where(level: 4): set heading(bookmarked: false)
  show heading.where(level: 5): set heading(bookmarked: false)
  show heading.where(level: 6): set heading(bookmarked: false)



// ------ FIGURES, TABLES, AND EQUATIONS --------------------------------

  // Reset counters each chapter to allow Ch.Sect type references
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }

  
  // Caption formatting
  show figure.caption: set text(size: uom-caption-size)
  show figure.caption: set align(center)

  
  // Table captions
  // Only the top line of a table is added at the moment. Should do under the header and the last line of the table to be in IEEE style
  show figure.where(kind: table): set figure.caption(position: top)  
  show figure.where(kind: table): set figure(supplement: uom-table-supplement)
  set table(stroke: (_, y) => if y == 0 { 
    (top: 1.5pt)
  } else if y == 0 {
    (bottom: 1.5pt) 
  })

  
  // Figure captions
  show figure: set block(spacing: 2em)
  show figure: set place(clearance: 1em)
  show figure.where(kind: image): set figure(supplement: uom-figure-supplement)
  set figure(numbering: num =>
    numbering("1.1", counter(heading).get().first(), num)
  )

  
  // Caption labels, such as "Fig. 1.1." and "Table 1.1.", in bold. This is a caption rule rather than a figure rule, so that a figure with no number works, and so that subpar can label the parts of a sub-figure itself.
  show figure.caption: it => {
    if it.numbering == none { return it.body }
    let prefix = (
      if it.kind == table [#uom-table-supplement]
      else if it.kind == image [#uom-figure-supplement]
      else [#it.supplement]
    )
    let numbers = numbering(it.numbering, ..it.counter.at(it.location()))
    [#text(prefix + " " +  numbers + ".", weight: "bold") #it.body]
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
  show quote.where(block: true): it => pad(x: 2.5em, { // indented both sides, as in LaTeX
    ["] + h(0pt, weak: true) + emph(it.body) + h(0pt, weak: true) + ["]
    if it.attribution != none [ #it.attribution]
  })



// ------ LIST OF THESIS REVISIONS --------------------------------------

  // For a resubmitted thesis or dissertation only. Goes before the title page and any COVID-19 impact statement, and is taken out of the final version after the re-examination
  // In general I would suggest doing the list of revisions in a seperate document, but can do as a direct part of this document if would like, and this makes adding cross-references to sections/pages easier
  if revisions != none {
    heading(outlined: false, bookmarked: true, numbering: none, level: 1, kind.revisions-title)
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    revisions
    pagebreak()
    counter(page).update(1)
  }



// ------ COVID-19 IMPACT STATEMENT -------------------------------------

  // Optional. Only allowed for people starting before September 2022. Likely to be removed from template in next revision
  // Goes immediately before the title page, has no page number, and is taken out of the final version after the examination 
  if covidstatement != none {
    heading(outlined: false, bookmarked: true, numbering: none, level: 1, [COVID-19 impact statement])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    covidstatement
    pagebreak()
    counter(page).update(1)
  }



// ------ TTILE PAGE ----------------------------------------------------

  // Invisible parent for the front-matter entries in the contents and PDF bookmarks
  let uom-front-matter() = {
    show heading: none
    heading(
      level: 1,
      numbering: none,
      outlined: true,
      bookmarked: true,
    )[Front matter]
  }

  
  // PDF bookmark for the title page
  uom-front-matter()
  {
    show heading: none
    heading(
      level: 2,
      numbering: none,
      outlined: false,
      bookmarked: true,
    )[Title page]
  }

  
  // Format title page
  place(dx: -left-margin+uom-logo-pad, dy:-top-margin+uom-logo-pad,
    image("uom-logo.svg", width: uom-logo-width, alt: "The University of Manchester logo")
  )
  v(2fr)
  set align(center)
  text(uom-title-size, weight: "bold", title)
  v(1fr)
  if continuation {
    text(continuation-statement)
  } else {
    text(kind.statement + " \n " + degree + " \n in the Faculty of ")
    text(faculty)
  }
  v(1fr)
  text(year)
  v(1fr)  
  if taught {
    // The student ID instead of the name, or one ID per line for a group
    let ids = if type(studentid) == array { studentid } else { (studentid,) }
    text(ids.map(id => [#id]).join(linebreak()))
  } else {
    text(1em, author)
  }
  text("\n" + school)
  text("\n" + departmentordivision)
  v(1fr)
  pagebreak()
  set align(left)
  set page(numbering: "1")


  
// ------ FRONT MATTER SECTIONS ---------------------------------------------

  // All front-matter headings are structurally level 2 so that they sit underneath "Front matter" in the contents and PDF bookmarks.
  let uom-front-heading(body) = [
    #heading(
      level: 2,
      numbering: none,
      outlined: true,
      bookmarked: true,
      body,
    ) <uom-front-heading>
  ]
  show outline: set heading(
    level: 2,
    numbering: none,
    outlined: true,
    bookmarked: true,
  )

  
  // Display a front-matter heading like an unnumbered chapter heading.
  let uom-show-front-heading(it) = {
    if chapterbreak { pagebreak(weak: true) }
    v(uom-l1-header-size)
    set align(left)
    set text(uom-l1-header-size, weight: "bold")
    uom-heading-text(it.body)
    v(uom-l1-header-space-front * uom-l1-header-size)
  }
  show <uom-front-heading>: uom-show-front-heading


  // Give Contents, List of figures and List of tables the same appearance other front-matter headings
  show outline: it => {
    uom-in-outline.update(true)
    show heading.where(level: 2): uom-show-front-heading
    it
    uom-in-outline.update(false)
  }


  // Contents
  {
    show outline.entry.where(level: 1): set outline.entry(fill: none)
    show outline.entry.where(level: 1): set text(weight: "bold")
      outline(
        title: [Contents],
        depth: 3,
        indent: auto,
      )
    }

  
  // Word count, at the bottom of the contents page. Counts the main text only: the chapters, including footnotes, but not the preliminary pages, the bibliography or the appendices. The count is taken from the body at the end of this function.
  align(right + bottom, block[
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
  outline(
    depth: 3, 
    indent: auto,
    title: [List of tables],
    target: figure.where(kind: table),
  )
  pagebreak()

  
  // List of publications. Optional
  if publications != none {
    uom-front-heading([List of publications])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    publications
    pagebreak()
  }

  
  // Terms and abbreviations. Optional
  if termsandabbreviations != none {
    uom-front-heading([Terms and abbreviations])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    termsandabbreviations
    pagebreak()
  }

  
  // Abstract
  uom-front-heading([Abstract])
  v(-1 * uom-l1-header-space * uom-l1-header-size)
  abstract
  pagebreak()

  
  // Lay abstract. Optional
  if layabstract != none {
    uom-front-heading([Lay abstract])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    layabstract
    pagebreak()
  }

  
  // Declaration of originality. Either the default text 
  uom-front-heading([Declaration of originality])
  v(-1 * uom-l1-header-space * uom-l1-header-size)
  if declaration != none {
    declaration
  } else {
    kind.declaration
  }
  pagebreak()

  
  // Copyright statement, or intellectual property statement for a taught dissertation, worded as in the document for the report type (see uom-reports at the top)
  uom-front-heading(kind.rights-title)
  v(-1 * uom-l1-header-space * uom-l1-header-size)
  if uom-reports == taught {
    set enum(numbering: "i.")
    enum(..kind.rights)
  } else {
    list(..kind.rights)
  }
  pagebreak()

  
  // Acknowledgements. Optional
  if acknowledgements != none {
    uom-front-heading([Acknowledgements])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    acknowledgements
    pagebreak()
  }


  // The author. Optional
  if theauthor != none {
    uom-front-heading([The author])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    theauthor
    pagebreak()
  }


  // AI decalaration. Optional
  if aideclaration != none {
    uom-front-heading([AI declaration])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    aideclaration
    pagebreak()
  }


  // Content notification. Optional
  if contentnotification != none {
    uom-front-heading([Content notification])
    v(-1 * uom-l1-header-space * uom-l1-header-size)
    contentnotification
    pagebreak()
  }


  
// ------ MAIN BODY ---------------------------------------------

  set text(hyphenate: true)
  show: word-count.with(exclude: <uom-appendices>)
  body

  // In draft mode, list the to-dos and missing figures at the end. Outside it, stop the build if there are any left
  context {
    let left = query(selector(<uom-todo>).or(<uom-missing-figure>))
    let pages = left.map(it => str(counter(page).at(it.location()).first())).dedup()
    if draft and left.len() > 0 {
      heading(outlined: false, bookmarked: true, numbering: none, level: 1, [Still to do])
      for it in left {
        let what = if it.label == <uom-todo> [To do] else [Missing figure]
        [- #link(it.location())[Page #counter(page).at(it.location()).first()]: #what: #it.value]
      }
    }
    let where = (if pages.len() == 1 { "on page " } else { "on pages " }) + pages.join(", ", last: " and ")
    assert(draft or left.len() == 0, message: "the thesis still has to-dos or missing figures, " + where + ". Finish them, or use draft: true in uom-thesis while it is still being written")
  }

show bibliography: set heading(
  numbering: none,
  outlined: true,
  bookmarked: true,
)

show bibliography: set block(
  below: uom-l1-header-space-front * uom-l1-header-size,
)
  
}



// ------ APPENDIX FORMATTING -------------------------------------------

#let uom-appendix(body, chapterbreak: true) = [#{
  state("appendix").update(true)

  
  // Add "Appendices" page and heading
  heading(
    level: 1,
    numbering: none,
    outlined: true,
    bookmarked: true,
  )[Appendices]
  pagebreak()

  
  // Appendix headings are offset by 1 so they are typeset as chapters, but appear underneath the "Appendices" heading in the contents and PDF bookmarks.
  set heading(offset: 1)
  counter(heading).update((0, 0))


  // Only appendix titles go into the TOC.
  show heading: set heading(outlined: false)

  
  // Appendix titles: A, B, C, ...
  show heading.where(level: 2): set heading(
    outlined: true,
    bookmarked: true,
    supplement: [Appendix],
    numbering: (..nums) => numbering(
      "A",
      nums.at(1),
    ),
  )

  
  // Appendix sections: A.1, A.2, ...
  // These are bookmarked, but are not included in the TOC.
  show heading.where(level: 3): set heading(
    outlined: false,
    bookmarked: true,
    numbering: (..nums) => numbering(
      "A.1",
      nums.at(1),
      nums.at(2),
    ),
  )

  
  // Appendix subsections: A.1.1, A.1.2, ...
  // These are neither in the TOC nor PDF bookmarks.
  show heading.where(level: 4): set heading(
    outlined: false,
    bookmarked: false,
    numbering: (..nums) => numbering(
      "A.1.1",
      nums.at(1),
      nums.at(2),
      nums.at(3),
    ),
  )

  show heading.where(level: 5): set heading(
    outlined: false,
    bookmarked: false,
  )

  show heading.where(level: 6): set heading(
    outlined: false,
    bookmarked: false,
  )


  // Style Appendix level 2 like a chapter
  show heading.where(level: 2): it => {
    if chapterbreak {
      pagebreak(weak: true)
    }

    // Reset per-appendix counters.
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)

    v(uom-l1-header-space * uom-l1-header-size)
    set align(left)
    set text(uom-l1-header-size, weight: "bold")

    if it.numbering != none {
      uom-heading-text(
        "Appendix "
        + counter(heading).display(
          (..nums) => numbering(
            "A",
            nums.at(1),
          )
        )
        + "\n"
        + it.body
      )
    } else {
      uom-heading-text(it.body)
    }
  }

  
  // Style Appendix level 3 like a section
  show heading.where(level: 3): it => {
    set align(left)
    set text(uom-l2-header-size, weight: "bold")

    if it.numbering != none {
      uom-heading-text(
        counter(heading).display(
          (..nums) => numbering(
            "A.1",
            nums.at(1),
            nums.at(2),
          )
        )
        + " "
        + it.body
      )
    } else {
      uom-heading-text(it.body)
    }
  }

  
  // Style Appendix level 4 like a subsection
  show heading.where(level: 4): it => {
    set align(left)
    set text(uom-l3-header-size, weight: "bold")

    if it.numbering != none {
      uom-heading-text(
        counter(heading).display(
          (..nums) => numbering(
            "A.1.1",
            nums.at(1),
            nums.at(2),
            nums.at(3),
          )
        )
        + " "
        + it.body
      )
    } else {
      uom-heading-text(it.body)
    }
  }

  
  // Style figure/table numbering to use the appendix letter
  set figure(numbering: num => {
    let appendix = counter(heading).get().at(1)

    if appendix == 0 {
      numbering("1", num)
    } else {
      numbering("A.1", appendix, num)
    }
  })

  
  // Style equation numbering to use the appendix letter
  set math.equation(
    supplement: none,
    numbering: num => {
      let appendix = counter(heading).get().at(1)

      if appendix == 0 {
        numbering("(1)", num)
      } else {
        numbering("(A.1)", appendix, num)
      }
    },
  )

  body
} <uom-appendices>]



// ------ SUB-FIGURES ---------------------------------------------------

// By default subpar relabels figures in a way which is incompatbile with how they are relablled in other parts of the template. There is thus a custom command below. Should revist in a future release to allow subpar to be used directly

// A figure made of several parts, using the subpar package. It is numbered like any other figure (Fig. 1.2, or Fig. A.2 in an appendix), the parts are labelled (a), (b) and so on, and a reference to a part reads Fig. 1.2a. It takes the same arguments as subpar.grid.
#let uom-subfigures(..args) = {
  // Numbers that follow the chapter, or the appendix letter
  let by-chapter(main, appendix, before-appendix) = (..num) => {
    let chapter = counter(heading).get().first()
    if state("appendix").get() != true { numbering(main, chapter, ..num) }
    else if chapter == 0 { numbering(before-appendix, ..num) }
    else { numbering(appendix, chapter, ..num) }
  }
  let kind = args.named().at("kind", default: image)

  // subpar draws the figure inside a context block, which the word count
  // can't see into, so the word count gets a copy of the captions here.
  // The copy is never shown.
  [#block({
    for part in args.pos() { if type(part) == content { part } }
    args.named().at("caption", default: none)
  })<uom-count-only>]

  subpar.grid(
    numbering: by-chapter("1.1", "A.1", "1"),
    numbering-sub-ref: by-chapter("1.1a", "A.1a", "1a"),
    ..if kind == image { (supplement: uom-figure-supplement) },
    ..args,
  )
}
