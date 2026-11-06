/// A boolean state storing whether solutions should currently be shown in the document.
/// This can be set using the Typst CLI using `--input solution=true` (or `false`, which is already
/// the default) or by updating the state:
///
/// ```typ
/// #questions.solution.update(true)
/// ```
///
/// Additionally, @@with-solution() can be used to change the solution state temporarily.
///
/// -> state
#let solution = state("scrutinize-solution", {
  import "utils.typ": boolean-input
  boolean-input("solution")
})

#let _solution = solution

/// Sets whether solutions are shown for a particular part of the document.
///
/// - solution (boolean): the solution state to apply for the body
/// - body (content): the content to show
/// -> content
#let with-solution(solution, body) = context {
  let orig-solution = _solution.get()
  _solution.update(solution)
  body
  _solution.update(orig-solution)
}

/// An answer to a free text question. If the document is not in solution mode,
/// the answer is hidden but the height of the element is preserved.
///
/// - answer (content): the answer to (maybe) display
/// - height (auto, relative): the height of the region where an answer can be written
/// -> content
#let free-text-answer(answer, height: auto) = context {
  let answer = block(inset: (x: 2em, y: 1em), height: height, answer)
  if (not solution.get()) {
    answer = hide(answer)
  }
  answer
}

/// A checkbox which can be ticked by the student.
/// If the checkbox is a correct answer and the document is in solution mode, it will be ticked.
///
/// - correct (boolean): whether the checkbox is of a correct answer
/// -> content
#let checkbox(correct) = context {
  if (solution.get() and correct) { sym.ballot.x } else { sym.ballot }
}

/// A table with multiple options that can each be true or false.
/// Each option is a tuple consisting of content and a boolean for whether the option is correct or not.
///
/// - options (array): an array of (option, correct) pairs
/// -> content
#let multiple-choice(options) = {
  table(
    columns: (auto, auto),
    align: (col, row) => (left, center).at(col) + horizon,

    ..for (option, correct) in options {
      (option, checkbox(correct))
    }
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
