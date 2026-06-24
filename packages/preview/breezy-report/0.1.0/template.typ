// breezy-report: A clean colour-customisable engineering report template
// Author: Breanna Barraclough
// License: MIT-0

#let date = datetime.today()

#let breezy(
  semester: "Semester 1, 20##", 
  course-code: "ENGE500",
  course-name: "Course Name",
  title:"Report Title: The purpose of the report",
  student-ID:"########",
  author:"Author Name",
  bib-file:none,
  accent-colour:rgb("#300649"),
  table-header-text-colour:white,
  report
) = [
  #let in-body = state("in-body", false)

  #let headingFont = ("Montserrat","DejaVu Sans")

  #let secondaryColour = accent-colour.lighten(20%)

  #set par(leading: 0.75em, spacing: 1.2em)

  #show heading: it => block(
    above:1.5em,
    below:1em,
    text(font: headingFont,fill:accent-colour,it) 
  )

  #set heading(
    numbering: "1.",
  )

  #show raw.where(block:true): it => block(
    fill: accent-colour.lighten(90%),
    inset:12pt,
    radius:3pt,
    width:100%,
    text(fill:luma(15%),it)
  )

  #set text(font:"Georgia")
  #set line(length:100%)

  #set list(
    marker: (
      [#text(fill: accent-colour)[•]], 
      [#text(fill: accent-colour)[‣]], 
      [#text(fill: accent-colour)[–]]
    )
  )


  //Colours all supplements to the accent colour
  #show figure.caption: it => [
    #text(fill: accent-colour)[#it.supplement #it.counter.display(it.numbering)]#it.separator#it.body
  ]

  #show ref: it => text(fill: accent-colour, it)
  #show cite: it => text(fill: accent-colour, it)

  #show link: it => text(fill:accent-colour,it)

  // Provide custom supplements for each figure type
  #show figure.where(kind: image): set figure(supplement: [Fig.])
  #show figure.where(kind: table): set figure(supplement: [Tab.])
  #set math.equation(numbering: "(1)", supplement: [Eq.])
  #show figure.where(kind: "code"): set figure(supplement: [Snip.])

  // Custom table settings where the heading is bold, white, serif font. Table has dark gray borders and left-aligned text. 
  #show table.cell.where(y: 0): set text(
    weight: "bold",
    font:headingFont,
    fill: table-header-text-colour
  )
  #set table(
    stroke:0.5pt + accent-colour.lighten(50%),
    fill: (x,y) => {
      if y == 0 {accent-colour}
    },
    inset:5pt,
    align:left
  )

  // Page settings

  #set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),

    // Header design, applied to all but first page
    header: context {
      if (in-body.get()){
        [
          #place(
            top + left,
            dx: -2cm,
            dy: 0pt,
            block(
              width: 100% + 4.1cm,
              height: 1.75cm,
              fill: accent-colour
            )
          )
          #set text(fill: accent-colour.lighten(90%))
          #align(horizon)[
            #grid(
              columns: (1fr, auto),
              [
                #course-code 
                #{ let parts = title.split(":")
                  parts.at(0)
                }
              ],
              [
                ID: #student-ID
              ]
            )
          ]
        ]
      } else { [] }
    },
  )

  // Cover page

  #place(
    top+left,
    dx:-2cm,
    dy:-2.5cm,
    block(
      width:100% + 4.1cm,
      height:6cm,
      fill:accent-colour,
      inset:(x:2.5cm,y:1.5cm),
      align(bottom)[
        #text(size:20pt,weight:"bold",font:headingFont,fill:white)[#course-name]
        #v(-0.5em)
        #text(size:14pt,weight:"bold",font:headingFont,fill:accent-colour.lighten(70%))[#course-code]
      ]
    )
  )

  #align(center + horizon)[
    #text(size:12pt,font:headingFont,fill:accent-colour.lighten(25%))[#semester]
    #v(1em)
    #text(size:28pt,font:headingFont,fill:accent-colour,weight:"bold")[#title]
    #v(0.5em)
    #line(length:40%,stroke:accent-colour.lighten(60%))
  ]

  #place(
    bottom+left,
    dx:-2cm,
    dy:2.5cm,
    block(
      width:100% + 4.1cm,
      height:3.5cm,
      fill:accent-colour,
      inset:(x:2.5cm,y:1cm),
      align(horizon)[
        #grid(
          columns:(1fr,auto),
          align:horizon,
          [
            #text(size:14pt,font:headingFont,fill:white,weight:"bold")[#author]
            #v(-0.5em)
            #text(size:11pt,font:headingFont,fill:accent-colour.lighten(70%))[Student ID: #student-ID]
          ],
          [
          #text(size:11pt,font:headingFont,fill:accent-colour.lighten(94%))[ *Submission date:* \
            #date.display("[day]/[month]/[year]")]
          ]
        )
      ]
    )

  )

  #pagebreak()
  
  // Create page number in footer, removing title page from the count

  #counter(page).update(1)
  #set page(
    footer: context{
      align(center,
        text(fill:accent-colour)[-- #counter(page).get().first() --]
      )
    },
  )

#outline()

  // Only display the table of contents for tables, figures if there are any

  #context{
    
    if counter(figure.where(kind:image)).final().at(0) > 0 {
      outline(
        title:"List of Figures",
        target: figure.where(kind:image)
      )
    }

    if counter(figure.where(kind:table)).final().at(0) > 0 {
      outline(
        title:"List of Tables",
        target: figure.where(kind:table)
      )
    } 
  }

  #in-body.update(true)
  
  #pagebreak()
  #report
  #in-body.update(false)

  #if bib-file != none [
    #pagebreak()
    #bibliography(bib-file, style: "ieee", title: "References")
  ]
]