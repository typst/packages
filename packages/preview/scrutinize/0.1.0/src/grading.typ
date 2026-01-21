/// Takes an array of question `metadata` objects (not dictionaries) and returns the sum of their points.
/// Note that the points metadata is optional and may therefore be `none`;
/// if your test may contain questions without points, you have to take care of that.
///
/// This function also optionally takes a filter function.
/// If given, the function will get the metadata of each question and must return a boolean.
///
/// - questions (array): an array of question `metadata` objects
/// - filter (function): an optional filter function for determining which questions to sum up
/// -> integer
#let total-points(questions, filter: none) = {
  if filter != none {
    questions = questions.filter(filter)
  }
  questions.map(q => q.points).sum(default: 0)
}

/// A utility function for generating grades with upper and lower point limits.
/// The parameters must alternate between grade names and threshold scores, with grades in ascending order.
/// these will be combined in dictionaries for each grade with keys `body`, `lower-limit`, and `upper-limit`.
/// The first (lowest) grade will have a `lower-limit` of `none`;
/// the last (highest) grade will have an `upper-limit` of `none`.
///
/// Example:
///
/// ```typ
/// #let total = 8
/// #let (bad, okay, good) = grading.grades(
///   [bad], total * 2/4, [okay], total * 3/4, [good]
/// )
/// [
///   You will need #okay.lower-limit points to pass,
///   everything below is a #bad.body grade.
/// ]
/// ```
///
/// - ..args (any): only positional: any number of grade names interspersed with scores
/// -> array
#let grades(..args) = {
  assert(args.named().len() == 0)
  let args = args.pos()
  assert(calc.odd(args.len()))

  let result = ()

  for i in range(0, args.len(), step: 2) {
    result.push((
      body: args.at(i),
      lower-limit: if i > 0 { args.at(i - 1) },
      upper-limit: if i < args.len() - 1 { args.at(i + 1) },
    ))
  }

  result
}
