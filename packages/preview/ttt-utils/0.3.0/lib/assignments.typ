#import "components.typ": point-tag, checkbox
#import "helpers.typ": if-auto-then
#import "random.typ"
#import "layout.typ": *

// ------------
// Counters
// ------------
#let _question_counter = counter("ttt-question-counter");
/// Wrapper to reset the `_question_counter` back to zero
#let reset-question-counter() = { _question_counter.update(0) }

/// Get current numbering
/// -> content
#let current-numbering(style: "1.a)") = context {
  numbering(
    (..nums) => {
      nums = nums.pos()
      if nums.len() == 1 {
        str(nums.at(0)) + "."
      } else {
        numbering(style, ..nums)
      }
    },
    .._question_counter.get()
  )
}

// ------------
// Labels
// ------------
#let _question-label = label("ttt-question-label")

// ------------
//  States
// ------------
#let _solution = state("ttt-solution", false);
#let _scenario_env = state("ttt-scenario-env", false)
#let _scenario-collect = state("ttt-scenario-collect", false)

// ------------
//  Scenario
// ------------

#let new-scenario = {
  _scenario_env.update(true)
  _question_counter.step(level: 1)
}
#let end-scenario = {
  _scenario_env.update(false)
  _scenario-collect.update(false)
}

#let is-scenario() = { _scenario_env.get() }
#let scenario-number() = {
  if is-scenario() { _question_counter.get().first() } else {none}
}
#let question-number() = { _question_counter.get().last() }

#let start-collecting-points = { _scenario-collect.update(true) }
#let is-collecting-points() = { _scenario-collect.get() }

// ---------
// Queries
// ---------

/// Fetch the metadata of the options of the current question
/// ```example
/// #context current-options()
/// ```
/// -> array of dictionaries
#let current-options() = {
  query(selector(_option-label)).filter(meta => {
    meta.value.question-number == _question_counter.get()
  }).map(meta => meta.value)
}

/// Fetch the metadata of all questions  in the document.
///
/// -> dictionary
#let get-questions(
  /// a filter which is applied before returning
  /// -> function
  filter: none
) = {
  let all-questions = query(_question-label).map(m => m.value)
  if filter != none {
    all-questions.filter(filter)
  } else {
    all-questions
  }
}

// -----------------
// Solution methods
// -----------------

/// Wrapper to set solution-mode to true
#let show-solutions = { _solution.update(true) }
/// Wrapper to set solution-mode to false
#let hide-solutions = { _solution.update(false) }

// Wrapper to get the current value of the `_solution` state
// ! needs context
// -> bool
#let is-solution-mode() = {
  _solution.get()
}

/// Sets the solution to a defined state.
///
/// -> content
#let set-solution-mode(
  /// the solution state
  /// -> bool
  value
) = {
  assert.eq(type(value), bool, message: "expected bool, found " + str(type(value)))
  _solution.update(value)
}

/// Sets whether solutions are shown for a particular part of the document.
///
/// -> content
#let with-solution(
  /// the solution state to apply for the body
  /// -> bool
  solution,
  /// - body (content): the content to show
  /// -> content
  body
) = context {
  assert.eq(type(solution), bool, message: "expected bool, found " + str(type(solution)))
  let orig-solution = _solution.get()
  _solution.update(solution)
  body
  _solution.update(orig-solution)
}


// -----------------
// Scenario
// -----------------
#let scenario(
  body,
  collect-points: false,
  disable-numbering: false,
) = {
  new-scenario

  if collect-points {
    start-collecting-points

    context {
      let points = get-questions(filter: q => q.num.first() == scenario-number()).map(q => q.points).sum(default: 0)

      place(end, dy: -1em, context render-point-tag(points))
    }
  }

  if not disable-numbering { current-numbering() }; body

  end-scenario
}


/// Add a question to your document.
///
/// ```example
/// #question(points: 2)[
///   What is the result of $1 + 1$ ?
/// ]
/// ```
///
/// -> content
#let question(
  /// the content to be displayed for this assignment
  /// -> content
  body,
  /// the given points for a correct answer of this question. Will be stored as metadata.
  /// -> int | none
  points: none,
  /// if true the question can be broken over multiple pages
  /// -> bool
  breakable: false,
  /// function which renders the question.
  /// -> function
  // render: block-question-renderer,
) = {
  // assertions
  if points != none {
    assert.eq(type(points), int, message: "expected points argument to be an integer, found " + str(type(points)))
  }

  context {
    let level = if is-scenario() { 2 } else { 1 }
    _question_counter.step(level: level)
  }

  context {
    // note: metadata must be a new context to fetch the updated _question_counter value correct
    [#metadata((
      type: "ttt-question",
      num: _question_counter.get() ,
      points: points,
    )) #_question-label]

    if is-collecting-points() {
      let points = none
    }

    let number = current-numbering()

    // render the question
    set block(breakable: breakable)
    render(
      points: points,
      [#number #body],
    )
  }
}

/// Creates an option with a checkbox
/// -> content
#let option(
  /// the content of the option
  /// -> content
  body,
  /// if true the checkbox will be filled red and ticked if solution-mode is set to true. default: false
  /// -> bool
  correct: false,
) = {
  context {
    let is-sol-mode = is-solution-mode()

    grid(
      columns: (auto, 1fr),
      gutter: 0.5em,
      align: (center, start),
      checkbox(fill: if correct and is-sol-mode { red }, tick: correct and is-sol-mode),
      body
    )
  }
}

/// Helper function to quickly create options with a list style.
/// Use bullet list (`-`) for distractors and numbered list (`+`) for correct options
///  Example:
/// ```example
/// #quick-options[
///   - javascript
///   + typst
///   - python
///   - rust
/// ]
/// ```
#let quick-options(
  body
) = {
  show list.item: it => option(it.body)
  show enum.item: it => option(correct: true, it.body)

  body
}


/// Helper functions
#let correct(option) = { (correct: true, body: option) }

/// Add multiple options to a question. The options get shuffled by default, but can be turned off with the `shuffle` argument. Each option is rendered with the `option` function, so the correct answer can be marked by using the `correct` helper function.
#let options(
  cols: 1,
  shuffle: true,
  ..seq
) = {
  let options-ordered = seq.pos()

  context {
    let options-shuffled = if shuffle {
      random.shuffle(options-ordered, _question_counter.get())
    } else {
        options-ordered
    }

    grid(
      columns: cols,
      gutter: 1em,
      ..options-shuffled.map(o => {
        if type(o) == dictionary {
          option(o.body, correct: o.correct)
        } else {
          option(o)
        }
      })
    )
  }
}


/// An answer to a question which is only shown if solution-mode is true.
/// -> content
#let answer(
  /// the content to show if solution-mode is on
  /// -> content
  body,
  /// text color of the answer. default: red
  /// -> color
  color: red,
  /// if true the answer is only hidden if solution mode is false.
  /// -> bool
  hide: false
) = {

    context {
      if is-solution-mode() {
        set text(fill: color)
        body
      } else if hide {
          std.hide(body)
        }
    }
}
