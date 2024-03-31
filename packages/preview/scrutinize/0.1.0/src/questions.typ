#let solution = state("scrutinize-solution", false)

/// Shows solutions in the document.
///
/// -> content
#let set-solution() = solution.update(true)

/// Hides solutions in the document.
///
/// -> content
#let unset-solution() = solution.update(false)

/// Queries the current solution display state.
///
/// If a function is provided as a parameter, the boolean is used to call it and content is returned.
/// If a location is provided instead, it is used to retrieve the boolean state and it is returned directly.
///
/// - func-or-loc (function, location): either a function that receives metadata and returns content, or the location at which to locate the question
/// -> content, boolean
#let is-solution(func-or-loc) = {
  let inner(loc) = solution.at(loc)

  if type(func-or-loc) == function {
    let func = func-or-loc
    // find value, transform it into content
    locate(loc => func(inner(loc)))
  } else if type(func-or-loc) == location {
    let loc = func-or-loc
    // find value, return it
    inner(loc)
  } else {
    panic("function or location expected")
  }
}

/// An answer to a free text question. If the document is not in solution mode,
/// the answer is hidden but the height of the element is preserved.
///
/// - answer (content): the answer to (maybe) display
/// - height (auto, relative): the height of the region where an answer can be written
/// -> content
#let free-text-answer(answer, height: auto) = is-solution(solution => {
  let answer = block(inset: (x: 2em, y: 1em), height: height, answer)
  if (not solution) {
    answer = hide(answer)
  }
  answer
})

/// A checkbox which can be ticked by the student.
/// If the checkbox is a correct answer and the document is in solution mode, it will be ticked.
///
/// - correct (boolean): whether the checkbox is of a correct answer
/// -> content
#let checkbox(correct) = is-solution(solution => {
  if (solution and correct) { sym.ballot.x } else { sym.ballot }
})

/// A table with multiple options that can each be true or false.
/// Each option is a tuple consisting of content and a boolean for whether the option is correct or not.
///
/// - options (array): an array of (option, correct) pairs
/// -> content
#let multiple-choice(options) = {
  table(
    columns: (auto, auto),
    align: (col, row) => (left, center).at(col) + horizon,

    ..options.map(((option, correct)) => (
      option,
      checkbox(correct),
    )).flatten()
  )
}

/// A table with multiple options of which one can be true or false.
/// Each option is a content, and a second parameter specifies which option is correct.
///
/// - options (array): an array of contents
/// - answer (integer): the index of the correct answer, zero-based
/// -> content
#let single-choice(options, answer) = {
  multiple-choice(options.enumerate().map(((i, option)) => (option, i == answer)))
}
