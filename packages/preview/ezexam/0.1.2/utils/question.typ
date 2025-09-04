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
  top: 0pt,
  bottom: 0pt,
  with-heading-label: false,
  line-height: auto,
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
    if label == auto {
      if mode-state.get() == LECTURE {
        _label = "【1.1.1.1.1.1】"
      } else {
        _label = "1."
      }
    }
    let arr = (item,)
    if with-heading-label {
      // 去除heading-label数组中的0
      arr = counter(heading).get().filter(item => item != 0) + arr
    }
    text(label-color, weight: label-weight, numbering(_label, ..arr))
  })

  set par(leading: line-height) if line-height != auto
  v(top)
  list(
    marker: _format,
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
    text, move(dx: figure-x, dy: figure-y)[#box[#figure]],
  )
}

// 解析
#let explain(
  body,
  title: none,
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
  above: 30pt,
  below: 20pt,
  show-number: true,
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
    width: 100%,
  )[

    #counter("explain").step()
    // 解析题号的格式化
    #let format(..item) = context () => {
      context numbering("1.", ..counter("explain").get())
    }

    #list(marker: if show-number { format } else { none }, text(fill: color.get(), body))

    #if title == none { return }
    #place(top + title-align, float: true, clearance: 10pt, dx: title-x, dy: title-y)[
      #box(fill: title-bg-color, outset: 8pt, radius: title-radius, text(
        size: title-size,
        weight: title-weight,
        fill: title-color,
        title,
      ))
    ]
  ]
}

// 答案
#let answer(body, color: maroon) = {
  par(text(weight: 700, fill: color)[答案: #body])
}

// 解析的分值
#let score(points, color: maroon, score-prefix: "", score-suffix: "分") = {
  text(fill: color)[
    #box(width: 1fr, repeat($dot$))#score-prefix#points#score-suffix
  ]
}

