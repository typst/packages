// breezy-report: A clean colour-customisable engineering report template
// Author: Breanna Barraclough
// License: MIT-0

#let date = datetime.today()

#let breezy(
  semester: "Semester 1, 20##", 
  courseCode: "ENGE500",
  courseName: "Course Name",
  title:"Report Title: The purpose of the report",
  studentID:"########",
  author:"Author Name",
  bibFile:none,
  accentColour:rgb("#300649"),
  tableHeaderTextColour:white,
  report
) = [
  #let in-body = state("in-body", false)

  #let headingFont = ("Montserrat","DejaVu Sans")

  #let secondaryColour = accentColour.lighten(20%)

  #set par(leading: 0.75em, spacing: 1.2em)

  #show heading: it => block(
    above:1.5em,
    below:1em,
    text(font: headingFont,fill:accentColour,it) 
  )

  #set heading(
    numbering: "1.",
  )

  #show raw.where(block:true): it => block(
    fill: accentColour.lighten(90%),
    inset:12pt,
    radius:3pt,
    width:100%,
    text(fill:luma(15%),it)
  )

  #set text(font:"Georgia")
  #set line(length:100%)

  #set list(
    marker: (
      [#text(fill: accentColour)[•]], 
      [#text(fill: accentColour)[‣]], 
      [#text(fill: accentColour)[–]]
    )
  )


  //Colours all supplements to the accent colour
  #show figure.caption: it => [
    #text(fill: accentColour)[#it.supplement #it.counter.display(it.numbering)]#it.separator#it.body
  ]

  #show ref: it => text(fill: accentColour, it)
  #show cite: it => text(fill: accentColour, it)

  #show link: it => text(fill:accentColour,it)

  // Provide custom supplements for each figure type
  #show figure.where(kind: image): set figure(supplement: [Fig.])
  #show figure.where(kind: table): set figure(supplement: [Tab.])
  #set math.equation(numbering: "(1)", supplement: [Eq.])
  #show figure.where(kind: "code"): set figure(supplement: [Snip.])

  // Custom table settings where the heading is bold, white, serif font. Table has dark gray borders and left-aligned text. 
  #show table.cell.where(y: 0): set text(
    weight: "bold",
    font:headingFont,
    fill: tableHeaderTextColour
  )
  #set table(
    stroke:0.5pt + accentColour.lighten(50%),
    fill: (x,y) => {
      if y == 0 {accentColour}
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
              fill: accentColour
            )
          )
          #set text(fill: accentColour.lighten(90%))
          #align(horizon)[
            #grid(
              columns: (1fr, auto),
              [
                #courseCode 
                #{ let parts = title.split(":")
                  parts.at(0)
                }
              ],
              [
                ID: #studentID
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
      fill:accentColour,
      inset:(x:2.5cm,y:1.5cm),
      align(bottom)[
        #text(size:20pt,weight:"bold",font:headingFont,fill:white)[#courseName]
        #v(-0.5em)
        #text(size:14pt,weight:"bold",font:headingFont,fill:accentColour.lighten(70%))[#courseCode]
      ]
    )
  )

  #align(center + horizon)[
    #text(size:12pt,font:headingFont,fill:accentColour.lighten(25%))[#semester]
    #v(1em)
    #text(size:28pt,font:headingFont,fill:accentColour,weight:"bold")[#title]
    #v(0.5em)
    #line(length:40%,stroke:accentColour.lighten(60%))
  ]

  #place(
    bottom+left,
    dx:-2cm,
    dy:2.5cm,
    block(
      width:100% + 4.1cm,
      height:3.5cm,
      fill:accentColour,
      inset:(x:2.5cm,y:1cm),
      align(horizon)[
        #grid(
          columns:(1fr,auto),
          align:horizon,
          [
            #text(size:14pt,font:headingFont,fill:white,weight:"bold")[#author]
            #v(-0.5em)
            #text(size:11pt,font:headingFont,fill:accentColour.lighten(70%))[Student ID: #studentID]
          ],
          [
          #text(size:11pt,font:headingFont,fill:accentColour.lighten(94%))[ *Submission date:* \
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
        text(fill:accentColour)[-- #counter(page).get().first() --]
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

  #if bibFile != none [
    #pagebreak()
    #bibliography(bibFile, style: "ieee", title: "References")
  ]
]