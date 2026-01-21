// The FH JOANNEUM Template
//
// requires parameters set in the main file "thesis.typ"
//

// ******************
// Helper functionality: todo / quote / fhjcode / textit / textbf / fhjtable / ...
// ******************

// Helper to support long and short captions for outlines (list of figures)
// author: laurmaedje
// Put this somewhere in your template or at the start of your document.
#let in-outline = state("in-outline", false)
#let flex-caption(long, short) = context if in-outline.get() { short } else {
long }

#let todo(term, color: red) = {
  text(color, box[#term])
}

#let quote(message, by) = {
  block(radius: 1em, width: 90%, inset: (x: 2em, y: 0.5em), [
    #message,
    #par(first-line-indent: 25em, text(font: "Times New Roman", size: 9pt, [
      (#by)
    ]))
  ])
}

// inspired by: https://github.com/typst/typst/issues/344
#let fhjcode(code: "", language: "python", firstline: 0, lastline: -1) = {
  // Custom layout for raw code
  // with line numbering
  show raw.where(block: true, lang: "trimmed_code"): it => {
    //
    // shorten the source code if firstline and/or lastline are specified
    //
    let theCode = it.text // contents -> string
    let lines = theCode.split("\n")
    let fromLine = if firstline > lines.len() { lines.len() } else { firstline };
    let toLine = if lastline > lines.len() { lines.len() } else { lastline };
    lines = lines.slice(fromLine, toLine)

    set par(justify: false); grid(
      columns: (100%, 100%), column-gutter: -100%,
      // output source code
      block(
        radius: 1em, fill: luma(240), width: 100%, inset: (x: 2em, y: 0.5em), raw(lines.join("\n"), lang: language),
      ),
      // output line numbers
      block(
        width: 100%, inset: (x: 1em, y: 0.6em), for (idx, line) in lines.enumerate() {
          text(size: 0.6em, str(idx + 1) + linebreak())
        },
      ),
    )
  }
  set text(size: 11pt)

  // we use here INTERNAL lang parameter "trimmed_python"
  // which supports trimming (see: show  raw.where(...) )
  raw(code, block: true, lang: "trimmed_code")
}

// macros to emphasise / italic / boldface in a specific way
// e.g. invent your own styles for tools/commands/names/...

#let textit(it) = [
  #set text(style: "italic")
  #h(0.1em, weak: true)
  #it
  #h(0.3em, weak: true)
]

#let textbf(it) = [
  #set text(weight: "semibold")
  #h(0.1em, weak: true)
  #it
  #h(0.2em, weak: true)
]

