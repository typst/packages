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
/// If a function is provided as a parameter, the located question's metadata is used
/// to call it and content is returned.
/// If a location is provided instead, the question's metadata is located there and returned directly.
///
/// Example:
///
/// ```typ
/// #question.current(q => [This question is worth #q.points points.])
///
/// #locate(loc => {
///   let points = question.current(loc).points
///   // note that `points` is an integer, not a content!
///   let points-with-extra = points + 1
///   // but eventually, `locate()` will convert to content
///   [I may award up to #points-with-extra points for great answers!]
/// })
/// ```
///
/// - func-or-loc (function, location): either a function that receives metadata and returns content, or the location at which to locate the question
/// -> content, dictionary
#let current(func-or-loc) = {
  let inner(loc) = {
    let q = query(selector(_label).before(loc), loc).last()
    _metadata_to_dict(q)
  }

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

/// Locates all questions in the document, which can then be used to create grading keys etc.
/// The array of question metadata is used to call the provided function.
///
/// If a function is provided as a parameter, the array of located questions' metadata is used
/// to call it and content is returned.
/// If a location is provided instead, it is used to retrieve the metadata and they are returned directly.
///
/// Example:
///
/// ```typ
/// #question.all(qs => [There are #qs.len() questions.])
///
/// #locate(loc => {
///   let qs = question.all(loc)
///   // note that `qs` is an array, not a content!
///   // but eventually, `locate()` will convert to content
///   [The first question is worth #qs.first().points points!]
/// })
/// ```
///
/// - func-or-loc (function, location): either a function that receives metadata and returns content, or the location at which to locate the question
/// -> content, array
#let all(func-or-loc) = {
  let inner(loc) = {
    let qs = query(_label, loc)
    qs.map(_metadata_to_dict)
  }

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
