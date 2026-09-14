// 占 width 的宽度, 展开所有字符, 两端对其
// [ 类 似 这 样 ]
#let fixed-width-text-justified(width: auto, body) = {
  if type(body) == str {
    return box(width: width, stack(dir: ltr, ..body.clusters().map(x => [#x]).intersperse(1fr)))
  }
  return box(width: width, body)
}

// 占 width 的宽度画下划线, 其中包含一些字符
// [     类似这样     ]
//  _________________
#let fixed-width-underline(width: auto, height: auto, body) = box(
  width: width,
  stroke: (bottom: 0.5pt),
  outset: (bottom: 0.2em),
  height: height,
  {
    // 这里设置行间距
    // 默认 leading 大约是 0.65em
    set par(leading: 0.5em) 
    body
  }
)

// 占 width 的宽度, 其中包含一些字符
// [     类似这样     ]
#let fixed-width-text(width: auto, body) = box(body, width: width, stroke: none, outset: 0pt)

// 画 width 的宽度的空白
//  类似这样 ↓
// [          ]
#let fixed-width-space(width) = box("", width: width)

#let justified-text-with-underline(text-width, underline-width, text-content, underline-content) = {
  block()[
    #fixed-width-text-justified(width: text-width, text-content)
    #h(0.5em)
    #fixed-width-underline(width: underline-width, underline-content)
  ]
}

#let fixed-text-with-underline(text-width, underline-width, text-content, underline-content) = {
  block()[
    #fixed-width-text(width: text-width, text-content)
    #h(0.5em)
    #fixed-width-underline(width: underline-width, underline-content)
  ]
}
