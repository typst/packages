#let sxjBlank(ans, scale: auto) = context {
  let body = []
  let lenStd = ans
  if type(ans) == content or type(ans) == str {
    body = ans
    lenStd = measure(body).width.to-absolute()
    if lenStd == 0pt { lenStd = 1em }
  } else if type(ans) == int or type(ans) == float {
    body = []
    lenStd = (ans * 1em).to-absolute()
  } else if type(ans) == length {
    body = []
    lenStd = ans.to-absolute()
  }
  let _scale = scale
  if scale == auto {
    if type(ans) == content or type(ans) == str {
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

#let sxjBracket(ans) = {
  [（#box(
    {
      set align(center)
      ans
    },width: 1em)）]
}
