#let title-state = state("title", "")

#let total-points = counter("points")


/// Initialize an exam with a show rule.
///
/// Example:
/// ```typst
/// #show: exam.init
/// ```
///
/// - body (content): The body content of the exam.
#let init(body) = {
  set page(margin: 40pt)
  set text( 
    font: ("Roboto"),
    size: 11pt,
    fill: black, 
    weight: "regular"
  )
  set raw(theme: "../themes/codepoint.tmTheme")  
  show raw: set text(font: ("Courier", "Courier Prime"), weight: "bold", size: 10pt)

  set par(spacing: 1.2em)
  
  body
}


#set page(header: [
  #context title-state.get()
])

#let setup(title) = {
  assert(
    type(title) == str or type(title) == content, 
    message: "expected title to be string or content, but received " + str(type(title))
  )


  title-state.update(title)
}

/// header: Render a header for the exam, will check total number of points 
/// Usually done via something like:
/// ```typst
/// #exam.setup("CS-1181 Quiz #1")
/// #set page(header: [
///   #context e.title-state.get()
/// ])
/// #e.header()
/// ```
/// - out-of (none, int): Maximum points the exam is taken out of
#let header(out-of: none) = [
  #assert(
    type(out-of) == none or type(out-of) == int,
    message: "Expected out-of to be none or int, but received " + str(type(out-of))
  )
  
  #context {
    let max-earnable = total-points.final().at(0)
    
    // typst supports conditional assignments :)
    let max-scorable = if (out-of != none) { 
      out-of 
    } else { 
      max-earnable
    }

    grid(
      columns: (1fr, 1fr),
      align(left)[
        #text(size: 17pt)[
          Name: #box(width: 1fr, move(dy: 2pt, line(length: 100%, stroke: 1pt)))
        ]
      ],
      align(right)[
        #text(size: 17pt)[
          #grid(
            rows: (0pt, 20pt),
            align(right)[
              // need a box wrap 
              #box(width: 40pt, move(dy: 2pt, line( 
                length: 130%, stroke: 0.7pt
              )))
              #("/ " + str(max-scorable))
            ],
            if out-of != none {
              v(1.2em)
              "Max: " + str(max-earnable) + " pts"
            }
          )
        ]
      ]
    )
  }
]

#let spacer() = {
  v(10pt)
}


#let cur-question = state(
  "num-qs", 1
)


/// question: Create a generic question
/// - body (content, str): Question Body
/// - points (int): Number of points the question is worth
#let question(body, points: 1) = context {
  assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )

  assert(
    type(points) == int,
    message: "Expected points to be int, but received" + str(type(points))
  )
  
  cur-question.update(n => n + 1)
  total-points.update(p => p + points)
  let qnum = cur-question.get()
  
  block(width: 100%, breakable: true, inset: (bottom: 0.5em))[
    #grid(
      columns: (20pt, 1fr),
      column-gutter: 8pt,
      text(weight: "bold")[#qnum.],
      [#body #h(5pt) (#points pts)]
    )
  ]
}

#let c = counter("letter")

#let _answer-indents = (1fr, 10fr, 1fr)


/// num-to-fr-units: Map a number into a tuple of 1fr units primarily used to make optional column passing to #multiple-choice easier
/// ```
/// input = 3 -> output = (1fr, 1fr, 1fr)
/// input = 5 -> output = (1fr, 1fr, 1fr, 1fr, 1fr)
/// ```
/// - num (int): number to map
/// -> array Array of num fr units

#let _num-to-fr-units(num) = {
  range(num).map(i => 1fr)
}



