// Based on Examify by tarunjana, MIT License
// Source: https://github.com/tarunjana/examify
// Typst Universe: https://typst.app/universe/package/examify

// ---------------- VARIABLE DEFS
#let points = counter("points")
#let current_page_points = counter("current_page_points")
#let qnumber = counter("qnumber")
#let subqnumber = counter("subqnumber")

//#let headercount = state("headercount", counter("headercount"))
#let headercount = state("headercount", counter("headercount"))

#let page_point_counts = state("page_point_counts", (counter( "page_count" )))
#let header_point_counts = state("header_point_counts", (counter( "header_count" )))

#let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#let lalphabet = "abcdefghijklmnopqrstuvwxyz"

#let sub-question-format = "a"

#let should-show-solutions = state("should-show-solutions", false)

#let show-solutions() = {
  context {should-show-solutions.update(true)}
}

#let A = 1
#let B = 2
#let C = 3
#let D = 4
#let E = 5
#let F = 6
#let G = 7
#let H = 8
#let I = 9
#let J = 10

#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}

#let dh-sheets(
  paper-size: "us-letter",
  fonts: "New Computer Modern",
  language: "EN",
  institute: none,
  author: none,
  exam-name: none,
  date: [],
  good-luck: [Best of luck!#v(3em)],
  end-of-exam: [End of exam.],
  upper-left-label: [],
  show-total-points: true,
  show-per-page-points: true,
  per-page-point-label: [Scorers only],
  show-page-count: true,
  page-count-label: "Pg. 1 of 1",
  instructions: [],
  student-fields: [],
  content,
) = {
  // ------------------- DOCUMENT SETUP
  set document(
    title: [#exam-name - #institute],
    author: author,
    date: auto,
  )

  set page(
    paper: paper-size,
    
    
    
    footer: {
      context [
        #let tt = here().position().page
        #page_point_counts.update(old => (old, (counter( "page_count" + str(tt) ))).flatten())
      ]

      
      context [
        #line(length: 100%)
        // Name, Contact Details & Page Number at footer
        #if counter(page).get().first() == 1 [
          #align(center)[
            #grid(columns: 3, [#v(-0.07em)#sym.diamond.filled],
              [#h(0.3em)This exam written by #author#h(0.3em)],
              [#v(-0.07em)#sym.diamond.filled])
          ]
        ] else [
          #grid(
            columns: (7em, 1fr, 6em),
            align: (left, center, right),
            date,
            if author != none {
              grid(columns: 3, [#v(-0.07em)#sym.diamond.filled],
              [#h(0.3em)#author#h(0.3em)], [#v(-0.07em)#sym.diamond.filled])
            },
            if show-page-count {
              counter(page).display(
                page-count-label,
                both: true,
              )
            },
          )
        ]
      ]
    },
    
    
    
    header: [
      #context if counter(page).get().at(0) > 1 [
        #grid(columns: (20em, 1fr, 20em), align: (left, center, right),
        [#upper-left-label#v(1.3em)],
        [],
        [
          #if show-per-page-points {
            grid(
              columns: (10em),
              stroke: 0.5pt,
              inset: 0.3em,
              align: center,
              per-page-point-label,
              [#v(0.5em)Points: #h(3em)/ #page_point_counts.get().at(here().position().page -1).final().first() #v(0.5em)]
            )
          }
        ])
      ] else if show-per-page-points [
        #align(right)[
          #grid(
                columns: (13em),
                stroke: 0.5pt,
                inset: 0.5em,
                align: center,
                per-page-point-label,
                [#v(0.5em)Total points: #h(3em) /#points.final().at(0)#v(0.5em)]
              )
        ]
      ]
    ],
    margin: (
      top: 3.5cm
    )
  )
  
  set text(
    font: fonts,
    size: 12pt,
    lang: language,
  )

  align(horizon)[

    // Numbered list style
    #set enum(numbering: "1.i)")

    // Paragraph settings
    #set par(justify: true)

    // Institute name
    #if institute != none {
      grid(
        columns: 1fr,
        align: (center),
        text(weight: "extrabold", size: 25pt, [#sym.chevron.l.double #institute #sym.chevron.r.double]),
      )
      v(2em)
    }

    // Exam name
    #if exam-name != none {
      grid(
        columns: 1fr,
        align: (center),
        text(weight: "bold", size: 20pt, exam-name),
      )
      v(1em)
    }
    #context if should-show-solutions.final() {
      grid(
        columns: 1fr,
        align: (center),
        text(weight: "bold", size: 24pt, [SOLUTIONS]),
      )
      v(1em)
    }

      #align(center)[
        #text(weight: "bold", size: 12pt, context [Feb 20 2027])
      ]
      #if show-total-points {
        align(center)[
          #text(weight: "bold", size: 16pt, context [#points.final().at(0) points total])
        ]
      }
    
    #context if not should-show-solutions.get() {
      v(1em)
      student-fields
      v(1em)
    }

    // Horizontal line
    #line(length: 100%)
    
    #v(-4.5em)
    #block(inset: 5em, instructions)
    
    #v(-4em)
    #line(length: 100%)
    
    #v(3em)
    #align(center)[#good-luck]
  ]

  pagebreak()

  // Main content
  set align(horizon)
  content
  
  v(5em, weak: false)
  
  align(center)[#end-of-exam]
  
}

