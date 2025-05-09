
// This file contains styling configuration for the LTH Master's thesis template,
// including LTH brand colors, fonts, and heading styles. Feel free to customize
// these settings or logic to match your needs.


#let LTHblue = rgb(0,0,128)
#let LTHbronze = rgb(156,97,20)
#let LTHgreen = rgb(173,202,184)
#let LTHpink = rgb(233,196,199)
#let LTHcream = rgb(214,219,196)
#let LTHcyan = rgb(185,211,220)
#let LTHgrey = rgb(191,184,175)

// Download the fonts from Google Drive and replace the empty `fonts/` folder (see README.md)
#let fonts = (
    serif: "Adobe Garamond Pro",
    sansserif: "Frutiger LT Pro",
    mono: "TeX Gyre Cursor"
)

#let headingPrefix = state("headingPrefix", "Chapter")

#let renderHeading(it) = {
  if it.body == [Appendices]{
    set text(font:fonts.serif, weight:700, size: 24.88pt)
    place(center+horizon,
        it.body, dy: -70pt
    )
  }
  else if it.body not in ([References], [Contents], [Acknowledgements]) {
    block(width: 100%, height: 38%)[
      #set text(font:fonts.serif, weight:"bold", size: 24.88pt)
        #if it.numbering != none {
          v(3.0em)
          headingPrefix.get()
          //headingPrefix.display()
          [ ]
          counter(heading).display()
          v(0.3em)
          h(-1.45em)
        }
        #it.body
        #v(2.0em)
        #line(length: 100%, stroke: 0.4pt)
    ]
  } else {
    block(width: 100%, height: 32%)[
      #v(4.6em)
      #set text(font: fonts.serif, weight:"bold", size: 24.88pt)
      #align(left, it.body)
      #v(2em)
      #line(length: 100%, stroke: 0.4pt)
    ]
  
  }
}

#let createAppendices(content) = {
  headingPrefix.update("")
  pagebreak(weak: true, to:"odd")
  counter(heading).update(0)
  headingPrefix.update("Appendix")
  set heading(numbering: "A")
  heading("Appendices", numbering: "A", outlined: false)
  counter(heading).update(0)
  content
}


