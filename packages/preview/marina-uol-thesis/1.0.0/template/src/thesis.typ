#let ack_body = state("ack_body", [])
#let abstract_body = state("abstract_body", [])
#let appendix_body = state("appendix_body", [])

#let thesis_has_images = state("thesis_has_images", false)
#let thesis_has_raw = state("thesis_has_raw", false)
#let thesis_has_tables = state("thesis_has_tables", false)
#let thesis_has_equations = state("thesis_has_equations" ,false)

#let _make_titlepage(title, name, studentid, degree, programme, school, supervisor, date) = {
  // make title page
  align(center)[

    #v(1.5cm)
    // this box makes sure that even on a single-line title,
    // that the logo doesn't get shifted up, since it's 2-ish lines tall
    #box(height: 48pt)[
      // set to default value temporarily so that the global par change
      // doesn't affect it (looks better this way)
      // https://typst.app/docs/reference/model/par/#parameters-leading
      #par(leading: 0.65em)[
        #text(size: 24pt, weight:"semibold", title)
      ]
    ]

    #v(1cm)
    #align(center)[
      #image("/template/resources/logo.jpg", width: 35%)
    ]

    #v(1.5cm)
    #text(size: 16pt)[
      #name \
      #studentid
    ]

    #v(1.5cm)

    Submitted in partial satisfaction of the requirements for the \ degree of
    #v(0.5cm)
    #degree #programme \
    #school \
    University of Lincoln

    #v(1cm)
    Supervisor: #supervisor \
    #v(1.5cm)
    #date

    #pagebreak()
  ]
}

#let _make_preamble_page(title, heading_label, content_body) = {
  show heading.where(level: 1): this => {
    text(size: 24pt)[
      #this.body
      #parbreak()
    ]
  }
  // [= Acknowledgements <acknowledgements>]
  heading(outlined: false)[#title #label(heading_label)]
  // context ack_body.final()
  content_body
  pagebreak()
}

#let _clear_counters() = {

  if counter(figure.where(kind: image)).get().at(0) > 0 {
    thesis_has_images.update(true)
  }

  if counter(figure.where(kind: raw)).get().at(0) > 0 {
    thesis_has_raw.update(true)
  }

  if counter(figure.where(kind: table)).get().at(0) > 0 {
    thesis_has_tables.update(true)
  }

  if counter(math.equation).get().at(0) > 0 {
    thesis_has_equations.update(true)
  }

  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: raw)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
}

