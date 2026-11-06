#let choices(
  column: auto,
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
  let arr = options.pos()
  let choice-number = arr.len()
  if choice-number == 0 { return }
  let max-width = 0pt
  // 拼接选项并添加标签和间距;获取选项中最长的宽度
  for index in range(choice-number) {
    // 加[] 是为了将内容转为content,有可能在使用时直接传入整数
    let choice = [#arr.at(index)]

    // 选项为图片的处理
    let _choice-width = 0pt
    if choice.func() == image {
      // 当选项为图片时,设置百分比宽度使用mesure获取宽度时为0pt, 设置百分比宽度的处理
      if choice.has("width") and choice.width.length == 0pt {
        _choice-width = choice.width.ratio * container.width
      }
      choice = box(baseline: 40%, choice)
    }

    // 选项为表格的处理
    if choice.func() == table {
      choice = box(baseline: 40%, choice, inset: (left: body-indent * 2))
    }

    arr.at(index) = par(
      hanging-indent: 1.5em,
      h(indent) + numbering(label, index + 1) + h(body-indent) + choice,
    )

    if column != auto { continue }
    _choice-width += measure(arr.at(index)).width
    max-width = calc.max(max-width, _choice-width)
  }

  let _column = column
  // 如果未指定列数,则自动排列,默认4列
  if column == auto {
    _column = 4
    let actual-occupied-width = max-width + c-gap
    // 排成1行,选项之间的间距
    let choice-gap = container.width / choice-number - actual-occupied-width
    let min-gap = 0.15in
    if choice-gap < min-gap {
      _column = 2
      // 排成2行,选项之间的间距
      choice-gap = choice-gap * 2 + actual-occupied-width
      if choice-gap < min-gap { _column = 1 }
    }
  }

  grid(
    columns: _column * (1fr,),
    column-gutter: c-gap,
    row-gutter: r-gap,
    align: horizon,
    inset: (top: top, bottom: bottom),
    ..arr
  )
})

