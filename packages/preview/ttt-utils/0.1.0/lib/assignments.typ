#import "components.typ": point-tag, checkbox, caro, lines as _lines
#import "helpers.typ": if-auto-then
#import "random.typ": shuffle

// States
#let _solution = state("ttt-solution", false);
#let _answer_field = state("ttt-auto-field", _lines(2))

/// wrapper for updating the `_answer_field` state
///
/// - field (content): Content to be shown if @answer field parameter is `auto` 
/// -> content (state-update)
#let set-default-answer-field(field) = _answer_field.update(field)

// Counters
#let _question_counter = counter("ttt-question-counter");

/// Wrapper to reset the `_question_counter` back to zero
#let reset-question-counter() = { _question_counter.update(0) }

// Labels
#let _question_label = label("ttt-question-label")


/// Add the current assignment number
///
/// - style (string): style of the number gets passed to typst `numbering` function. default: "1."
/// -> content
#let a-nr(style: "1.") = context numbering(style, _question_counter.get().first())

/// Add the current question number
///
/// - style (string): style of the number gets passed to typst `numbering` function. default: "a)"
/// -> content
#let q-nr(style: "a)") = context numbering(style, _question_counter.get().last())




/// the assignment environment state
/// should contain `none` or an `integer` with the current assignment number
#let _assignment_env = state("ttt-assignment-state", none)

/// Starts a new assignment environment.
/// All following questions will be grouped into this assignment until a `end-assignment` statement occurs.
#let new-assignment = {
  _question_counter.step(level: 1)
  context _assignment_env.update(_question_counter.get().first())
}

/// Ends the assignment environment.
/// All following questions will be treated as stand alone questions. 
#let end-assignment = _assignment_env.update(none)

/// Wrapper to check if the assignment environment is active.
#let is-assignment() = {
  _assignment_env.get() != none
}

/// Add an assignment environment. 
/// By default this adds the current assignment number up front. 
///
/// Example:
/// 
/// ```typ
/// #assignment [
///   Answer the questions
///
///   #question[This will be question a)]
///   #question[This will be question b)]
/// ]
/// ```
/// - body (content): the content to be displayed for this assignment
/// - number (string, none): if none no number will be displayed otherwise the string gets passed to typst `numbering` function.
/// -> content
#let assignment(body, number: "1.") = {
  new-assignment
  
  if (number != none and number != "hide") { a-nr(style: number) }
  body

  end-assignment
}

/// Add a question and some metadata to your document. 
///
/// This function will just render the given body and store the points as metadata inside the document.
/// You mostly want to use the higher level `question` function.
///
/// - body (content): the content to be displayed for this assignment
/// - points (int): the given points for a correct answer of this question. Will be stored as metadata.
/// -> content
#let _question(body, points: none) = {
  if points != none {
    assert.eq(type(points), int, message: "expected points argument to be an integer, found " + type(points))
  }
  context {
    let level = if is-assignment() { 2 } else { 1 }
    _question_counter.step(level: level)
    // note: metadata must be a new context to fetch the updated _question_counter value correct
    context [#metadata((type: "ttt-question", num: _question_counter.get() ,points: points, level: level)) #_question_label]
  }
  body
}

/// Add a question with number and point-tag to your document. 
///
/// This function adds the current question number up front and a `point-tag` on the right side.
/// If you just want the plain question to render use the low level `_question` function.
///
/// Example:
/// 
/// ```typ
///   #question(points: 2)[What is the result of $1 + 1$ ?]
/// ```
/// - body (content): the content to be displayed for this assignment
/// - points (int): the given points for a correct answer of this question. Will be stored as metadata.
/// - number (string, none): if none no number will be displayed otherwise the string gets passed to typst `numbering` function.
/// -> content
#let question(body, points: none, number: auto) = {
  grid(
    columns: (1fr, auto),
    column-gutter: 0.5em,
    _question(points: points)[
      #context q-nr(style: if-auto-then(number, { if is-assignment() { "a)" } else { "1." }  }))
      #body
    ],
    if points != none {
      place(end, dx: 1cm,point-tag(points))
    }
  )
}

