#import "@preview/cetz:0.2.2"
#import "utilities.typ": *
#import "questionit.typ": parsequestion, showquestion, pointscounter

#let totalpoints = context pointscounter.final()

#let examit(
  body,
  title: "Default Title",
  subtitle: none,
  date: none,
  margin: (left: 18mm, right: 25mm, top: 16mm, bottom: 25mm),
  cols: 1,
  gutter: 1.3em,
  questions: none,
  instructions: none,
  extrapicturebox: true,
  dropallboxes: none,
  namebox: "left",
  pointsplacement: "right",
  answerlinelength: 4cm,
  defaultpoints: none,
  lang: "en",
  font: "Linux Libertine",
) = {
  // Set the document's basic properties.
  set document(title: title)
  let gradetablewidth = 16em
  let tableoffset = 5mm
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
    footer: context [
      #set text(8pt)
      #grid(
        // stroke: black+0.2mm,
        columns: (1fr, 1fr, 1fr),
        // rows: (2em),
        align: (center, center+horizon, right+horizon),
        [],
        [
          Page #counter(page).display(
            "1 of 1",
            both: true,
          )
          #label("page"+str(here().page()))
          // Points so far: #pointscounter.at(<page1>)
        ],
        move(
          dx: 4em, [
            Points on this page: #h(1em)
            #box( baseline: 0pt, stroke: black+0.2mm, outset: 6pt, [
              #let prev2 = counter("pre2")
              #context (pointscounter.get().first() - prev2.get().first())#prev2.update(pointscounter.get().first())
            ])
            #h(12pt)
            #box( baseline: 0pt, stroke: black+0.2mm, outset: 6pt, [#hide("123")])
          ]
        )
      ),
      
      // #totalpages.step()
    ],
    footer-descent: 40%,
    background: {
      context if here().page() == 1 [
        #align(
          // top,
          top + right,
          move(
            dx: -tableoffset, 
            dy: tableoffset, 
            [
              #let prev = counter("pre")
              #block(
                // stroke: black,
                width: gradetablewidth, [
                  #table(
                    columns: (auto, auto, auto),
                     // inset: 1em,
                    align: center,
                    stroke: black+0.2mm,
                    [*Page*],[*Possible*],[*Score*],
                    ..for x in range(1, counter(page).final().first()+1) {
                      (
                        [
                          #x
                        ],
                        [
                          #context (pointscounter.at(label("page"+str(x))).first() - prev.get().first())
                          #prev.update(pointscounter.at(label("page"+str(x))).first())
                        ],
                        []
                      )
                    },
                    [_Total:_],[*#pointscounter.final().first()*]
                  )
                ]
              )
            ]
          )       
        )
      ]
      context if calc.odd(here().page()) == true {
        if namebox == "left" {
          place(
            left+top,
            dx: -7cm+0.5cm,
            dy: 0cm+0.5cm,
            rotate(
              -90deg,
              origin: top+right,
              box(
                width: 7cm, height: 1cm, stroke: black + 0.2mm, [
                  #text(
                    size: 7pt, baseline: 1cm-1em, style: "italic", [#h(3pt)Full Name]
                  )
                ]
              )
            )
          )
        } else if namebox == "top" {
          place(
            left+top,
            dx: 0cm+0.5cm,
            dy: 0cm+0.5cm,
            box(
              width: 7cm, height: 1cm, stroke: black + 0.2mm, [
                #text(
                  size: 7pt, baseline: 1cm-1em, style: "italic", [#h(3pt)Full Name]
                )
              ]
            )
          )
        }
      }
    }
  )
  // set text(font: "Linux Libertine", lang: "en")
  // set text(font: "New Computer Modern")
  set text(font: font, lang: lang)

  // let pagewidth = layout(x => {length(x.width)})

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
    // = #title
    #if subtitle != none [
      #v(-0.3em)
      #block(text(weight: 700, 1.25em, subtitle))
      // == #subtitle
    ]
    #v(1em, weak: true)
    #date
  ]

  // Main body.
  // set par(justify: true)

  if instructions != none {
    layout(x => [#block(stroke: none, width: x.width - gradetablewidth + tableoffset +3em, [#instructions])])
  }
  
  columns(cols, gutter: gutter, {
    

  let questioncounter = counter("question")
  let subquestioncounter = counter("subquestion")
  set enum(full: false, numbering: (n) => {
    counter("questioncounter").update(n)
    numbering("1.a.", n)
  })
  let defaultspacing = none

  show ref: it => {
    if it.element.func() == figure and it.element.supplement == [examit] {
      questioncounter.at(locate(it.target)).first()
    } else {
      it
    }
  }
  if questions != none [
    #for question in questions [
      #if question.at("spacing", default: none) != none and question.at("question", default: none) == none {
        defaultspacing = question.spacing
      }
      #if question.at("spacing", default: none) == "reset" {
        let defaultspacing = none
      }
      #if defaultspacing != none and question.at("spacing", default: none) == none {
        question.insert("spacing",defaultspacing)
      }
      #if question.at("colbreak", default: false) or question.at("pagebreak", default: false) or question.at("break", default: false) {
        colbreak()
      }
      #if question.at("header", default: none) != none {
        [
          = #question.header
        ]
      }
      #if question.at("subheader", default: none) != none {
        [
          == #question.subheader
        ]
      }
      #if question.at("subsubheader", default: none) != none {
        [
          === #question.subsubheader
        ]
      }
      #if question.at("question", default: none) != none [
        #questioncounter.step()
        #context [
          #set enum(start: int(questioncounter.get().first()))
          #if question.at("unnumbered", default: false) [
            #parsequestion(question, number: questioncounter.display(), dropallboxes: dropallboxes, defaultpoints: defaultpoints)
          ] else [
            + #parsequestion(question, number: questioncounter.display(), dropallboxes: dropallboxes, defaultpoints: defaultpoints)
            #if question.at("label", default: none) != none [
              #place[
                #figure([], supplement: "examit")
                #label(question.label)
              ]
            ]
          ]
        ]
      ] else if question.at("answerbox", default: none) != none [
        #writingbox(height: question.answerbox)
      ]
      #if question.at("subquestion", default: none) != none [
        #subquestioncounter.update(0)
        #context [
          #set enum(start: int(questioncounter.get().first()), numbering: "1.a.")
          #enum([
            #for subquestion in question.subquestion [
              #subquestioncounter.step()
              #set enum(start: int(subquestioncounter.get().first()), numbering: "1.a.")
              #enum([
                #q(subquestion, number: subquestioncounter.display("a"), dropallboxes: dropallboxes)
              ])
            ]
          ])
        ]
      ]
    ]
  ]
  })

  if extrapicturebox {
    v(1fr)
    "If you have time, draw a picture here."
    writingbox(height: 1in)
  }
  
  body
}