// -------------------------------- FUNCTION DEFS

// Reset subquestion counter such that the next question moves onto a new full question, even if it also has subparts.
#let newsubquestion() = context {
  subqnumber.update(1)
}

// Internal function to display the question number trunk, for example "2(a)."
#let addqnumber(pts, is-sub-question: false, sub_question_formatting: none) = {
  context if not is-sub-question or (is-sub-question and subqnumber.get().at(0) == 1) {
    context qnumber.update(t => t+1)
  }

  if not is-sub-question {
    context subqnumber.update(1)
  }
  
  // There's a zero-width     || character there. It's required.
  
  // Only display points marker if question is worth anything.
  if is-sub-question {
   [#(context qnumber.display())‎(#(context subqnumber.display(if sub_question_formatting == none {sub-question-format} else {sub_question_formatting}))). ]

    context subqnumber.step()
  } else {
    [#(context qnumber.display()). ]
  }
  if pts > 0 {
    [(#pts pts)]
  }
  
  points.update(p => p + pts)
  // current_page_points.update(p => p + pts)
  context page_point_counts.get().last().update(p => p + pts)
  context header_point_counts.get().last().update(p => p + pts)
}

// Displays a multiple choice question.
#let mcq(options, pts, is-sub-question: false, sub_question_formatting: none, solution: 0) = {
[#grid(
    columns: {(7em,) + (1em, 3.5em,) * options + (10em,)},
    [#addqnumber(pts, is-sub-question: is-sub-question, sub_question_formatting: sub_question_formatting)],
    ..range(options*2).map((i) => if calc.rem(i,2) == 0 [#v(-0.1em)#context if calc.floor(i/2) == solution -1 and should-show-solutions.get() {$square.filled$} else {$square.stroked$}] else [#(alphabet.at(calc.floor((i -1)/2)))])
  )]
}

// Displays many multiple choice questions, with solutions given in `solutions`
#let mcqs(options, pts, solutions) = {
  for solution in solutions {
    mcq(options, pts, solution: solution)
  }
}

// Displays an open-ended question.
#let openended(height, pts, sameline: false, label: [], is-sub-question: false, sub_question_formatting: none, solution: []) = {
  // [#(context qnumber.get().at(0)+1). (#pts pts)]
  if sameline {
    height = 2em
    grid(
      columns: (5.5em + if is-sub-question {2em}, 1fr),
      [#addqnumber(pts, is-sub-question: is-sub-question, sub_question_formatting: sub_question_formatting)],
      [#box(width: 1fr, height: height, stroke: black)]
    )
  } else {
    block(breakable: false,
      grid([
        #addqnumber(pts, is-sub-question: is-sub-question, sub_question_formatting: sub_question_formatting)
        #if label != [] {
          h(1em)
          label
        }
        #v(1em)
      ],[
        #box(width: 1fr, height: height, stroke: black, inset: 0.8em,)[#context {if should-show-solutions.get() [*Solution:* \ 
        #solution]}]
      ])
    )
  }
}

#let header(label, show-total-points: false) = {
  context {
    headercount.get().update(t => t+1)
    
    let tt = here().position().page
    header_point_counts.update(old => (old, (counter( "header_count" + str(tt) ))).flatten())
  }
  context {
    [= $section$#{headercount.get().display("A")}: #label #{if true {[(#{header_point_counts.get().last().final().at(0)} points)]}}]
  }
  qnumber.update(0)
  v(1em)
}

#let repeat(n, content) = {
  let i = 0
  while i < n {
    content
    i = i + 1
  }
}