/// A stack with multiple options and a checkbox upfront.
///
/// - distractors (array): all wrong choices
/// - answer (array, string, integer): one or multiple correct choices.
/// - dir (direction): direction of the options. Get's passed to typst `stack` function.
/// -> content
#let _multiple-choice(distractors: (), answer: (), dir: ttb) = {
  let answers = if (type(answer) == array ) { answer } else { (answer,) }
  let choices = (..distractors, ..answers)

  choices = shuffle(choices).map(choice => {
    box(inset:(x:0.5em))[
      #context {
        let is-solution =  _solution.get() and choice in answers
        checkbox(fill: if is-solution { red }, tick: is-solution )
      }
    ]; choice
  })

  stack(dir:dir, spacing: 1em, ..choices)
}

/// A multiple or single choice question.
///
/// The checkbox of an answer will be filled red and ticked if solution-mode is set to true.
///
/// - ..args (arguments): only looking for prompt, distractors, answer and hint.
/// -> content
#let multiple-choice(..args, dir: ttb) = {
  // assertions
  let data = args.named()
  assert(type(data) == dictionary, message: "expected data to be a dictionary, found " + type(data))
  let keys = data.keys()
  assert("prompt" in keys, message: "could not find prompt in keys");
  assert("distractors" in keys, message: "could not find distractors in keys");
  assert("answer" in keys, message: "could not find answer in keys");

  // create output
  block(breakable: false,
    question(points: if (type(data.answer) == array) { data.answer.len() } else { 1 })[
      #data.prompt
      #_multiple-choice(
        distractors: data.distractors, 
        answer: data.answer,
        dir: dir //if data.at("dir", default: none) != none { data.at("dir") } else { ttb }
      )
      // show hint if available.
      #if ("hint" in data.keys()) {
        strong(delta: -100)[Hint: #data.at("hint", default: none)]
      }
    ]
  )
}

// -----------------
// Solution methods 
// -----------------

/// Wrapper to set solution-mode to true
#let show-solutions = { _solution.update(true) }
/// Wrapper to set solution-mode to false
#let hide-solutions = { _solution.update(false) }

/// Wrapper to get the current value of the _solution state
/// ! needs context
/// -> bool
#let is-solution-mode() = {
  _solution.get()
}

/// Sets the solution to a defined state. 
///
/// - value (bool): the solution state
/// -> content
#let set-solution-mode(value) = {
  assert.eq(type(value), bool, message: "expected bool, found " + type(value))
  _solution.update(value)
}

/// Sets whether solutions are shown for a particular part of the document.
///
/// - solution (bool): the solution state to apply for the body
/// - body (content): the content to show
/// -> content
#let with-solution(solution, body) = context {
  assert.eq(type(value), bool, message: "expected bool, found " + type(value))
  let orig-solution = _solution.get()
  _solution.update(solution)
  body
  _solution.update(orig-solution)
}


/// An answer field which is only shown if solution-mode is false.
///
/// - body (content): the content to show
/// -> content
#let answer-field(body) = {
  context {
    if not is-solution-mode() { body }
  }
}


/// An answer to a question which is only shown if solution-mode is true.
///
/// - body (content): the content to show
/// - color (color): text color of the answer. default: red
/// - field (auto, content): some content which is shown if solution-mode is off. default: `_answer_field` state value
/// -> content
#let answer(body, color: red, field: auto) = {
    answer-field(context if-auto-then(field, _answer_field.get()))
    context {
      if is-solution-mode() { 
        set text(fill: color)
        body 
      }
    }
}

// ---------
// Queries 
// ---------

/// Fetch the metadata of the last defined question
///
/// -> dictionary
#let current-question() = { query(selector(_question_label).before(here())).last().value }

/// Fetch the metadata of all questions  in the document.
///
/// - filter (function): a filter which is applied before returning
/// -> dictionary
#let get-questions(filter: none) = {
  let all-questions = query(_question_label).map(m => m.value)
  if filter != none {
    all-questions.filter(filter)
  } else {
    all-questions
  }
}