// Create a table from csv,
//   render first line bold,
//   use alternating line colors
#let fhjtable(
  tabledata: "", columns: 1, header-row: rgb(255, 231, 230), even-row: rgb(255, 255, 255), odd-row: rgb(228, 234, 250),
) = {
  let tableheadings = tabledata.first()
  let data = tabledata.slice(1).flatten()
  table(
    columns: columns, fill: (_, row) =>
    if row == 0 {
      header-row // color for header row
    } else if calc.odd(row) {
      odd-row // each other row colored
    } else {
      even-row
    }, align: (col, row) =>
    if row == 0 { center } else { left }, ..tableheadings.map(x => [*#x*]), // bold headings
    ..data,
  )
}



// ******************
// MAIN TEMPLATE:
// ******************

// This function gets your whole document as its `body` and formats
// it as a bachelor or master thesis in the style suggested by IIT @ FH JOANNEUM.
#let thesis(
  // We default to a BA/MA thesis, but creating an expose is supported
  expose: false,
  // Currently supported abbreviations: 'ims', 'swd', 'itm', 'msd'
  study: "<study>",
  // Supported: 'en' and 'de'
  language: "en", bibfilename: "",
  // Base infors, such as title and (optional) subtitle, supervisor, author, (optional) logo, abstracts etc.
  title: "Specify the title of your Thesis",
  subtitle: none, supervisor: "Specify your supervisor",
  author: "Specify your author",
  submission-date: "Specify submission date",
  logo: none,
  // Abstract in English is required
  abstract-ge: none,
  abstract-en: [Replace this with your abstract.],
  // List of (3-7) keywords. E.g. ("ml","performance","optimise")
  keywords: none,
  // The bibliography is typically read from an *.bib file:
  biblio: none,
  // specify if all or only a subset of outlines (list-of <x>) should be output
  show-list-of: ("listings", "tables", "equations", "figures"),
  // keep links in black with
  link-color: blue.darken(60%),
  // when creating hard-copies
  // you might want to set left/right bindings to 'left'
  // and margins differently (e.g. inside to '9em' and outside to '6em')
  page-binding: auto, page-margin-inside: 6.5em, page-margin-outside: 6.5em,
  //
  // the main content from thesis.typ
  doc,
) = {
  // Helper to support long and short captions for outlines (list of figures)
  // author: laurmaedje
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  show link: set text(fill: link-color)

  // Set PDF document metadata.
  set document(title: title, author: author)

  // Optimise numbers with superscript
  // espcecially for nice bibliography entries
  show regex("\d?\dth"): w => { // 26th, 1st, ...
    let b = w.text.split(regex("th")).join()
    [#b#super([th])]
  }
  show regex("\d?\d[nr]d"): w => { // 2dn, 3rd
    let s = w.text.split(regex("\d")).last()
    let b = w.text.split(regex("[nr]d")).join()
    [#b#super(s)]
  }
  // if we find in bibentries some ISBN, we add link to it
  show "https://doi.org/": w => { // handle DOIs
    [DOI:] + str.from-unicode(160) // 160 A0 nbsp
  }
  show regex("ISBN \d+"): w => {
    let s = w.text.split().last()
    link("https://isbnsearch.org/isbn/" + s, w) // https://isbnsearch.org/isbn/1-891562-35-5
  }

  show footnote.entry: set par(hanging-indent: 1.5em)



  /*
          show figure.where(kind: table): it => {
            align(center)[
            #block(below: 0.65em, it.body)
            Table. #it.counter.display("1.") #it.caption
            ]
          }
          */

  //
  // GLOBAL SETTINGS:
  //
  // Defaults:
  let FHJ_THESIS_SUPERVISOR_LABEL = "Supervisor or Betreuer/in?"
  let FHJ_THESIS_AUTHOR_LABEL = "Submitted by or Eingereicht von?"

  // Following defaults should be overwritten
  // dependent of master/bachelor study degree programme:
  let FHJ_THESES_TITLE = "Master's or Bachelor's Thesis?"
  let FHJ_THESIS_SUBMITTED_FOR = "submitted or zur Erlangung des akademischen Grades?"
  let FHJ_THESES_TYP = "MSc or BSc?"
  let FHJ_THESES_PROG_TYPE = "Master's or Bachelor's degree programme?"
  let FHJ_THESIS_SUBMITTED_TO = "eingereicht am?" + linebreak()
  let FHJ_THESES_PROG_NAME = "IMS or SWD or MSD?"

  if (study == "ims") {
    FHJ_THESES_TITLE = "Master's Thesis"
    FHJ_THESIS_SUBMITTED_FOR = "submitted in conformity with the requirements for the degree of"
    FHJ_THESES_TYP = "Master of Science in Engineering (MSc)"
    FHJ_THESIS_SUBMITTED_TO = ""
    FHJ_THESES_PROG_TYPE = "Master’s degree programme"
    FHJ_THESES_PROG_NAME = "IT & Mobile Security"
  } else if (study == "swd" and language == "en") {
    FHJ_THESES_TITLE = "Bachelor's Thesis"
    FHJ_THESIS_SUBMITTED_FOR = "submitted in conformity with the requirements for the degree of"
    FHJ_THESES_TYP = "Bachelor of Science in Engineering (BSc)"
    FHJ_THESIS_SUBMITTED_TO = ""
    FHJ_THESES_PROG_TYPE = "Bachelor's degree programme"
    FHJ_THESES_PROG_NAME = "Software Design and Cloud Computing"
  } else if (study == "swd" and language == "de") {
    FHJ_THESES_TITLE = "Bachelorarbeit"
    FHJ_THESIS_SUBMITTED_FOR = "zur Erlangung des akademischen Grades"
    FHJ_THESES_TYP = "Bachelor of Science in Engineering (BSc)"
    FHJ_THESIS_SUBMITTED_TO = "eingereicht am" + linebreak()
    FHJ_THESES_PROG_TYPE = "Fachhochschul-Studiengang"
    FHJ_THESES_PROG_NAME = "Software Design and Cloud Computing"
  } else if (study == "msd" and language == "en") {
    FHJ_THESES_TITLE = "Bachelor's Thesis"
    FHJ_THESIS_SUBMITTED_FOR = "submitted in conformity with the requirements for the degree of"
    FHJ_THESES_TYP = "Bachelor of Science in Engineering (BSc)"
    FHJ_THESIS_SUBMITTED_TO = ""
    FHJ_THESES_PROG_TYPE = "Bachelor degree programme"
    FHJ_THESES_PROG_NAME = "Mobile Software Development"
  } else if (study == "msd" and language == "de") {
    FHJ_THESES_TITLE = "Bachelorarbeit"
    FHJ_THESIS_SUBMITTED_FOR = "zur Erlangung des akademischen Grades"
    FHJ_THESES_TYP = "Bachelor of Science in Engineering (BSc)"
    FHJ_THESIS_SUBMITTED_TO = "eingereicht am" + linebreak()
    FHJ_THESES_PROG_TYPE = "Fachhochschul-Studiengang"
    FHJ_THESES_PROG_NAME = "Mobile Software Development"
  } else {
    todo([

      ERROR

      Given setting '"+ study + "' for parameter 'study' is not supported.

      Configuration value for <study> can be 'ims', 'swd',or 'msd'.

      Check your configuration in the main file 'thesis.typ'.

      Then compile again.
    ])
  }

  if (language == "en") {
    FHJ_THESIS_SUPERVISOR_LABEL = "Supervisor"
    FHJ_THESIS_AUTHOR_LABEL = "Submitted by"
  }
  if (language == "de") {
    FHJ_THESIS_SUPERVISOR_LABEL = "Betreuer/in"
    FHJ_THESIS_AUTHOR_LABEL = "Eingereicht von"
  }

  set text(lang: if (language == "de") {
    "de"
  } else {
    "en"
  })

  //
  // heading: titles and subtitles
  //

  // Necessary for references: @backend, @frontend,...
  set heading(numbering: "1.")
  show heading.where(level: 1): it => [
    // we layout rather large Chapter Headings, e.g:
    //
    //  3 | Related Work
    //
    #set text(size: 34pt)
    #v(2cm)
    #block[
      #if it.numbering != none [
        #counter(heading).display()
        |
        #it.body
      ]
      #if it.numbering == none [
        #it.body
      ]
      #v(1cm)
    ]
    #v(1cm, weak: true)
  ]
  show heading.where(level: 2): it => [
    #set text(size: 18pt)
    #block[
      #v(0.5cm)
      #counter(heading).display()
      #it.body
    ]
    // some space after the heading 2 (before text)
    #v(0.5em)
  ]
  show heading.where(level: 3): set text(size: 14pt)

  // equations with numbers on the right side the (1) (2) (3) ...
  set math.equation(numbering: "(1)")

  set cite(style: "chicago-author-date")

  // we define a variable 'ht-last' (remember the 'last header title') to hold state:
  // see below for updating the variable
  let ht-last = state("page-last-section", none)

  set page(
    paper: "a4", binding: page-binding, margin: (inside: page-margin-inside, outside: page-margin-outside), numbering: none, number-align: right,
    // Header setup for no header at front page, abstract and chapter/section titles
    //              for chapter number and chapter title on pages within a chapter
    header: context {
      // Note: pageNumber displayed (relative)
      //       let pageNumber = counter(page).at(here()).first()
      // absolute (internal) page number:
      let absPageNumber = here().page()

      let selector = heading.where(level: 1)
      let headings = query(selector)
      let headingsFoundOnCurrentPageWithNumber =  headings.filter(it => it.location().page() == absPageNumber)

      // if we are on a page which holds (some) chapter section headings
      if headingsFoundOnCurrentPageWithNumber.len() > 0 {
        let lastHeading = headingsFoundOnCurrentPageWithNumber.first()
        let currSectionName = lastHeading.body

        // We compile a nice heading for upcoming pages of this section and therefore
        // we save CURRENT Section "#currSectionName" to ht-last variable
        ht-last.update(currSectionName) // Biblio (no numbering required)
        if lastHeading.numbering != none { // normal chapters
          if language == "en" {
            ht-last.update([ Chapter #counter(selector).display() #currSectionName])
          }else{
            ht-last.update([ Kapitel #counter(selector).display() #currSectionName])
          }
        }
      }else{ // no section heading on the current page
        // only if some section title has been stored to the ht-last variable
        // otherwise we would be at title page or abstract
        if ht-last.get() != none {
            ht-last.get()
        }
      }
    },
  )

  // top logo image
  if logo != none {
    set align(center + top)
    v(2cm) // top border
    logo // Logo FH JOANNEUM (vector graphics)
  }

  v(6em)

  //
  // TITLE
  //
  set align(center)
  text(26pt, weight: "bold", title)
  v(18pt, weak: true)

  //
  // Just an expose or a full-featured thesis:
  //
  if (expose == true) {
    // start of expose (i.e. without tables, listings etc)
    text(
      14pt, [
        #subtitle
        #v(5em)

        *Exposé*
        #v(5em)

        #text(weight: "bold", [#FHJ_THESIS_SUPERVISOR_LABEL: #supervisor])

        #text(weight: "bold", [#FHJ_THESIS_AUTHOR_LABEL: #author])
        #v(3em)

        #submission-date
        ]
    )
    set align(left)
    // end of expose
  } else {
    // start of thesis including list of listings, list of tables etc.
    text(
      14pt, [
        #subtitle
        #v(5em)

        *#FHJ_THESES_TITLE*

        #FHJ_THESIS_SUBMITTED_FOR

        *#FHJ_THESES_TYP*

        #FHJ_THESIS_SUBMITTED_TO #FHJ_THESES_PROG_TYPE *#FHJ_THESES_PROG_NAME*

        #v(0.5em)

        FH JOANNEUM (University of Applied Sciences), Kapfenberg
        #v(4em)

        #text(weight: "bold", [#FHJ_THESIS_SUPERVISOR_LABEL: #supervisor])

        #text(weight: "bold", [#FHJ_THESIS_AUTHOR_LABEL: #author])
        #v(3em)

        #submission-date
      ]
    )
  }

  todo([
    #v(1.3em)
    TODO: Specify the title, subtitle, author, submission date, study, language,
      your name, and supervisor/advisor in the main _thesis.typ_ file. Then compile
      with _typst compile thesis.typ_. \
      Finally, remove all TODOs (todo marcos) within your typst ource code.
  ])

  align(center + bottom)[Preview printed #datetime.today().display().]

  pagebreak()

  if (expose != true) { // start of thesis (section not needed for an expose)
    set page(numbering: "i", number-align: center)
    counter(page).update(1)

    //
    // ABSTRACT
    //

    // ABSTRACT (en)
    set align(center)
    text(size:18pt,[*Abstract*])
    v(1em)

    set align(left)
    par(justify: true, abstract-en)

    if keywords != none {
      v(1cm)
      [*Keywords*: ]
      keywords.join(", ")
    }
    pagebreak()

    if abstract-ge != none {
      // ABSTRACT (ge)
      set align(center)
      text(size:18pt,[*Kurzfassung*])
      v(1em)

      set align(left)
      par(justify: true, abstract-ge)
      pagebreak()
    }

    // Setting numbering for ToC, LoF, LoT, LoL, ...
    set align(left)
    enum(numbering: "I.")

    //
    // TABLE OF CONTENTS (ToC)
    //
    outline(depth: 2, indent: true)

    //
    // LIST OF FIGURES (LoF)
    //
    if show-list-of.contains("figures") {
      pagebreak()
      if (language == "de") {
        heading("Abbildungsverzeichnis", numbering: none)
      } else {
        heading("List of Figures", numbering: none)
      }
      outline(title: none, target: figure.where(kind: image))
    }

    //
    // LIST OF TABLES (LoT)
    //
    if show-list-of.contains("tables") {
      pagebreak()
      if (language == "de") {
        heading("Tabellenverzeichnis", numbering: none)
      } else {
        heading("List of Tables", numbering: none)
      }
      outline(title: none, target: figure.where(kind: table))
    }

    //
    // LIST OF EQUATIONS (LoE)
    //
    if show-list-of.contains("equations") {
      pagebreak()
      if (language == "de") {
        heading("Formelverzeichnis", numbering: none)
      } else {
        heading("List of Equations", numbering: none)
      }
      outline(title: none, target: figure.where(kind: math.equation))
    }

    //
    // LIST of LISTINGS LoL
    //
    if show-list-of.contains("listings") {
      pagebreak()
      if (language == "de") {
        heading("Source Codes", numbering: none)
      } else {
        heading("List of Listings", numbering: none)
      }
      outline(title: none, target: figure.where(kind: raw))
    }
  } // end of thesis (i.e. not end of expose)
  //
  // MAIN PART
  //

  // Rest of the document with numbers starting with 1
  set page(numbering: "1", number-align: center)
  counter(page).update(1)

  // Some more global settings:
  set align(left) // align text left (i.e. no longer centered)
  set par(justify: true) // text as block (German: Blocksatz)

  // everything you specified in the main "thesis.typ" file:
  // i.e. all the imported other chapters
  doc

  //
  // BIBLIOGRAPHY
  //
  if biblio != none {
    text(12pt, biblio)
  }
}
