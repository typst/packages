// SCUT 中文摘要
#import "../utils/style.typ": 字体, 字号, 正文字体, 正文字号, 正文段间距, 正文行距, 章标题字体, 章标题字号, 首行缩进
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/section-break.typ": section-break

#let abstract(
  doctype: "master",
  open-right: false,
  fonts: (:),
  info: (:),
  keywords: (),
  outline-title: "摘要",
  outlined: true,
  leading: 正文行距,
  spacing: 正文段间距,
  body,
) = {
  fonts = 字体 + fonts

  section-break(open-right: open-right)

  [
    #set text(font: 正文字体, size: 正文字号)
    #set par(leading: leading, justify: true, spacing: spacing)

    #invisible-heading(level: 1, outlined: outlined, outline-title)

    // 标题段独立设置段间距，使其后间距约一行正文行距
    #[
      #set par(spacing: 0.65em)
      #align(center)[
      #set text(font: 章标题字体, size: 章标题字号, weight: "bold")
      摘　　要
    ] ]

    // 规范：摘要题头后隔行书写正文
    #v(1em)

    #set par(first-line-indent: 首行缩进)
    #body

    #v(1em)

    // 关键词：标签黑体，内容宋体，不缩进
    #set par(first-line-indent: 0pt)
    #text(font: fonts.黑体)[关键词：]#(("",) + keywords.intersperse("；")).sum()
  ]
}
