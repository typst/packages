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
  // 只显示下划线；根据给定的len绘制
  if _len <= 0pt { panic("len must > 0") }
  // 第一行横线开始位置及长度
  let page-width = page.width
  let _columns = page.columns

  if page.flipped {
    page-width = page.height
  }

  if _columns > 1 {
    page-width = (page-width + columns.gutter * (_columns - 1)) / _columns
  }

  let first-line-available-space = page-width - page.margin - here().position().x

  // 第一行线
  // 如果当前指定长度 <= 剩余空间，则直接按照指定长度在文字后画线，否则，则需要在指定文字后先画一部分；
  let detla-len = (_len - first-line-available-space).length
  if detla-len <= 0pt {
    first-line-available-space = _len
  }

  let dy = -.682em
  if answer-state.get() { dy = 0pt }
  set box(stroke: (bottom: stroke))
  box(place(dy: dy)[#box(
    width: first-line-available-space,
    outset: (bottom: offset),
    align(center, body),
  )])

  // 画完第一行线后，画一个空行
  box(width: first-line-available-space, stroke: none)

  // 超过一行的后续横线
  if detla-len > 5pt {
    [ \ ]
    // 计算可以画多少完整的条数
    let _ratio = (_len - first-line-available-space) / (page.width - page.margin * 2)
    // 多条完整线
    for _ in range(calc.floor(_ratio)) { box(width: 100%, inset: (bottom: .682em)) }
    // 最后一行的线
    box(width: calc.fract(_ratio) * 100%)
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
  offset: 1.5pt,
) = context {
  assert(type(len) == length, message: "expect length, got " + str(type(len)))

  let result = _get-answer(body, placeholder, with-number, update)

  if (
    not answer-state.get() or result.child == [] or result.child == [ ]
  ) {
    _draw-line(len, stroke, offset, result)
    return
  }

  underline(
    evade: false,
    offset: offset,
    stroke: stroke,
    [#result],
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
  [#if justify { h(1fr) }（~~#upper(result)~~）]
}

// 类似英文中的7选5题型专用语法糖
#let parenn = paren.with(with-number: true, update: true)
#let fillinn = fillin.with(with-number: true, update: true)
