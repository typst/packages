#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-heading.typ": heading-content, header
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd
#import "../utils/zh-aio.typ":*

// 研究生目录生成
#let master-outline-page(
  // documentclass 传入参数
  doctype: "master",
  show-heading: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 2,
  title: "目录",
  heading-title: "目录",
  outlined: false,
  title-vspace: 0pt,
  title-text-args: auto,
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: 字号.小四,
  // 字体与字号
  font: auto,
  size: (字号.四号, 字号.小四),
  weight: ("bold", "bold", "regular"),
  // 垂直间距
  above: (14pt, 14pt),
  below: (14pt, 14pt),
  indent: (0pt, 1em, 1em),
  // 全都显示点号
  fill: (repeat([.], gap: 0em),),
  gap: .3em,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.三号, weight: "bold")
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  // 字体与字号
  if font == auto {
    font = (fonts.黑体, fonts.黑体, fonts.宋体)
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 设置页眉
  set page(header: header())
  let title = "目录"
  heading(level: 1, outlined: false, title)

  // v(title-vspace)
  set text(font: 字体.宋体, size: 字号.小四, top-edge: "ascender", bottom-edge: "descender")
  // 目录样式
  // v(3pt)
  // set par(leading: 4pt, spacing: 0em)
  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())
  // show outline.entry: entry => {
  //   let body = entry.body()
  //   if body.has("text") and body.text in "摘要 Abstract" {} else {
  //     entry
  //   }
  // }
  v(4pt)
  show outline.entry: entry => block(
    // above: above.at(entry.level - 1, default: above.last()),
    // below: below.at(entry.level - 1, default: below.last()),
    // above: 3pt,
    // below: 3pt,
    //
    // inset: 3pt,
    height: 18pt,
    link(entry.element.location(), entry.indented(none, {
      text(font: "SimSun", size: 字号.小四, {
        // set align(center + horizon)
        if entry.prefix() not in (none, []) {
          entry.prefix()
          h(.5em)
        }
        let body = entry.body()
        if body.has("text") and body.text in "摘要 Abstract" {} else {
          set text(font: 字体.宋体)
          entry.body()
          box(height: zh(5), width: 1fr, fill.at(entry.level - 1, default: fill.last()))
          entry.page()
        }
      })
    }, gap: 0pt)),
  )

  // 显示目录
  outline(title: none, depth: depth)
}