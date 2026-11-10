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
  assert(_len > 4pt, message: "len must > 4pt")

  set box(stroke: (bottom: stroke), inset: (bottom: offset), outset: (bottom: offset))

  let page-width = page.width
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
  let rest-len = _len - first-line-available-space
  let is-line-break = false
  let space = 1pt
  // 当前行剩余空间 < 10pt时，则直接换行在新的一行从头开始画
  if first-line-available-space < 10pt {
    [ \ ]
    is-line-break = true
    rest-len = _len
  } else {
    // 当前指定长度 > 当前行剩余空间 >= 10pt，则按照当前行的剩余空间画线
    first-line-available-space = 1fr
    // 如果当前指定长度 < 剩余空间，则按照指定长度在文字后画线
    // 不清楚为啥按照指定长度画第一行线时，在一些特殊的值下 box 会换行。明明宽度是小于可用宽度的,猜测跟精度有关
    // 为了解决上述 bug，所以减了 text.size，确保留有足够的宽度给 box
    if rest-len < 0pt {
      first-line-available-space = _len - space * 2 - text.size
    }
    // 第一行线
    h(space, weak: true)
    box(width: first-line-available-space, inset: 0pt, align(center, body))
    h(space, weak: true)
  }

  if type(first-line-available-space) == fraction [ \ ]

  // 超过一行的后续横线
  if rest-len > 5pt {
    // 计算可以画多少完整的条数
    let _ratio = rest-len / (page.width - page.margin * 2)
    // 多条完整线
    // + "" 是为了解决多条线时，最后一行线与之前的线间距不等的问题
    (
      (
        box(width: 100%)[#if is-line-break {
          align(center, body)
          is-line-break = false
        }]
          + ""
      )
        * calc.trunc(_ratio)
    )

    // 最后一行的线
    // + "" 是为了解决最后一行线，在这条线之后如果加文本线的间距变大问题
    box(width: calc.fract(_ratio) * 100% + space)[#if is-line-break { align(center, body) }] + ""
    h(space, weak: true)
  }
}

// 填空的横线
#let fillin(
  body,
  len: 1.5cm,
  placeholder: "▴",
  with-number: false,
  update: false,
  stroke: .45pt + luma(0),
  offset: 3pt,
) = context {
  assert(type(len) == length, message: "expect length, got " + str(type(len)))

  let result = _get-answer(body, placeholder, with-number, update)
  if not answer-state.get() or result.child in ([], [ ]) {
    return _draw-line(len, stroke, offset / 2, result)
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
