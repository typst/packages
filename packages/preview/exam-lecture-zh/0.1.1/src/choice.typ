/*
 column: 列数
 c-gap: 列间距
 r-gap: 行间距
 indent: 选项的缩进
 body-indent: 选项和标签之间的距离
 ..options: 选项
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
  ..options,
) = context {
  let arr = options.pos()
  let choice-number = arr.len()
  if choice-number == 0 { return }
  let max-width = 0pt
  // 拼接选项并添加标签和间距;获取选项中最长的宽度
  for index in range(choice-number) {
    // 加[] 是为了将内容转为content,有可能咋使用时直接传入整数
    let result = [#arr.at(index)]
    // 选项为图片的处理
    if result.func() == image {
      result = box(baseline: 40%, result)
    }
    // 选项为表格的处理
    if result.func() == table {
      result = box(baseline: 40%, inset: (left: body-indent), result)
    }

    arr.at(index) = h(indent) + numbering(label, index + 1) + h(body-indent) + result

    max-width = calc.max(max-width, measure(arr.at(index)).width)
  }
  // 根据选项内容自动排列选项;使用layout获取当前父元素的宽度
  layout(container => {
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

