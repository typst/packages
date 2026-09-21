/// Point totals and the scoring table. The exam element computes this data
/// once from the parsed item tree and stores it in a state; the functions
/// here read the final value, so they work anywhere in the document (even
/// before the exam).

#import "types.typ": *
#import "refs.typ": LABELLING

#let points_data_state = state(PREFIX + "/points-data", none)

/// API documentation for this module's exports, consumed by
/// docs/generate-api.typ (keyed by export name).
#let DOCS = (
  "points-table": (
    desc: "A scoring table with one column per question plus a total. Works anywhere in the document, even before the exam.",
  ),
  "num-questions": (
    desc: "The total number of questions in the exam. Works anywhere in the document.",
  ),
  "num-points": (
    desc: "The total number of regular (non-bonus, non-practice) points. Works anywhere in the document.",
  ),
)

/// Extract the per-question point data from parsed items.
#let compute_points_data(items) = {
  items
    .filter(it => it.kind == "division" and it.level == 1)
    .map(q => (
      number: q.number,
      total_points: q.total_points,
      total_bonus_points: q.total_bonus_points,
    ))
}

#let _question_label(number) = {
  if type(number) == int {
    numbering("1", number + 1)
  } else if number == none {
    sym.dash.en
  } else {
    [#number]
  }
}

/// The total number of questions in the exam.
#let num_questions = context {
  let data = points_data_state.final()
  if data == none { 0 } else { data.len() }
}

/// The total number of regular (non-bonus, non-practice) points.
#let num_points = context {
  let data = points_data_state.final()
  if data == none { 0 } else { data.map(q => q.total_points).sum(default: 0) }
}

/// A scoring table showing the point value of each question.
#let points_table = context {
  let data = points_data_state.final()
  if data == none or data.len() == 0 {
    return text(fill: red, "WARNING: No questions found! Can't make a points table.")
  }
  let total = data.map(q => q.total_points).sum(default: 0)

  table(
    align: (right, ..(center,) * (data.len() + 1)),
    columns: data.len() + 2,
    stroke: .2pt,
    inset: .6em,
    [Question: ],
    ..data.map(q => _question_label(q.number)),
    [Total],
    [Points:],
    ..data.map(q => [#q.total_points]),
    [#total],
  )
}
