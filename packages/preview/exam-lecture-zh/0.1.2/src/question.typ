#import "const-state.typ": LECTURE, answer-color-state, answer-state, mode-state

#let question(
  body,
  body-indent: 0.6em,
  indent: 0pt,
  label: auto,
  label-color: luma(0),
  label-weight: "regular",
  points: none,
  points-separate-par: true,
  points-prefix: "（",
  points-suffix: "分）",
  top: 0em,
  bottom: 0em,
  with-heading-label: none,
) = {
  // 分数设置
  let result = body
  if points != none {
    result = [#points-prefix#points#points-suffix #if points-separate-par [ \ ] #body]
  }
  // 格式化题号
  counter("question").step()
  let _format = context counter("question").display(item => {
    let _label = label
    let _with-heading-label = with-heading-label
    if label == auto {
      if mode-state.get() == LECTURE {
        _label = "【1.1.1.1.1】"
      } else {
        _label = "1."
      }
    }

    if with-heading-label == none {
      if mode-state.get() == LECTURE {
        _with-heading-label = true
      } else {
        _with-heading-label = false
      }
    }

    let arr = (item,)
    if _with-heading-label {
      // 去除heading-label数组中的0
      arr = counter(heading).get().filter(item => item != 0) + arr
    }
    text(label-color, weight: label-weight)[#numbering(_label, ..arr)<question-label>]
  })

  v(top)
  enum(
    numbering: _ => _format,
    body-indent: body-indent,
    indent: indent,
    result,
  )
  v(bottom)
}

// 题干中选项的括号
#let _get-answer(answer, placeholder: sym.triangle.filled.small) = {
  let result = placeholder
  if answer-state.get() {
    result = text(fill: answer-color-state.get(), answer)
  }
  return result
}

#let paren(answer, justify: false, placeholder: sym.triangle.filled.small) = context {
  let result = _get-answer(answer, placeholder: placeholder)
  [#if justify { h(1fr) } （~~#upper(result)~~）]
}

// 填空的横线
#let fillin(answer, length: 1em, placeholder: sym.triangle.filled.small) = context {
  let space = h(length)
  let result = _get-answer(answer, placeholder: placeholder)
  $underline(#space#result#space)$
}

// 图文混排(左文右图)
#let text-figure(
  text: "",
  figure,
  figure-x: 0pt,
  figure-y: 0pt,
  top: 0pt,
  bottom: 0pt,
) = {
  grid(
    columns: 2,
    align: horizon,
    inset: (
      top: top,
      bottom: bottom,
    ),
    text, move(dx: figure-x, dy: figure-y)[#figure],
  )
}

// 解析
#let explain(
  body,
  title: "解 析",
  title-size: 12pt,
  title-weight: "bold",
  title-color: luma(100%),
  title-bg-color: maroon,
  title-radius: 5pt,
  title-align: center,
  title-x: 0pt,
  title-y: -20pt,
  border-style: "dashed",
  border-width: .5pt,
  border-color: maroon,
  color: answer-color-state,
  radius: 5pt,
  inset: 15pt,
  bg-color: luma(100%),
  breakable: true,
  above: 40pt,
  below: 20pt,
) = context {
  if not answer-state.get() { return }
  block(
    above: above,
    below: below,
    breakable: breakable,
    inset: inset,
    radius: radius,
    stroke: (thickness: border-width, paint: border-color, dash: border-style),
    fill: bg-color,
  )[
    #place(top + title-align, float: true, clearance: 10pt, dx: title-x, dy: title-y)[
      #box(fill: title-bg-color, outset: 8pt, radius: title-radius, text(
        size: title-size,
        weight: title-weight,
        fill: title-color,
        title,
      ))
    ]
    #text(fill: color.get(), body)
  ]
}

// 解析的分值
#let score(points, color: maroon, score-prefix: "", score-suffix: "分") = {
  text(fill: color)[
    #box(width: 1fr, repeat($dot$))#score-prefix#points#score-suffix
  ]
}