#let template(
  // Your thesis title
  title: [Thesis Title],

  // Your thesis title in swedish
  se_title: [Svensk uppsatstitel],

  // Your thesis number, given by institution
  thesis_number: [Thesis Number],

  // Thesis ISSN
  issn: [XXXX-XXXX],
  
  subtitle: [Bachelor's Thesis],
  paper-size: "a4",
  supervisors: (),
  examiner: (),
  students: (),
  affiliation: (
    department: "Department of Computer Science",
    school: "LTH | Lund University",
    company: "the Department of Computer Science, Lund University",
  ),
  lang: "en",
  abstract: none,
  acknowledgements: none,
  keywords: none,
  body,
  popular_science_summary: (
    title: none,
    abstract: none,
    body: none,
  )
) = {
  
  //show par: set block(spacing: 0.65em)
  set par(
    first-line-indent: 0em, // no effect
    justify: true,
  )
  
  // Set document matadata.
  set document(title: title)

  // Set the body font, "New Computer Modern" gives a LaTeX-like look
  set text(font: fonts.serif, lang: lang, size: 12pt)

  // Configure the page
  set page(
    paper: paper-size,

    // Margins are taken from the university's guidelines
    background: 
    //image("assets/template/cover.jpg", width:97%, height:97.5%),
    image("assets/template/cover.jpg", height:97.5%, width:97%),
    //image("assets/template/Untitled.jpg", height:97.5%, width:97%),
    margin: (inside:3.5cm,outside:2.5cm, top: 3cm, bottom: 3cm)
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure raw text/code blocks
  show raw.where(block: true): set text(size: 0.8em, font: "Fira Code")
  show raw.where(block: false): set text(size: 1em, font: "Fira Code")
  show raw.where(block: true): set par(justify: false)
  show raw.where(block: true): block.with(
    fill: gradient.linear(luma(240), luma(245), angle: 270deg),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )
  //show raw.where(block: false): set text(size: 0.8em, font: fonts.m)

  // Configure figure's captions
  show figure: set block(spacing: 15.5pt)
  show figure: set place(clearance: 15.5pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set text(size: 10pt, font: fonts.serif)
  show figure.where(kind: table): set figure(numbering: "1")
  show figure.where(kind: image): set figure(supplement: "Figure", numbering: "1")
  show figure.caption: set text(size: 12pt)
  show figure.caption: set align(start)
  show figure.caption: set align(center)

  // Adapt supplement in caption independently from supplement used for
  // references.
  show figure: fig => {
    let prefix = (
      if fig.kind == table [Table]
      else if fig.kind == image [Figure]
      else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    show figure.caption: it => [*#prefix~#numbers:* #it.body #v(0.7em)]
    //show figure.caption.where(kind: table): smallcaps
    fig
  }

  // Configure lists and enumerations.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt, marker: ([•], [--]))

  // Configure headings
  set heading(numbering: "1.1.1")


  
  show heading.where(level: 1): it => {
    pagebreak(weak:true, to:"odd")
    renderHeading(it)
  }
  show heading.where(level: 2): it => block(width: 100%)[
    #v(1.1em)
    #set align(left)
    #set text(20.74pt, weight: "bold", font:fonts.sansserif)
    #counter(heading).display()
    #h(10pt)
    #it.body
    #v(12pt)
  ]
  show heading.where(level: 3): it => block(width: 100%)[
    #v(8pt)
    #set align(left)
    #set text(17.28pt, weight: "bold", font: fonts.sansserif)
    #counter(heading).display()
    #h(10pt)
    #it.body
    #v(8pt)
  ]
  show heading.where(level: 4): it => block(width: 100%)[
    #v(5pt)
    #set align(left)
    #set text(14.4pt, weight: "bold", font:fonts.sansserif)
    #counter(heading).display()
    #h(10pt)
    #it.body
    #v(5pt)
  ]

  // Title page
  set align(center)

  place(right, 
  block(width:120%)[
    #align(left, 
      text("MASTER'S THESIS 2025", fill:white, size:16pt, font:"Public Sans", weight: 800, tracking: 0.6pt),
    )
    #block(above:8pt, fill:white, inset:15pt, width: 100%)[
      #v(15pt)
      #set text(fill: LTHbronze, size:30pt, font: fonts.serif, weight: 600, spacing: 10pt)
      #set par(justify: false, leading: 22pt)
      #align(left,[
        #block(below: 20pt, width:100%)[
          #text(title)
          #v(20pt)
          #place(bottom, 
            line(stroke: LTHbronze + 2pt, length: 100%)
          )
        ]
        #block()[
            #text(students.map(x => x.name).join([, ]), size:18pt, spacing: 5pt)
          ]
      #v(10pt)
      ])
    ],
  ],
    dx: 63pt
  )

  place(right+bottom,
    image("assets/template/LUlogoRGB.png", width: 400pt),
    dx: 180pt,
    dy: 330pt
  )
  place(center+bottom,
    block()[
      #set text(fill:white, size:12pt)
      #align(right, 
        block()[
          #text(upper("ISSN " + issn))
          #v(-5pt)
          #text(upper(thesis_number))
          #v(-2pt)
          #set text(font:"DM Sans", weight: 500, size:11pt)
          #text(upper(affiliation.department))
          #v(-3pt)
          #text(upper(affiliation.university))
        ]
      )
    ],
    dx: -90pt,
    dy: 60pt
  )
  
  place(bottom,
    block()
  )

  pagebreak()
  set page(
    background: none,
  )
  pagebreak(to: "odd")
  set par(justify: false, first-line-indent: 1em)
  set align(top)

  // Archive page

  text(24.88pt)[ MASTER'S THESIS \ Computer Science ]
  
  v(150pt)
  text(24.88pt)[ #thesis_number ]
  v(50pt)
  text(24.88pt)[ *#title* ]
  v(5pt)
  text(20pt)[ #se_title ]
  v(35pt)
  text(15pt, weight:300)[ *#students.map(x => x.name).join(", ")* ]

  pagebreak(to: "odd")

  line(length:100%)
  text(25.88pt)[*#title*]
  v(10pt)
  text(18pt, weight: 500)[#subtitle]
  line(length:100%)
  grid(columns:students.len(), 
    ..students.map(s => 
        [
          #block(width:100%)[
            #text(s.name, size:16pt)
          ]
          #block(width:100%)[
            #link("mailto:"+s.email, raw(s.email))
          ]
        ]
    )
  )

  place(center+horizon, 
    text(
      // datetime.today().display("[month repr:long] [day], [year]"),
      datetime(year: 2025, month: 1, day: 24).display("[month repr:long] [day], [year]"),
      size: 18pt
    ),
    dy: -50pt
  )
  
  place(center+bottom, 
    block()[
      #text(
        "Master's thesis work carried out at " + affiliation.company + ".",
        size: 15pt,
      )
      #linebreak()
      #v(5pt)
      #text("Supervisors:")
      #for s in supervisors{
        text(s.name + ", ")
        link("mailto:"+s.email, raw(s.email))
        linebreak()
      }
      #v(0pt)
      #text("Examiner:")
      #text(examiner.name + ",")
      #{
        link("mailto:"+examiner.email, raw(examiner.email))
      }
    ],
    dy: -50pt
  )

  pagebreak(to:"odd")


  let numberingH(c)={
    if c.numbering == none {
      return
    }
    return numbering(c.numbering,..counter(heading).at(c.location()))
  }
  
  let renderHeader()={
    let level1 = query(selector(heading.where(level:1)).before(here()))
    let level1After = query(selector(heading.where(level:1)).after(here()))
    let level2 = query(selector(heading.where(level:2)).before(here()))
    if level1After.len() == 0{
      return
    }
    let chapterAtCurrent = level1After.first().location().page() == here().page()
    if chapterAtCurrent {
      return
    }
    if level1.len() == 0 {
      line(length:100%, stroke:0.4pt)
      return
    }
    let txt = level1.last().body.text
    let number = numberingH(level1.last())
    let useLevel2 = level2.len() != 0 and level2.last().location().page() >= level1.last().location().page()
    if useLevel2 {
      if level2.last().body.has("text") {
        txt = level2.last().body.text
        number = numberingH(level2.last())
      }
    }
    if number != none and (not useLevel2) and level1.len()==0 {
      number += "."
    }
    set text(weight: 300, font: fonts.serif, size: 10pt)
    let dir = right
    if calc.rem(here().page(), 2) == 0 {
      dir = left
    }
    align(dir,
      block()[
        #(
          if lower(txt) == "appendices"{
            ""
          }
          else {
            if lower(txt) != "references" {
              number 
              if number != none {
                ". "
              }
            }
            if lower(txt) != "acknowledgements" {
              smallcaps(txt)
            }
          }
        )
        #v(-0pt)
        #line(length:100%, stroke:0.4pt)
      ]
    )
  }



  counter(page).update(1)
  // Abstract
  if abstract != none {
    align(horizon, block(width:100%-2cm)[
        #text(
          "Abstract",
          size:12pt,
          weight:600
        )
        #v(0pt)
        #align(start, 
          block(below:0pt, above:30pt)[
            #set par(spacing: 0.6em, justify: true, first-line-indent: 1.5em, leading: 0.60em)
            #abstract
          ]
        )
        #v(2cm)
        // Keywords
        #align(left,
          if keywords != none {
            text("Keywords: ", 
              size:10pt,
              weight:600
            )
            keywords
          }
        )
      ]
    )
  }
  
  // hacky header and footer :S
  set page(header: context{
    renderHeader()
  }, footer: context{
    if here().page() == 7 {
      return
    }
    if calc.rem(here().page(), 2) == 0 [           // even pages
      #line(length:100%, stroke:0.4pt)
      #align(left, text(str(here().page()-6)))
    ] else [                                       //odd pages
      #line(length:100%, stroke:0.4pt)
      #align(right, text(str(here().page()-6)))
    ]
  })
  
  pagebreak(weak: true, to: "odd")
  
  // Acknowledgments
  if acknowledgements != none {
    align(start, 
      heading(
        level: 1,
        numbering: none,
        outlined: false,
        "Acknowledgements"
      )
    )
    set par(spacing: 0.6em, justify: true, first-line-indent: 1.5em, leading: 0.60em)

    align(start, 
      acknowledgements
    )

    pagebreak(weak: true)
  }


  // Table of contents
  // Outline customisation
  show outline.entry.where(level: 1): it => {
    let txt = it.element.body
    let nbr = it.prefix()
    let page_nbr = str(it.element.location().page()-6)
    v(25pt, weak:true)
    if txt == [References] {
      text(1em, strong({txt}))
      h(1fr)
      text(1em, strong({page_nbr}))
    } else if nbr in ([A], [B], [C], [D], [E], [F], [G], [H]) {
      text(1em, strong("Appendix " + nbr + " - " + {txt}))
      h(1fr)
      text(1em, strong({page_nbr}))
    } else {
      link(it.element.location(), strong([
        #nbr
        #h(15pt)
        #txt
        #h(1fr)
        #text(page_nbr)
      ]))
    }
  }
  // Outline customization
  show outline.entry.where(level: 2): it => {
    text(size: 1em, it)
  }
  show outline.entry.where(level: 3): it => {
    text(size: 1em, it)
  }
  set outline.entry(
    fill: repeat(h(2pt) + [.] + h(2pt))
  )

  pagebreak(weak: true, to:"odd")
  outline(depth: 3, indent: 25pt)
  
  set text(hyphenate: true, kerning: true, spacing: .35em)
  //pagebreak()
  //align(left,
  //  [
  //    == Terms
  //    - _Multimodal_: Multiple distinct types of data.
  //  ]
  //)
  
  pagebreak(to: "odd")

  // Main body

  set underline(offset: 2pt, stroke: 0.4pt)
  set page(numbering: "1")
  set align(top + left)
  //counter(page).update(1) // does not work??


  // Display the paper's contents.
  set par(spacing: 0.6em, justify: true, first-line-indent: 1.5em, leading: 0.60em)

  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      it
    } else {
      if it.element != none and it.element.numbering == "A" {
        //it.fields()
        if el.numbering == none {
          return "FAILED APPENDIX HAS NO SPECIFIC NUMBERING"
        }
        [Appendix #numbering(el.numbering,..counter(heading).at(el.location()))]
        //"Appendix"
      } else if it.element != none and it.element.has("level") and it.element.level == 1 {
        link(el.location())[Chapter #numbering(el.numbering,..counter(heading).at(el.location()))]
      }
      else {
        it
      }
    }
  }

  //show link: underline
  body

  pagebreak(to: "odd")

    if popular_science_summary != none{
  
      set page(
        margin: ( top: 18pt, left: 2cm, right: 2cm, ),
        columns: 2,
        footer: none,
      )
      
      place( top + left, float: true, scope: "parent", clearance: 1.5cm)[
        #stack(
          dir: ltr,
          spacing: 0pt,
          line(angle: 90deg, length: 3cm, stroke: 3pt + rgb(120,120,120)),
          [
            #align(left)[
              #h(10pt)
              #text( size: 9pt, upper[institutionen för datavetenskap | lunds tekniska högskola | presenterad 2025-01-24], )    
              #v(12pt)
              #h(-8pt)
              #text( size: 9pt, underline( offset: 4pt, [#upper[*examensarbete*] #title] ) )
              #v(3pt)
              #h(-8pt)
              #text( size: 9pt, underline( offset: 4pt, [#upper[*studenter*] #students.map(x => x.name).join([, ])] ) )
              #v(3pt)
              #h(-8pt)
              #text( size: 9pt, underline( offset: 4pt, [#upper[*handledare*] #supervisors.map(x => x.name).join([, ])] ) )
              #v(3pt)
              #h(-8pt)
              #text( size: 9pt, underline( offset: 4pt, [#upper[*examinator*] #examiner.name] ) )
            ]
          ]
        )
      ]
    
      place( top + left, float: true, scope: "parent", clearance: 2em, )[ 
        #set par(leading: 10pt)
        #text(fill: LTHbronze, size:25pt, font: fonts.sansserif, weight: 700, spacing: 5pt, 
        )[ #popular_science_summary.title ]
      ]
      place( top + left, float: true, scope: "parent", clearance: 2em, )[
        #line(length: 100%, stroke:0.8pt)
        #v(3pt)
        #par(justify: false)[ #text(size: 12pt)[ 
          #upper([populärvetenskaplig sammanfattning])
          #h(5pt) 
          *#students.map(x => x.name).join([, ])* 
        ]]
        #v(3pt)
        #line(length: 100%, stroke:0.8pt)
      ]
      
      place( top + left, float: true, scope: "parent", clearance: 2em, )[
        #par(justify: true, leading: 8pt)[ 
          #text(size: 14pt)[#popular_science_summary.abstract]
        ]
      ]
  
      par(justify: true)[
        #text(size: 11pt)[
          #popular_science_summary.body
        ]
      ]
    }
  }
  }
}