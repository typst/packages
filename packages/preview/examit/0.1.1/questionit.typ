#import "utilities.typ": *

#let pointscounter = counter("totalpoints")
#let answerlinelength = 4cm

#let showquestion(
  pointsplacement: "right",
  number: "",
  dropboxes: none,
  question: none,
  points: none,
  unnumbered: false,
  bonus: false,
  spacing: 1em,
  answerbox: none,
  graph: none,
  numberline: none,
  choices: none,
  matching: none,
  horizontal: none,
  tf: false,
  sameline: false,
  writelines: none,
  answerline: true,
  ungraded: false,
  likert: none,
) = {
  // add this question's points to total
  if not bonus and not ungraded {
    pointscounter.update(t => t + points)
  }
  let boxspacing = 12pt
  let leftedge = -2.6em
  let scoreboxwidth = 1.7em
  let theboxes = place(
      if pointsplacement == "right" {
        right
      } else if pointsplacement == "left" {
        left
      },
      dx: if pointsplacement == "right" {
        16mm
      } else if pointsplacement == "left" {
        leftedge - boxspacing - scoreboxwidth
      },

      [
        #if not unnumbered [
        #box(stroke: none, [
          #set text(size: 8pt)
          #align(center + horizon, [#number])])
        ]
        #box(
          width: 1.2em,
          [
            #align( center + horizon,
              [
                #points#if bonus [\*]
              ]
            )
          ]
        )
        #box(
          width: scoreboxwidth,
          [])
      ]
    )
  let willdrop = if dropboxes != none {
    dropboxes
  } else if answerline {
    true
  } else if choices != none or matching != none or answerbox != none {
     false
  } else if sameline == false {true} // and answerline and writelines == -1 and answerbox != none

  if not willdrop and not ungraded [
    #set place(dy: -3.5pt)
    #set box(stroke: black + 0.2mm, height: 1.2em, baseline: -2em,)
    
    #theboxes
  ]
    
  [
    #if bonus [(Bonus)]
    #question

    // offset for answerbox
    #if answerbox != none [
      // #v(-3pt)
      #writingbox(height: answerbox)
      #v(-10pt)
    ]
    
    // blank lines for writing
    #if writelines != none and writelines > 0 [
      #v(1em)
      #for x in range(writelines) [
        #writingline()\
        \
      ]
      #v(-4em)
    ]

    #if sameline {
      v(-2em) // TODO: this for 
    }

    // \
    // polar or rectangular graph response
    #if graph != none {
      h(1fr)
      if graph == "polar" {
        align(right, graphpolar())
      // } else if graph == "numberline" {
      //   align(right, graphline())
      } else {
        v(-3em)
        align(right, graphgrid())
        v(-4em)
      }
        
    }

    // multiple choice or true/false
    #if choices != none {
      [
        #align(right, [
          #if horizontal == false {
            table(
              stroke: none,
              align: left,
              ..for choice in choices {
                (choicebox(choice),)
              }
            )
          } else {
            h(1fr)
            for choice in choices [
              #box([
                #h(1em)
                // #sym.circle.big
                // #box(width: 1em, height: 1em, stroke: 0.2mm)
                // // #sym.square.stroked
                // #h(0.5em) #box([#move(dy: -0.2em, [#choice])])
                #choicebox(choice)
              ])
            ]
            h(1em)
          }
        ])
      ]
    }
    #if matching != none {
      [
        #if horizontal == true {
          grid(
            // stroke: black,
            columns: (auto, )*matching.len(),
            // column-gutter: 5em,
            row-gutter: 1em,
            ..for pair in matching {
              (choicebox(pair.at(0)), )
            },
            ..for pair in matching.enumerate() {
              (
                [
                  #enum(
                    start: pair.at(0)+1,
                    numbering: "A.",
                    pair.at(1).at(1)
                  )
                ], 
              )
            },
          )
        } else {
          grid(
            columns: (auto, auto),
            column-gutter: 5em,
            row-gutter: 1em,
            ..for pair in matching.enumerate() {
              (
                choicebox(pair.at(1).at(0)),
                [
                  #enum(
                    numbering: "A.",
                    start: pair.at(0)+1,
                    [#pair.at(1).at(1)]
                  )
                ]
              )
            }
          )
        }
      ]
    }
    
    #if spacing != none {
      v(spacing, weak: false)
    }

    // answerline and dropped points boxes
    #if willdrop or answerline or numberline != none [
      #place(
        right + bottom,
        // dy: spacing,
        [
          #if answerline [
            #number. #box([#line(stroke: 0.4pt, length: answerlinelength, start: (4pt, 0pt))])
          ]
          #if numberline != none [
            #number. #box(graphline(width: numberline))
          ]
          #if willdrop and not ungraded [
            #set place(dy: -10.5pt)
            #set box(stroke: black + 0.2mm, height: 1.2em, baseline: -2em,)
            #theboxes
          ]
          // #v(1em)
        ]
      )
    ]
  ]
  block(width: 100%)
}

#let parsequestion(
  question,
  pointsplacement: "right",
  number: "",
  dropallboxes: none,
  defaultpoints: none,
) = {
  let exists(key) = {
    question.at(key, default: none) != none
  }
  if question.at("tf", default: false) {
    question.insert("choices", ([T],[F],))
  }
  
  if question.at("choices", default: none) != none and not exists("spacing") {
    // question.insert("sameline", true)
    question.insert("spacing", -0.5em)
  }
  if question.at("answerbox", default: none) != none and not exists("answerline") {
    question.insert("answerline", false)
    question.insert("spacing", 0pt)
  }
  // if question.at("numberline", default: none) != none {
  //   question.insert("graph", "numberline")
  // }
  
  let defaults = (
    "writelines": none,
    "tf": false,
    "sameline": if question.at("choices", default: none) != none and question.at("sameline", default: true) {true} else {false},
    "answerline": if question.at("choices", default: none) != none or question.at("graph", default: none) != none or question.at("numberline", default: none) != none or question.at("writelines", default: none) != none {false} else {true},
  )
  
  let args = (
    question: question.at("question", default: none),
    points: question.at("points", default: defaultpoints),
    unnumbered: question.at("unnumbered", default: false),
    bonus: question.at("bonus", default: false),
    spacing: question.at("spacing", default: 3em),
    answerbox: question.at("answerbox", default: none),
    graph: question.at("graph", default: none),
    numberline: question.at("numberline", default: none),
    choices: question.at("choices", default: none),
    matching: question.at("matching", default: none),
    horizontal: question.at("horizontal", default: none),
    writelines: question.at("writelines", default: none),
    answerline: question.at("answerline", default: defaults.answerline),
    sameline: question.at("sameline", default: defaults.sameline),
    ungraded: question.at("ungraded", default: false),
    dropboxes: question.at("dropboxes", default: dropallboxes),
    number: number,
    pointsplacement: pointsplacement,
    likert: question.at("likert", default: none),
  )
  box(showquestion(..args))
}