/// multiple-choice: Create a multiple choice question
/// - body (content, str): Body of question
/// - points (int): `1` Points the question is worth
/// - cols (int, array): `1` Number of columns to render the answer. Pass an array of units for specific spacing e.g. (1fr, 1fr, 12pt)
/// - ..answers (arguments): The options
#let multiple-choice(body, points: 1, cols: 1, ..answers) = {

  assert(
    type(body) == content or type(body) == str,
    message: "Expected body to be content or str, but received" + str(type(body))
  )

  assert(
    type(points) == int,
    message: "Expected points to be int, but received" + str(type(points))
  )

  assert(
    type(cols) == int,
    message: "Expected cols to be int, but received" + str(type(cols))
  )

  
  assert(
    answers.pos().len() > 0,
    message: "Expected at least one value in answers, but received 0"
  )

  assert(
    answers.pos().all(cur => {
      type(cur) == content or type(cur) == str
    }),
    // would like to say which value caused failure here, but its a little hard with the arr.all func used
    message: "Expected all answers to be content or str"
  )



  let cols-type = type(cols)

  block[
    #c.update(0)
    #question(body, points: points)
    #v(-0.4em)
    #grid(
      columns: _answer-indents,
      rows: (auto),
      "",
      block[
        #grid(
          columns: {
            if(cols-type) == int {
              _num-to-fr-units(cols)
            } else {
              cols
            }
          },
          rows: auto,
          column-gutter: 5pt,
          row-gutter: 15pt,
          ..answers.pos().map(answer => {
            c.step()
            block[
              #context c.display("a"). #" " #answer
            ]
          })
        )
      ],
      "",
    )
  ]
}


/// https://xkcd.com/221/
/// Not cryptographically secure
/// - arr (array): The array
/// - seed (int): The seed
/// -> array
#let _shuffle(arr, seed: 4) = {

  // doing assertions for private functions assuming no public version exists
  assert(
    type(arr) == array,
    message: "Expected arr to be of type array, but received " + str(type(arr))
  )

  assert(
    type(seed) == int,
    message: "Expected seed to be of type int, but received " + str(type(seed))
  )

  for i in range(arr.len()) {
    let rnd-index = calc.rem(i * seed, arr.len())
    
    // swap via destructuing
    (arr.at(i), arr.at(rnd-index)) = ((arr.at(rnd-index), arr.at(i)))
  }

  arr
}



#let _matching(q-body, points, seed: 4, pairs) = {
  // condense each pair down into just each side => then shuffle
  let left-opts = _shuffle(
    pairs.map(pair => pair.at(0)),
    seed: seed
  )

  let right-opts = _shuffle(
    pairs.map(pair => pair.at(1)),
    seed: seed + 1,
  )
  

  block[
    #c.update(0)
    #question(q-body, points: points)
    #spacer()
    #grid(
      columns: (1fr, 4fr, 7fr),
      "",
      align(left)[
        #for left-item in left-opts {
          block[
            #box(width: 40pt, move(dy: 2pt, line(length: 85%, stroke: 0.5pt))) #left-item
            #spacer()
          ]
        }
      ],
      align(left)[
        #for right-item in right-opts {
          block[
            #c.step()
            #context c.display("a"). #right-item
            #spacer()
          ]
        }
      ]
    )
  ]
}

#let _validate-pairs(pairs) = {
  assert(type(pairs) == array, message: "Expected pairs to be an array, got " + str(type(pairs)))
  
  for pair in pairs {
    assert(type(pair) == array and pair.len() == 2, message: "Every elem. in pairs must be an array of exactly 2 elements: (left, right)")
  }
}

/// matching: Create a matching question e.g.
/// ```
/// Cat      A. Canine
/// Dog      B. Feline
/// Fish     C. Aquatic Creature
/// ```
/// - q-body (content, str): body of question to ask
/// - points (none, int): = none points the question is worth. Once wrapped, this will default to the length of pairs
/// - seed (int): = 4 Random seed used for shuffling each side
/// - pairs (array): An array containing pairs of answers/definitions
#let matching(q-body, points: none, seed: 4, pairs) = {
  assert(
    type(q-body) == content or type(q-body) == str,
    message: "Expected q-body to be content or str, but received" + str(type(q-body))
  )

  assert(
    type(points) == int or type(points) == none,
    message: "Expected points to be int or none, but received" + str(type(points))
  )

  assert(
    type(seed) == int,
    message: "Expected seed to be of type int, but received " + str(type(seed))
  )

  // points will end up defaulting to len of pairs if not passed
  assert(points == none or type(points) == int, message: "Expected points to be integer or none, received: " + str(type(points)))
  assert(type(seed) == int, message: "Expected seed to be integer, received: " + str(type(seed)))
  
  _validate-pairs(pairs)

  let real-points = -1

  if(points == none){
    real-points = pairs.len()
  } else {
    real-points = points
  }

  _matching(q-body, real-points, seed: seed, pairs)
}

