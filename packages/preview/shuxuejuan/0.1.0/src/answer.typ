
/// Print a blank `___` (with an answer in it)
/// - answer (content, string):
///   The one-line answer you want to print.
/// - scale (float, auto):
///   The ratio between the length of underline
///   and the length of the answer.
///   When set to auto, it would be 2 when `ans` is not empty
///   and 1 when `ans` is.
/// -> content
#let sxj-blank(answer, scale: auto) = context {
  let body = []
  let lenStd = answer
  if type(answer) == content or type(answer) == str {
    body = answer
    lenStd = measure(body).width.to-absolute()
    if lenStd == 0pt { lenStd = 1em }
  } else if type(answer) == int or type(answer) == float {
    body = []
    lenStd = (answer * 1em).to-absolute()
  } else if type(answer) == length {
    body = []
    lenStd = answer.to-absolute()
  }
  let _scale = scale
  if scale == auto {
    if type(answer) == content or type(answer) == str {
      _scale = 2
    } else {
      _scale = 1
    }
  }
  box(
    {
      set align(center + horizon)
      body
    },
    stroke: (bottom: .6pt + black),
    width: lenStd * _scale,
  )
}

/// Print a bracket `( )` (with an answer in it)
/// - answer (content): The answer you want to put in a bracket.
/// -> content
#let sxj-bracket(answer) = {
  [（#box(
    {
      set align(center)
      answer
    },width: 1em)）]
}
