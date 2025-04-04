/// A checkbox which can be ticked by the student. If the checkbox is a correct answer and the
/// document is in solution mode, it will be ticked.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds.choice: checkbox
/// Correct: #checkbox(true) -- Incorrect: #checkbox(false)
/// ```)
///
/// - correct (boolean): whether the checkbox is of a correct answer
/// -> content
#let checkbox(correct) = context {
  import "../solution.typ"
  box(height: 0.65em, {
    show: move.with(dy: -0.1em)
    set text(1.5em)
    solution.answer(
      if not correct {
        sym.ballot
      } else if sys.version < version(0, 12, 0) {
        sym.ballot.x
      } else {
        sym.ballot.cross
      },
      placeholder: sym.ballot,
    )
  })
}

/// A table with multiple options that can each be true or false. Each option is a tuple consisting
/// of content and a boolean for whether the option is correct or not.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: choice
/// #choice.multiple(
///   range(1, 6).map(i => ([Answer #i], calc.even(i))),
/// )
/// #set table(stroke: none, inset: (x, y) => (
///   right: if calc.even(x) { 0pt } else { 0.8em },
///   rest: 5pt,
/// ))
/// #choice.multiple(
///   boxes: left,
///   direction: ltr,
///   range(1, 6).map(i => ([#i], calc.even(i))),
/// )
/// ```)
///
/// - options (array): an array of (option, correct) pairs
/// - boxes (alignment): `left` or `right`, specifying on which side of the option the checkbox
///   should appear
/// - direction (direction): `ttb` or `ltr`, specifying how options should be arranged
/// -> content
#let multiple(options, boxes: right, direction: ttb) = {
  assert(boxes in (left, right))
  assert(direction in (ltr, ttb))

  let col-multiplier = if direction == ltr { options.len() } else { 1 }

  table(
    columns: (auto, auto) * col-multiplier,
    align: (col, row) => ((left, center) * col-multiplier).at(col) + horizon,

    ..for (option, correct) in options {
      if boxes == left {
        (checkbox(correct), option)
      } else {
        (option, checkbox(correct))
      }
    }
  )
}

/// A table with multiple options of which one can be true or false. Each option is a content, and a
/// second parameter specifies which option is correct.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: choice
/// #choice.single(
///   range(1, 6).map(i => [Answer #i]),
///   // 0-based indexing
///   3,
/// )
/// #set table(stroke: none, inset: (x, y) => (
///   right: if calc.even(x) { 0pt } else { 0.8em },
///   rest: 5pt,
/// ))
/// #choice.single(
///   boxes: left,
///   direction: ltr,
///   range(1, 6).map(i => [#i]),
///   3,
/// )
/// ```)
///
/// - options (array): an array of contents
/// - answer (integer): the index of the correct answer, zero-based
/// - boxes (alignment): `left` or `right`, specifying on which side of the option the checkbox
///   should appear
/// - direction (direction): `ttb` or `ltr`, specifying how options should be arranged
/// -> content
#let single(options, answer, boxes: right, direction: ttb) = {
  multiple(
    boxes: boxes,
    direction: direction,
    options.enumerate().map(((i, option)) => (option, i == answer)),
  )
}
