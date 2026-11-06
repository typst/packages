#import "../utils/style.typ": 字号, 字体

// 中英双语图片标题函数（支持手动编号）
#let bilingual-figure(
  body,
  caption: none,
  caption-en: none,
  kind: "figure",
  supplement: auto,
  numbering: "1.1",  // 使用章节-序号格式
  gap: 0.65em,       // 图片与标题间距
  caption-position: bottom, // 标题位置
  manual-number: none, // 手动指定编号
) = context {
  show figure.caption: c => c.body
  let sup = if supplement == auto {
    if kind == "figure" { "图" }
    else if kind == "table" { "表" }
    else { kind }
  } else { supplement }

  let sup-en = if supplement == auto {
    if kind == "figure" { "Figure" }
    else if kind == "table" { "Table" }
    else { kind }
  } else { supplement }

  // 创建显示编号的函数
  let display-number = if manual-number != none {
    manual-number
  } else {
    counter(kind).display(numbering)
  }

  set figure.caption(position: caption-position)

  figure(
    body,
    caption: if caption != none {
      [
        #set text(font: 字体.宋体, size: 字号.小四, weight: "regular")
        #set align(center)
        #sup #display-number #caption

        #if caption-en != none {
          [
            #set text(font: 字体.宋体, size: 字号.五号, weight: "regular")
            #set align(center)
            #sup-en #display-number #caption-en
          ]
        }
      ]
    } else [],
    kind: kind,
    gap: gap,
    supplement: "",  // 设置为空字符串，因为我们已在caption中手动处理
    numbering: none,
  )
}