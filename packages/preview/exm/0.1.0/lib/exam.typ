#import "utils.typ": *

#let exam(doc, 
  courseid: "",
  coursename: "",
  school: "",
  semester: "",
  instructor: "",
  examtitle: "",
  date: "",
  length: "",
  blanks: ("Your Name", "Your Student ID"),
  instructions: "",
  extra: "",
  sols: false) = {
  set par(justify: true)
  set text(size: 10pt)
  show smallcaps: set text(font: "Libertinus Serif")

  // custom raw for print
  // https://github.com/typst/typst/issues/1331
  set raw(lang: "python")  // all are default python

  show raw: set text(size: 8pt)

  show raw: it => context {
    if docmode.get() == "screen" or it.theme == none { return it }

    let fields = it.fields()
    let text = fields.remove("text")
    _ = fields.remove("lines")
    fields.at("theme") = none
    raw(..fields, text)
  }

  // table styles
  show table.cell: set text(size: 9pt)
  show table.cell.where(y: 0): set text(size: 9pt, weight: 700)

  // enum styles, https://forum.typst.app/t/how-can-i-format-an-enums-numbering-without-overriding-the-numbering-style/3246
  set enum(
    full: true, 
    numbering: (..nums, last) => {
    text(
      weight: "bold", 
      numbering(("(a)","i.").at(nums.pos().len(), default: "1."), last)
    )
  }
  )

  set table(
    stroke: (x, y) => (
    left: if x == 0 { 0.5pt } else { 0pt },
    right: 0.5pt,
    top: if y <= 1 { 0.5pt } else { 0pt },
    bottom: 0.5pt,
  ),
    fill: (_, y) =>
    if calc.even(y) { luma(245) }
    else { white },
    inset: (x: 10pt, y: 5pt),
  )

  // format page (margins, set footer)
  set page(
    margin: (top: 1.65cm, bottom: 2.65cm, left: 1.65cm, right: 1.65cm),
    paper: "us-letter"
  )

  // set doc
  set document(
    title: examtitle + " " + coursename + " " + semester
  )

  box[
    #box(height: 35pt)[
      #line(length: 100%, stroke: 1pt)

      #v(-1pt)

      #set text(font: "Libertinus Serif")

      #grid(columns: (1fr, 3fr, 1fr), [
        #align(left)[
          #smallcaps[#text(courseid, size: 18pt, tracking: -0.04em)]
          #v(-16.5pt)
          #text(semester, size: 13pt, tracking: -0.02em)
        ]
      ],

        [
        #align(horizon)[
          #align(center)[
            #smallcaps[#text(coursename, size: 17pt, tracking: -0.03em, weight: 500)]
          ]
        ]
      ], 

        [
        #align(if instructor == "" { horizon } else { top })[
          #align(right)[
            #smallcaps[#text(examtitle, size: 18pt, tracking: -0.03em)]

            #if instructor != "" {
            v(-18pt)
            text(instructor, size: 12pt, tracking: -0.02em)
          }

            #if sols {
            v(-18pt)
            text("Solutions", size: 12pt, tracking: -0.02em, fill: colorblue)
          }
          ]
        ]
      ]
      )

      #v(-1pt)

      #line(length: 100%, stroke: 1pt)
    ]

    #v(4pt)

    #align(center)[
      #smallcaps[#text(date, tracking: 0.003em, size: 11pt)]
    ]

    #[
      #set par(justify: false)
      #set text(top-edge: 18pt)
  
      #for x in blanks [
        #smallcaps[Print] #x: #box(width: 1fr)[#line(stroke: 0.45pt, length: 100%)]
        
      ]

      #if blanks.len() > 0 [
        #v(8pt)
        #line(length: 100%, stroke: 0.75pt)
      ]
    ]

    #v(4pt)
    
    #smallcaps[#text("Instructions", size: 12pt, weight: 500, tracking: -0.03em)]

    #v(-6pt)

    #context[
    You have *#length* to complete the exam. There are *#section-counter.final().at(0) questions* and *#counter(page).final().at(0) pages* on this exam, including this cover page.
  ]

    #show table.cell: set text(size: 10pt)
    #context [#align(center)[
      #table(columns: section-counter.final().at(0) + 2,
        inset: (x: 6pt, y: 4pt),
        fill: white,
        [Question], ..(range(1, section-counter.final().at(0) + 1).map(x => [#x])), [Total],

        [Points], ..(section-points.final().map(x => [#x])), [#section-points.final().sum(default: 0)]
      )
    ]]

    #instructions

    #v(8pt)
    #line(length: 100%, stroke: 0.75pt)
    #v(4pt)

    #columns(2, gutter: 8pt)[
      #[
      #set text(tracking: -0.004em)
      #h(-1pt)
      Questions with *circular bubbles*: you may select only *1 choice*.
    ]

      #{ 
      let choices = ("Unselected option (completely unfilled)", "Single option selected (completely filled)")
      let items = choices.enumerate().map(((i, v)) => [
        #let fill = if i == 1 { black } else { white }
        #let strokecolor = black

        #box(height: 8pt,
          circle(radius: 4pt, stroke: stroke(thickness: 0.5pt, paint: strokecolor), fill: fill)
        )
        #h(5pt)
        #text(fill: strokecolor, v, baseline: -0.75pt)
      ])

      block(width: 100%)[
        #v(-2pt)
        #stack(dir: ttb, spacing: 9pt, ..items)
      ]
    }

      #colbreak()

      #[
      #set text(tracking: -0.016em)
      #h(-1pt)
      Questions with *square boxes*: you may select *1 or more choices*.
    ]

      #{ 
      let choices = ("You may select multiple squares", "as long as they are completely filled")
      let items = choices.enumerate().map(((i, v)) => [
        #let fill = if i == 1 or i == 0 { black } else { white }
        #let strokecolor = black

        #box(height: 8pt,
          square(size: 7.25pt, stroke: stroke(thickness: 0.5pt, paint: strokecolor), fill: fill)
        )
        #h(5pt)
        #text(fill: strokecolor, v, baseline: -1pt)
      ])

      block(width: 100%)[
        #v(-2pt)
        #stack(dir: ttb, spacing: 9pt, ..items)
      ]
    }
    ]

    You must fill in the bubbles *completely*. Ticks, crosses, or other check marks will *not* receive credit.

    #if extra != "" [
      #v(8pt)
      #line(length: 100%, stroke: 0.75pt)
      #v(4pt)

      #extra
    ]
  ]

  pagebreak()

  // pages after title page

  set page(
    margin: (top: 2.75cm, bottom: 2.6cm, left: 1.65cm, right: 1.65cm),
    footer: context [
    #line(length: 100%, stroke: 0.75pt)
    #v(-11pt)
    #smallcaps[#text(courseid + " " + semester, size: 10pt, top-edge: 1em)]
    #h(1fr)
    #smallcaps[#text(examtitle, size: 10pt, top-edge: 1em)] | #text(counter(page).display(), size: 10pt, top-edge: 1em)
  ],
    header: context [
    #text("Initials:", size: 10pt) #h(2pt) #box(width: 55pt, stroke: 0.5pt, height: 15pt, baseline: 4pt, outset: 0pt, inset: 0pt)
    #h(1fr)
    #text(instructor, size: 10pt, top-edge: 11pt)
    #v(-12pt)
    #line(length: 100%, stroke: 0.75pt)
    #v(0.15cm)
  ],
    paper: "us-letter"
  )

  blankpage()

  pagebreak()

  [ #doc ]
}

