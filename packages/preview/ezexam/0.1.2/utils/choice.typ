/*
 column: 列数
 c-gap: 列间距
 r-gap: 行间距
 indent: 选项的缩进
 body-indent: 选项和标签之间的距离
 ..choices: 选项
*/
#let choices(
  column: auto,
  c-gap: 0pt,
  r-gap: 25pt,
  indent: 0pt,
  body-indent: 5pt,
  top: 0pt,
  bottom: 0pt,
  label: "A.",
  ..choices,
) = {
  // 使用layout获取当前父元素的宽度
  layout(container => {
    let arr = choices.pos()
    let choice-number = arr.len()
    if choice-number == 0 { return }
    let max-width = 0pt
    // 拼接选项并添加标签和间距;获取选项中最长的宽度
    for index in range(choice-number) {
      // 加[] 是为了将内容转为content,有可能在使用时直接传入整数
      let choice = [#arr.at(index)]

      // 选项为图片的处理
      let _choice-width = none
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

      let item-width = measure(arr.at(index)).width
      if _choice-width == none {
        _choice-width = item-width
      } else {
        _choice-width += item-width
      }
      max-width = calc.max(max-width, _choice-width)
    }

    let _column = column
    // 如果未指定列数,则自动排列,默认4列
    if column == auto {
      _column = 4
      // 选项实际占用的宽度
      let choice-width = max-width + c-gap
      // 1行排列选项之间的间距
      let one-row-choice-gap = container.width / choice-number - choice-width
      // 2行排列选项之间的间距
      let two-row-choice-gap = container.width / (choice-number / 2) - choice-width
      let choice-min-gap = 0.15in
      if one-row-choice-gap < choice-min-gap {
        if two-row-choice-gap < choice-min-gap {
          _column = 1
        } else {
          _column = 2
        }
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
}

