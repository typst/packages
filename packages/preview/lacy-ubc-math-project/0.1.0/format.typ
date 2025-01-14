// Question levels, corresponding numbering and labeling.

// The maximum number of question levels.
#let __max-qs-level = 3
// The current question level.
#let __question-level = state("question-level", 0)
// The question counters.
#let __question-counters = range(1, __max-qs-level + 1).map(i => counter("question-" + str(i)))
// Duplicate question numbers
#let __question-duplicates = state("question-duplicates", (:))
// Numbering for each question level.
#let __question-numbering = (
  "1.",
  "(a)",
  "i.",
)
// Label numbering for each question level.
#let __question-labels = (
  "1",
  "a",
  "i",
)
// Make sure the numbering and labeling are consistent.
#assert(__question-numbering.len() == __max-qs-level and __question-labels.len() == __max-qs-level)

// solution visibility
#let __solution-visible = state("solution-visible", true)
#let toggle-solution(visible) = {
  assert(type(visible) == bool, message: "The visibility of the solution must be a boolean.")
  __solution-visible.update(v => visible)
}
#let __solution-disabled = sys.inputs.at("hide-solution", default: "") in ("1", "true", "yes", "y")

/// Creates an author (a `dictionary`).
/// - firstname (str, content): The author's first name, bold when displayed.
/// - lastname (str, content): The author's last name.
/// - id (int, content): The author's student ID.
/// - strname (str, none): `str` alternative as the full name. In case of special characters or formatting in the name, a plain text version can be used for PDF metadata.
#let author(firstname, lastname, id, strname: none) = {
  (
    name: (
      first: firstname,
      last: lastname,
    ),
    id: id,
    strname: strname,
  )
}

// The green used for solution frame and text.
#let green-solution = rgb(10%, 40%, 10%)

/// Creates a question block.
/// Automatically increments the question level for further questions in `body`.
/// Supports up to 3 levels of questions.
/// [WARN] Do not provide `counters`, `numbering` or `labels` if unsure of what they do.
///
/// - point (int, content, str, none): The number of points for the question. Does not display if it is `0` or `none`; does not attach "points" if it is `content` or `str`.
///
/// - body (block): The question, sub-questions and solutions.
///
/// - counters (array): The question counters for each level.
///
/// - numbering (array): The numbering for each question level.
///  For example, `("1.", "(a)", "i.")`.
///
/// - labels (array): The label numbering for each question level. Must not contain anything not allowed in `label`, e.g. spaces, plus signs.
///  For example, `("1", "a", "i")` will result in question 1.1.1 being labeled with `<qs:1-a-i>`.
#let question(point, body, counters: __question-counters, numbering: __question-numbering, labels: __question-labels) = context {
  // Increment the question level.
  __question-level.update(n => n + 1)
  // Get the current question level.
  let level = __question-level.get()
  // Make sure the question level is within the supported range.
  assert(
    level <= __max-qs-level,
    message: "Maximum question level exceeded. Only " + str(__max-qs-level) + " levels are supported.",
  )

  // Gutter between the question number and the question body.
  let gut = 0.45em
  // Width of the question number, which is the width of an enum number.
  let w = measure(enum.item([])).width
  // The question number#.
  let numbers = range(0, level + 1).map(i => str(counters.at(i).display(labels.at(i)))).join("-")
  // Update the duplicate question numbers.
  __question-duplicates.update(d => {
    if numbers in d.keys() {
      (..d, (numbers): d.at(numbers) + 1)
    } else {
      d + ((numbers): 1)
    }
  })
  context grid(
    columns: (w, 100% - w - gut),
    column-gutter: gut,
    align: (top + right, top + left),

    // Question number with label.
    [
      #counters.at(level).display(numbering.at(level))

      #let occ = __question-duplicates.get().at(numbers, default: 1)
      #label(
        "qs:"
          + numbers
          + if occ > 1 { "_" + str(occ) } else { none },
      )
    ],
    // Question body.
    [
      #if point not in (none, 0) {
        if type(point) == str or type(point) == content [(#point)] else if (
          type(point) == int and point == 1
        ) [(#point point)] else [(#point points)]
        sym.space.thin
      }
      #body
    ]
  )

  // Increment the question counter at the current level.
  counters.at(level).step()
  // Set all lower level question counters to 1.
  for i in range(level + 1, counters.len()) {
    counters.at(i).update(1)
  }
  // Reduce the question level, leave.
  __question-level.update(n => n - 1)
}

/// Creates a solution block.
/// - body (content): The solution.
/// - color (color): The color of the solution frame and text.
/// - supplement (content): The supplemental text to be displayed before the solution.
#let solution(body, color: green-solution, supplement: [*Solution*: ], force: false) = {
  context block(
    width: 100%,
    inset: 1em,
    stroke: color + 0.5pt,
  )[
    #if __solution-disabled { return none }
    #if not force and not __solution-visible.get() { return none }
    #set align(left)
    #set text(fill: color)
    #supplement#body
  ]
}

