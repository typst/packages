#let _label = <scrutinize-question>
#let _builtin_counter = counter

#let _metadata_to_dict(m) = (..m.value, location: m.location())

/// The question counter
///
/// Example:
///
/// ```typ
/// #show heading: it => [Question #question.counter.display()]
/// ```
///
/// -> counter
#let counter = _builtin_counter(_label)

/// Adds a question with its metadata, and renders it.
/// The questions can later be accessed using the other functions in this module.
///
/// - body (content): the content to be displayed for this question
/// - ..args (string): only named parameters: values to be added to the question's metadata
/// -> content
#let q(
  body,
  ..args,
) = {
  assert(args.pos().len() == 0)
  [#metadata((body: body, ..args.named())) #_label]
  body
}

/// Locates the most recently defined question;
/// within a @@q() call, that is the question _currently_ being defined.
///
/// This function is contextual and must appear within a ```typ context``` expression.
///
/// Example:
///
/// ```typ
/// #context [
///   #let points = question.current().points
///   This question is worth #points points.
///
///   I may award up to #(points + 1) points for great answers!
/// ]
/// ```
///
/// -> dictionary
#let current() = {
  let q = query(selector(_label).before(here())).last()
  _metadata_to_dict(q)
}

/// Locates all questions in the document, which can then be used to create grading keys etc.
///
/// This function is contextual and must appear within a ```typ context``` expression.
///
/// Example:
///
/// ```typ
/// #context [
///   #let qs = question.all()
///   There are #qs.len() questions.
///
///   The first question is worth #qs.first().points points!
/// ]
/// ```
///
/// -> array
#let all() = {
  let qs = query(_label)
  qs.map(_metadata_to_dict)
}
