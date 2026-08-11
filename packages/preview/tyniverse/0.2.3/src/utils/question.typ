#let question-counter = counter("question")

/// Base question frame
///
/// - heading-counter (bool): whether to show heading counter
/// - number (auto | int | str | content): question number, defaults to `auto`.
///   When using `auto`, the number will be auto-incremented and it only
///   increments with the `auto` value.
/// - display-number (function(override: str | content, ..int) -> content): how
///   to display the question number
/// - display-desc (function(content) -> content): how to display the
///   question description
/// - display-frame (function(content) -> content): how to display the
///   question frame
/// - desc (content): question description
/// -> content
///
#let question(
  heading-counter: false,
  number: auto,
  display-number: none,
  display-desc: none,
  display-frame: none,
  desc,
) = {
  assert(
    type(display-number) == function and type(display-frame) == function and type(display-desc) == function,
    message: "display-number, display-frame, and display-desc must be functions",
  )

  // heading-counter doesn't work when number is a string
  assert(
    (type(number) != str and type(number) != content) or not heading-counter,
    message: "heading-counter doesn't work when `number` is a string or content",
  )

  if number == auto {
    question-counter.step()
  }

  context {
    let heading-number = counter(heading).get()
    let current-number = if number == auto {
      (..question-counter.get(),)
    } else if type(number) == int {
      (number,)
    } else {
      ()
    }

    let numbers = if heading-counter {
      (..heading-number, ..current-number)
    } else {
      current-number
    }

    display-frame({
      if numbers.len() == 0 {
        display-number(override: number)
      } else {
        display-number(..numbers)
      }

      h(5pt)

      display-desc(desc)
    })
  }
}

/// Preset: simple question
///
/// - heading-counter (bool): whether to show heading counter
/// - number (auto | int | str | content):
///   question number, defaults to `auto` (auto-incremented)
/// - display-number (function(override: str | content, ..int) -> content):
///   how to display the question number, defaults "1.1." with bold style
/// - display-desc (function(content) -> content):
///   how to display the question description, defaults to bold style
/// - display-frame (function(content) -> content):
///   how to display the question frame, defaults to number and description over a line
/// - desc (content): question description
/// -> content
///
#let simple-question = question.with(
  display-number: (override: none, ..numbers) => {
    if type(override) == str {
      strong(override)
    } else if type(override) == content {
      strong(override)
    } else {
      strong(numbering("1.1.", ..numbers))
    }
  },
  display-desc: it => strong(it),
  display-frame: it => {
    it
    v(-0.9em)
    line(length: 100%)
    v(-0.6em)
  },
)

/// Preset: complex question
///
/// - heading-counter (bool): whether to show heading counter
/// - number (auto | int | str | content):
///   question number, defaults to `auto` (auto-incremented)
/// - display-number (auto | function(override: str | content, ..int) -> content):
///   how to display the question number, defaults "1.1." with bold style
/// - display-desc (function(content) -> content):
///   how to display the question description, defaults to no extra style
/// - display-frame (function(content) -> content):
///   how to display the question frame, defaults to 100% width rectangle with 5pt radius
/// - desc (content): question description
/// -> content
///
#let complex-question = question.with(
  display-number: (override: none, ..numbers) => {
    if type(override) == str {
      strong(override)
    } else if type(override) == content {
      strong(override)
    } else {
      strong(numbering("1.1.", ..numbers))
    }
  },
  display-desc: it => it,
  display-frame: it => rect(width: 100%, radius: 5pt)[#it],
)

#set heading(numbering: "1.")
