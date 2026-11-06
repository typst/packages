/// Takes an array of _flattened_ task metadata and returns the sum of their points. Tasks without points count as zero points.
///
/// - tasks (array): a flat array of task metadata dictionaries
/// - field (string): the field in the metadata over which to calculate the sum
/// -> integer, float
#let total-points(tasks, field: "points") = {
  tasks.map(t => {
    if t.data != none {
      t.data.at(field, default: 0)
    } else {
      0
    }
  }).sum(default: 0)
}

/// A utility function for generating grades with upper and lower point limits. The parameters must
/// alternate between grade names and threshold scores, with grades in ascending order. These will
/// be combined into dictionaries for each grade with keys `body`, `lower-limit`, and `upper-limit`.
/// The first (lowest) grade will have a `lower-limit` of `none`; the last (highest) grade will have
/// an `upper-limit` of `none`.
///
/// Example:
///
/// #example(
///   mode: "markup",
///   ratio: 1.8,
///   scale-preview: 100%,
///   ```typ
///   #let total = 8
///   #let (bad, okay, good) = grading.grades(
///     [bad], total * 2/4, [okay], total * 3/4, [good]
///   )
///   You will need #okay.lower-limit points to pass,
///   everything below is a _#(bad.body)_ grade.
///   ```
/// )
///
/// - ..args (any): only positional: any number of grade names interspersed with scores
/// -> array
#let grades(..args) = {
  assert(args.named().len() == 0)
  let args = args.pos()
  assert(calc.odd(args.len()))

  range(0, args.len(), step: 2).map((i) => (
    body: args.at(i),
    lower-limit: if i > 0 { args.at(i - 1) },
    upper-limit: if i < args.len() - 1 { args.at(i + 1) },
  ))
}
