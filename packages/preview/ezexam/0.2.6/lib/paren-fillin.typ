#import "const-state.typ": answer-color-state, answer-state

#let _get-answer(body, placeholder, with-number, update) = {
  if answer-state.get() {
    return text(answer-color-state.get(), body)
  }
  if not with-number { return placeholder }
  counter("placeholder").step()
  context counter("placeholder").display()
  if update { counter("question").step() }
}

#let _draw-line(len, stroke, offset, body) = {
  let _len = len.to-absolute()
  if _len < 5pt { panic("len must >= 5pt") }
  // 第一行横线开始位置及长度
  let page-width = page.width
  let _columns = page.columns

  if page.flipped {
    page-width = page.height
  }

  let _columns = page.columns
  let here-pos-x = here().position().x
  if _columns > 1 {
    let one-column-width = (page-width + columns.gutter * (_columns - 1)) / _columns
    // 当有多个列时，当前内容所在的那一列加上前面所有的列的总宽度
    page-width = one-column-width * calc.ceil(here-pos-x / one-column-width)
  }
  let first-line-available-space = page-width - page.margin - here-pos-x
  // 第一行线
  // 如果当前指定长度 < 剩余空间，则直接按照指定长度在文字后画线
  let detla-len = _len - first-line-available-space
  if detla-len < 0pt {
    first-line-available-space = _len
  }

  // 当前指定长度 > 剩余空间且剩余空间 > 2pt，在指定文字后先画一部分；
  set box(stroke: (bottom: stroke), inset: (bottom: offset), outset: (bottom: offset))

  let is-new-line = false
  if first-line-available-space <= 7pt {
    [ \ ]
    is-new-line = true
    detla-len = _len
  } else {
    h(1.5pt, weak: true)
    box(width: first-line-available-space - 1.5pt, align(center, body), inset: 0pt)
    h(1.5pt, weak: true)
  }
  // 超过一行的后续横线
  if detla-len > 5pt {
    // 计算可以画多少完整的条数
    let _ratio = detla-len / (page.width - page.margin * 2)
    // 多条完整线
    for _ in range(calc.floor(_ratio)) {
      (
        box(width: 100%)[
          #if is-new-line {
            align(center, body)
            is-new-line = false
            v(-offset)
          }]
          + hide("")
      )
    }

    // 最后一行的线
    let _last-line-len = calc.fract(_ratio)
    (
      box(width: _last-line-len * 100%)[
        #if is-new-line {
          align(center, body)
        }
        #v(-offset)
      ]
        + hide("")
    )
    h(1.5pt, weak: true)
  }
}

// 填空的横线
#let fillin(
  body,
  len: 1cm,
  placeholder: "▴",
  with-number: false,
  update: false,
  stroke: .45pt + luma(0),
  offset: 3pt,
) = context {
  assert(type(len) == length, message: "expect length, got " + str(type(len)))

  let result = _get-answer(body, placeholder, with-number, update)

  if (
    not answer-state.get() or result.child == [] or result.child == [ ]
  ) {
    _draw-line(len, stroke, offset / 2, result)
    return
  }

  underline(
    evade: false,
    offset: offset,
    stroke: stroke,
    result,
  )
}

// 选项的括号
#let paren(
  body,
  justify: false,
  placeholder: "▴",
  with-number: false,
  update: false,
) = context {
  let result = _get-answer(body, placeholder, with-number, update)
  [#if justify { h(1fr) } else { h(0pt, weak: true) }（~~#result~~）]
}

// 类似英文中的7选5题型专用语法糖
#let parenn = paren.with(with-number: true, update: true)
#let fillinn = fillin.with(with-number: true, update: true)
