#import "tools.typ": _content-start-space

#let _format-choice(choice, label, indent, spacing, label-position) = {
  // 为了解决数学公式在左侧加间距的问题
  spacing -= _content-start-space(choice)
  if choice.func() not in (image, table) {
    return par(
      hanging-indent: indent + spacing + measure(label).width,
      h(indent) + label + h(spacing, weak: true) + choice,
    )
  }

  // 选项为图片、表格的处理
  if label-position == bottom {
    return grid(
      align: center,
      inset: (left: indent),
      pad(bottom: spacing, choice),
      label,
    )
  }

  grid(
    columns: 2,
    pad(left: indent, label), pad(left: spacing, choice),
  )
}

#let _count-columns(container-width, choice-number, max-choice-width, columns) = {
  // 如果未指定列数,则自动排列,默认4列
  if columns == auto {
    columns = 4
    // 排成1行,选项之间的间距
    let choice-gap = container-width / choice-number - max-choice-width
    let min-gap = 0.15in
    if choice-gap < min-gap {
      columns = 2
      // 排成2行,选项之间的间距
      choice-gap = choice-gap * 2 + max-choice-width
      if choice-gap < min-gap { columns = 1 }
    }
  }
  columns
}

#let choices(
  columns: auto,
  c-gap: 0pt,
  r-gap: 2em,
  indent: 0pt,
  spacing: 5pt,
  top: 0pt,
  bottom: 0pt,
  label: "A.",
  label-postion: left,
  ..options,
) = {
  let args-named = options.named()
  assert(args-named.len() == 0, message: "choices no " + repr(args-named) + " parameters")
  // 使用layout获取当前父元素的宽度
  layout(container => {
    let choices-arr = options.pos()
    let choice-number = choices-arr.len()
    assert(choice-number > 0, message: "choices must have at least one option")
    // 拼接选项并添加标签和间距;获取选项中最长的宽度
    let max-width = 0pt
    for index in range(choice-number) {
      choices-arr.at(index) = _format-choice(
        [#choices-arr.at(index)],
        numbering(label, index + 1),
        indent,
        spacing,
        label-postion,
      )

      if columns != auto { continue }
      max-width = calc.max(max-width, measure(choices-arr.at(index)).width)
    }

    v(top)
    grid(
      columns: _count-columns(container.width, choice-number, max-width + c-gap, columns) * (1fr,),
      column-gutter: c-gap,
      row-gutter: r-gap,
      align: horizon,
      ..choices-arr
    )
    v(bottom)
  })
}

