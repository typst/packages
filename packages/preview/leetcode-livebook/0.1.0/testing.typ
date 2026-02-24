// testing.typ - Test framework for running and displaying test cases
// Depends on: display
//
// Testcase format:
//   (
//     input: (param1: value1, param2: value2),  // Function parameters
//     explanation: [Optional Typst content],     // Optional explanation
//   )
//
// Validator signature:
//   validator(input, expected, yours) => bool

#import "display.typ": display

#let testcases(
  solution,
  reference,
  cases,
  validator: (input, expected, yours) => expected == yours,
  custom-display: none,
  custom-output-display: none,
) = {
  // Pre-compute all test results
  let results = cases.map(case => {
    let input = if "input" in case { case.input } else { case }
    let expected = reference(..input.values())
    let yours = solution(..input.values())
    let is-placeholder = yours == none
    let pass = if is-placeholder { false } else {
      validator(input, expected, yours)
    }
    (
      input: input,
      expected: expected,
      yours: yours,
      pass: pass,
      is-placeholder: is-placeholder,
      case: case,
    )
  })

  // Calculate pass rate and check if all are placeholders
  let total = results.len()
  let passed = results.filter(r => r.pass).len()
  let all-placeholder = results.all(r => r.is-placeholder)

  // Determine title color based on pass rate
  // All placeholder (no valid solution) -> gray
  // 0% pass -> red, 100% pass -> green, interpolate between
  let title-color = if all-placeholder {
    gray
  } else {
    let ratio = passed / total
    // Interpolate from red (0%) to green (100%)
    color.mix((green, ratio * 100%), (red, (1 - ratio) * 100%))
  }

  v(2em)
  heading(level: 2, outlined: false, numbering: none)[
    #text(fill: title-color)[Test Results (#passed / #total)]
  ]

  let idx = 0
  for result in results {
    let input = result.input
    let expected = result.expected
    let yours = result.yours
    let pass = result.pass
    let case = result.case
    let cell-color = if pass { green } else { red }

    block(
      breakable: false,
      inset: 0.6em,
      width: 100%,
    )[
      #heading(level: 2, outlined: false, numbering: none, [Case #(idx + 1)])

      // Display input using custom-display if provided, otherwise default per-key
      #if custom-display != none {
        custom-display(input)
      } else {
        for key in input.keys() {
          strong(key + ": ")
          display(input.at(key))
          linebreak()
        }
      }

      // Display explanation if present
      #if "explanation" in case and case.explanation != none {
        block(
          inset: (left: 0.5em, top: 0.3em, bottom: 0.3em),
          stroke: (left: 2pt + gray.lighten(50%)),
        )[
          #text(size: 0.9em, fill: gray.darken(20%))[#case.explanation]
        ]
      }

      // Display output using custom-output-display if provided, otherwise default
      #let render-output = if custom-output-display != none {
        custom-output-display
      } else {
        display
      }

      // Render yours output with special handling for placeholder (none)
      #let yours-display = if yours == none {
        text(
          fill: red.lighten(50%),
          style: "italic",
        )[Got none (check your code)]
      } else {
        render-output(yours)
      }

      #table(
        columns: (1fr, 1fr),
        column-gutter: 1em,
        stroke: 0.8pt + gray,
        inset: 0.6em,
        strong("Expected"),
        table.cell(stroke: cell-color)[#strong("Your Output")],
        render-output(expected),
        table.cell(stroke: cell-color)[#yours-display],
      )
    ]
    idx += 1
  }
}