#let thesis(
  title: none,
  name: none,
  studentid: none,
  degree: none,
  programme: none,
  school: none,
  supervisor: none,
  date: none,
  header_text: none,
  bib: none,
  bib_style: "harvard-cite-them-right-edited.csl",

  doc
  ) = {
  
  set page(
    paper: "a4",
  )

  set par(leading: 1.2em)
  set text(size: 12pt)

  set bibliography(
    // style: "harvard-cite-them-right"
    // style: "harvard-cite-them-right-edited.csl"
    style: bib_style
  )

  set math.equation(
    numbering: this => {
      let heading_count = counter(heading).get()
      numbering("1.1", heading_count.at(0), this)
    }
  )

  _make_titlepage(title, name, studentid, degree, programme, school, supervisor, date)

  set page(margin: (left: 3.5cm))

  // https://typst.app/docs/reference/text/text/#parameters-hyphenate
  // fill the entire line, instead of breaking into a new one
  // for words that are quite long
  set text(hyphenate: true)
  set par(justify: true, spacing: 2em)

  // set up header & footer
  set page(
    header: [
      #set text(size: 10pt)
      #align(right)[
        #text(weight: "light", emph(header_text))
      ]
    ],

    footer: {
      box()[
        #set text(size: 10pt)
        _#name (#studentid) _
        #h(1fr) 
        #context strong(counter(page).display("i"))
      ]
    }
  )

  // reset page counter to 1 after title page
  counter(page).update(1)

  context {

    if ack_body.final() != [] {
      _make_preamble_page([Acknowledgements], "acknowledgements", ack_body.final())
    }

    if abstract_body.final() != [] {
      _make_preamble_page([Abstract], "abstract", abstract_body.final())
    }

  }


  show outline.entry.where(level: 1): set block(above: 2em)

  // make table of contents with bold headings
  [
    #show outline.entry.where(level: 1): this => {
      strong(this)
    }

    #outline(
      title: text(size:24pt)[Table of Contents]
    )
    #pagebreak()
  ]

  // selectively create list of X pages depending on whether or not they exist
  // in the document
  context {

    // NOTE: could probably do away with these counters... querying the global variable
    // might be the best way of knowing whether or not that content exists, as there is
    // a condition where if there's only 1 of the element, it'll fail to generate the
    // page since the counter would've reset and this check would fall through
    if counter(figure.where(kind: image)).final().at(0) > 0 or thesis_has_images.final() {
      outline(
        title: text(size:24pt)[List of Figures],
        target: figure.where(kind: image)
      )
      pagebreak()
    }

    if counter(figure.where(kind: table)).final().at(0) > 0 or thesis_has_tables.final() {
      outline(
        title: text(size:24pt)[List of Tables],
        target: figure.where(kind: table)
      )
      pagebreak()
    }

    if counter(figure.where(kind: raw)).final().at(0) > 0 or thesis_has_raw.final(){
      outline(
        title: text(size:24pt)[List of Listings],
        target: figure.where(kind: raw)
      )
      pagebreak()
    }

    if counter(math.equation).final().at(0) > 0 or thesis_has_equations.final(){
      outline(
        title: text(size:24pt)[List of Equations],
        target: math.equation
      )
      pagebreak()
    }
  }

  // set page counter to 1, reset its style, and add the section title to the footer
  context counter(page).update(1)
  set page(
    footer: [
      #set text(size: 10pt)
      _#name (#studentid)_
      #h(1fr)
      #box()[
        #emph(context query(selector(heading.where(level: 1)).before(here())).last().body)
        #h(0.2cm)
        #context strong(counter(page).display("1"))
      ]
    ]
  )

  // different type of headings for following sections
  // follows the format "Chapter X \n Section title"
  [
    #set heading(numbering: "1.1")
    #show heading.where(level: 1): this => {
      set text(size: 24pt)

      [
        Chapter #counter(heading).display("1") \
        #this.body 
        #parbreak()
      ]

      _clear_counters()

    }

    #show heading.where(level: 2): this => {
      set text(size: 18pt)
      set block(
        above: 3em,
        below: 1.6em,
      )
      this
    }

    #show heading.where(level: 3): this => {
      set text(size: 16pt)
      this
    }

    #show figure.caption: this => {
      set par(leading: 0.8em)
      this
    }

    #set figure(
      numbering: this => {
        let heading_count = counter(heading).get()
        numbering("1.1", heading_count.at(0), this)
      }
    )

    #counter(heading).update(0)
    #doc
  ]

  // make bibliography
  if bib != none {
    pagebreak()
    [
      #show heading.where(level: 1): this => {
        set text(size:24pt)
        this.body
      }
      #bib
    ]
  }


  context {
    if appendix_body.final() != [] {
      pagebreak()
      {
        counter(heading).update(0)
        set heading(numbering: "A.1.1")
  
        show heading.where(level:1): this => {
          set text(size:24pt)
          [
            Appendix #counter(heading).display() \
            #this.body 
            #parbreak()
          ]

          _clear_counters()
        }
  
        show heading.where(level: 2): this => {
          set text(size: 18pt)
          set block(
            above: 3em,
            below: 1.6em
          )
          this
        }
  
        show heading.where(level: 3): this => {
          set text(size: 16pt)
          this
        }

        set figure(
          numbering: this => {
            let heading_count = counter(heading).get()
            numbering("A.1", heading_count.at(0), this)
          }
        )

        appendix_body.final()
      }
    }
  }
}

#let acknowledgements(doc) = {
  context ack_body.update(doc)
}

#let abstract(doc) = {
  context abstract_body.update(doc)
}

#let appendix(doc) = {
  context appendix_body.update(appendix_body.get() + doc)
}

#let _make_code_block(code) = [
  
  // based on codedis
  // https://github.com/AugustinWinther/codedis/blob/main/lib.typ
  #show raw.line: this => {
    
    let start = 1
    let end = this.count
    
    let get_stroke(line) = {
      // for 1 line long code blocks
      if line == start and line == end {
        return black + 1pt
      } else if line == start {
        return (top: black + 1pt, x: black + 1pt)
      } else if line == end {
        return (bottom: black + 1pt, x: black + 1pt)
      } else {
        return (x: black + 1pt)
      }
    }

    let line = this.number
    block(
      breakable: false,
      width: 100%,
      height: 2.5em,
      spacing: 0em,
      inset: (x: 1.2em, top: 0.8em),
      // stroke: black + 0.5pt
      stroke: get_stroke(line)
    )[
      #this
    ]

    // bring all blocks together
    if line != end { v(-1.8em) }
  }

  #code
]

#let code(code, caption: none, label_id: none, placement: auto, outlined: true) = [

  #show figure: this => {
    set block(breakable: true)
    this
  }

  #set figure(placement: placement)

  #if outlined [
    #figure(caption: caption)[
      #_make_code_block(code)
    ]
    #if label_id != none {
      label(label_id)
    }
  ] else [
    #figure(
      outlined: false,
      kind: "hidden",
      supplement: [hidden]
    )[
      #_make_code_block(code)
    ]
  ]
]

#let placeholder(height: 5cm, width: 100%, colour: red) = {
  rect(
    height: height,
    width: width,
    fill: colour
  )[
    #align(center + horizon)[
      #text(white, size: 16pt)[*PLACEHOLDER IMAGE*]
    ]
  ]
}