#let tf-block(q-body, points: 1, ..statements) = {

  assert(
    type(q-body) == content or type(q-body) == str,
    message: "Expected q-body to be content or str, but received" + str(type(q-body))
  )

  assert(
    type(points) == int,
    message: "Expected points to be int, but received" + str(type(points))
  )

    assert(
      statements.pos().all(cur => {
        type(cur) == content or type(cur) == str
      }),
      message: "Expected all statements to be content or str"
    )




  let num = counter("I")
  num.step() 
  block[
    #question(q-body, points: points)
    #v(-0.4em)
    #for statement in statements.pos() {
      block[
        #grid(
          columns: (42pt, 18pt, 9fr, 1fr),
          rows: (auto),
          "",
          block[
            #set text(font: "Libertinus Serif")
            #context num.display("I").
            #context num.step()
          ],
          statement,
          box(width: 1fr, move(dy: 2pt, line(length: 70%, stroke: 0.5pt)))
        )
      ]
    }
  ]
}

/// short-answer: Create a short answer question
/// - q-body (content, str): Question Body
/// - lines (int): = 1 lines of space to give the user, renders as actual lines
/// - points (int): = 1 points the question is worth
#let short-answer(q-body, lines: 1, points: 1) = {

  assert(
    type(q-body) == content or type(q-body) == str,
    message: "Expected q-body to be content or str, but received" + str(type(q-body))
  )

  assert(
    type(lines) == int,
    message: "Expected lines to be int, but received" + str(type(points))
  )

  assert(
    type(points) == int,
    message: "Expected points to be int, but received" + str(type(points))
  )





  question(q-body, points: points)
  
  // you don't need the full spacing from the question before the first line
  v(-10pt)
  block(width: 100%, inset: (left: 20pt))[
    #for _ in range(lines) {
      // line spacing
      v(25pt) 
      line(length: 90%, stroke: 0.5pt)
    }
  ]
}


/// free-response: Create a free response question2
/// - q-body (content, str): Question Body
/// - lines (int): = 1 lines of space to give the user, renders as empty space
/// - points (int): = 1 points the question is worth
#let free-response(q-body, lines: 1, points: 1) = {

  assert(
    type(q-body) == content or type(q-body) == str,
    message: "Expected q_body to be content or str, but received" + str(type(q-body))
  )

  assert(
    type(lines) == int,
    message: "Expected lines to be int, but received" + str(type(points))
  )
  
  assert(
    type(points) == int,
    message: "Expected points to be int, but received" + str(type(points))
  )

  question(q-body, points: points)

  // i did not know you could just multiply units like that
  v(15pt * lines)
}

/// code-block: Create a code block formatted for exams
/// Wraps in box to the edge of the code, can add white space if need it to be longer
/// - include-line-numbers (boolean): Boolean param for whether line numbers should be included in the output
/// - raw-code (content): raw code block
#let code-block(include-line-numbers: true, raw-code) = {
  assert(
    type(raw-code) == content,
    message: "Expected raw-code to be content, but received " + str(type(raw-code))
  )

  let lines = raw-code.text.split("\n")  
  
  // fold to flat array of cells, 
  // (1, firstLine, 2, secondLine, etc
  // then spread to table values later 
  let table-values = ()
  // pythonic enumerate :)
  for (i, line) in lines.enumerate() {
    // push line number
    // table_values.push(text(fill: gray)[#(i + 1)]) // start at 1 instead of 0
    if include-line-numbers {
      table-values.push(raw([#(i + 1)].text))
      
    }

    // converting to raw like this loses the language context, so copy it to each line
    table-values.push(raw(line, lang: raw-code.lang)) 
  }

  // wrap in a box to avoid having conditional stroke

  let desired-columns = (auto)
  if include-line-numbers {
    desired-columns = (auto, auto)
  } 

  block(
    stroke: rgb("#d9d9d9"),
    inset: 2pt, // need some extra internal padding
    table(
      columns: desired-columns,
      stroke: none,
      inset: (x: 5pt, y: 3pt),
      ..table-values
    )
  )
}



