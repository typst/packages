#let choices(
  columns: auto,
  c-gap: 0pt,
  r-gap: 25pt,
  indent: 0pt,
  body-indent: 5pt,
  top: 0pt,
  bottom: 0pt,
  label: "A.",
  ..options,
) = layout(container => {
  // 使用layout获取当前父元素的宽度
  let args-named = options.named()
  assert(args-named.len() == 0, message: "choices no " + repr(args-named) + " parameters")

  let arr = options.pos()
  let choice-number = arr.len()
  assert(choice-number > 0, message: "choices must have at least one option")

  let max-width = 0pt
  // 拼接选项并添加标签和间距;获取选项中最长的宽度
  for index in range(choice-number) {
    // 加[] 是为了将内容转为content,有可能在使用时直接传入整数
    let choice = [#arr.at(index)]
    let _choice-width = 0pt
    // 选项为图片、表格的处理
    if choice.func() in (image, table) {
      // 当选项为图片时,设置百分比宽度使用mesure获取宽度时为0pt, 设置百分比宽度的处理
      if choice.has("width") and choice.width.length == 0pt {
        _choice-width = choice.width.ratio * container.width
      }
      arr.at(index) = grid(
        columns: 2,
        pad(left: indent, numbering(label, index + 1)), pad(left: body-indent, choice),
      )
    } else {
      arr.at(index) = par(
        hanging-indent: 1.5em,
        h(indent) + numbering(label, index + 1) + h(body-indent) + choice,
      )
    }

    if columns != auto { continue }
    _choice-width += measure(arr.at(index)).width
    max-width = calc.max(max-width, _choice-width)
  }

  let _columns = columns
  // 如果未指定列数,则自动排列,默认4列
  if columns == auto {
    _columns = 4
    let actual-occupied-width = max-width + c-gap
    // 排成1行,选项之间的间距
    let choice-gap = container.width / choice-number - actual-occupied-width
    let min-gap = 0.15in
    if choice-gap < min-gap {
      _columns = 2
      // 排成2行,选项之间的间距
      choice-gap = choice-gap * 2 + actual-occupied-width
      if choice-gap < min-gap { _columns = 1 }
    }
  }

  v(top)
  grid(
    columns: _columns * (1fr,),
    column-gutter: c-gap,
    row-gutter: r-gap,
    align: horizon,
    ..arr
  )
  v(bottom)
})

