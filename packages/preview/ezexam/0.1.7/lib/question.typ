#import "const-state.typ": HANDOUTS, answer-color-state, answer-state, mode-state

#let question(
  body,
  body-indent: .6em,
  indent: 0pt,
  label: auto,
  label-color: luma(0),
  label-weight: "regular",
  with-heading-label: false,
  points: none,
  points-separate: true,
  points-prefix: "（",
  points-suffix: "分）",
  top: 0pt,
  bottom: 0pt,
  line-height: auto,
) = context {
  let _body = body
  // 分数设置
  if points != none {
    _body = [#points-prefix#points#points-suffix #if points-separate [ \ ] #body]
  }
  set par(leading: line-height) if line-height != auto

  // 格式化题号
  counter("question").step()
  let _format = context counter("question").display(num => {
    let _label = label
    if label == auto {
      if mode-state.get() == HANDOUTS {
        _label = "【1.1.1.1.1.1】"
      } else {
        _label = "1."
      }
    }

    let _counter = counter("placeholder")
    if _counter.get().first() < num {
      _counter.step()
    }

    let arr = (num,)
    if with-heading-label {
      // 去除heading label数组中的0
      arr = counter(heading).get().filter(item => item != 0) + arr
    }
    text(label-color, weight: label-weight, box(numbering(_label, ..arr), width: 1.5em))
  })

  if top != 0pt { v(top + par.leading) }
  enum(
    numbering: _ => _format,
    body-indent: body-indent,
    indent: indent,
    _body,
  )
  v(bottom)
}

#let _get-answer(body, placeholder, with-number, update) = context {
  if answer-state.get() {
    return text(answer-color-state.get(), body)
  }

  if not with-number { return placeholder }

  counter("placeholder").step()
  context counter("placeholder").display()
  if update { counter("question").step() }
}

// 选项的括号
#let paren(
  body,
  justify: false,
  placeholder: sym.triangle.filled.small,
  with-number: false,
  update: false,
) = {
  let body = _get-answer(body, placeholder, with-number, update)
  [#if justify { h(1fr) } （~~#upper(body)~~）]
}

// 填空的横线
#let fillin(
  body,
  length: 1em,
  placeholder: sym.triangle.filled.small,
  with-number: false,
  update: false,
) = {
  let body = _get-answer(body, placeholder, with-number, update)
  let space = h(length)
  $underline(#space#body#space)$
}

// 类似英文中的7选5题型专用语法糖
#let parenn = paren.with(with-number: true, update: true)
#let fillinn = fillin.with(with-number: true, update: true)

// 图文混排(左文右图)
#let text-figure(
  text: "",
  figure,
  figure-x: 0pt,
  figure-y: 0pt,
  top: 0pt,
  bottom: 0pt,
) = grid(
  columns: 2,
  align: horizon,
  inset: (
    top: top,
    bottom: bottom,
  ),
  text, move(dx: figure-x, dy: figure-y)[#box[#figure]],
)

#let solution(
  body,
  title: none,
  title-size: 12pt,
  title-weight: "bold",
  title-color: luma(100%),
  title-bg-color: maroon,
  title-radius: 5pt,
  title-align: top + center,
  title-x: 0pt,
  title-y: 0pt,
  border-style: "dashed",
  border-width: .5pt,
  border-color: maroon,
  color: blue,
  radius: 5pt,
  bg-color: luma(100%),
  breakable: true,
  top: 20pt,
  bottom: 20pt,
  inset: (rest: 10pt, top: 20pt, bottom: 20pt),
  show-number: true,
  margin-top: 0pt,
  line-height: auto,
) = context {
  if not answer-state.get() { return }
  set par(leading: line-height) if line-height != auto
  assert(type(inset) == dictionary, message: "inset must be a dictionary")
  let _padding = (rest: 10pt, top: 20pt, bottom: 20pt) + inset
  block(
    above: top,
    below: bottom,
    breakable: breakable,
    inset: _padding + (top: _padding.top),
    radius: radius,
    stroke: (thickness: border-width, paint: border-color, dash: border-style),
    fill: bg-color,
  )[
    #if title != none {
      let title-box = box(fill: title-bg-color, inset: 6pt, radius: title-radius, text(
        size: title-size,
        weight: title-weight,
        tracking: 3pt,
        title-color,
        title,
      ))
      let _title-height = measure(title-box).height
      place(
        title-align,
        dx: title-x,
        dy: if type(inset) == length { -inset } else { -inset.top } - _title-height / 2 + title-y,
      )[#title-box]
    }
    #block(width: 100%)[
      #counter("explain").step()
      // 解析题号的格式化
      #let format(..item) = context () => {
        numbering("1.", ..counter("explain").get())
      }
      #if margin-top != 0pt {
        v(margin-top + _padding.top)
      }
      #list(
        marker: if show-number { format } else { none },
        text(color, body),
      )
    ]
  ]
}

// 该方法是解决有比较高的公式的时候，题号和解析之间对不齐的问题
// 不单独使用，仅在question方法 或者 solution方法 中使用
#let height-content(top: 0pt, line-height: 0pt, body) = context place(
  dy: top,
  float: true,
  clearance: top + par.leading,
  alignment.top,
)[#par(leading: line-height, body)]

// 解析的分值
#let score(points, color: maroon, score-prefix: "", score-suffix: "分") = text(color)[
  #box(width: 1fr, repeat($dot$))#score-prefix#points#score-suffix
]

#let answer(body, color: maroon) = par(text(weight: 700, color)[答案: #body])
