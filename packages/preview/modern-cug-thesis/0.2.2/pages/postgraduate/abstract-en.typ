#import "../../utils/style.typ": 字号, 字体

// 研究生英文摘要页
#let postgraduate-abstract-en(
  // documentclass 传入的参数
  doctype: "master",
  degree: "academic",
  anonymous: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  keywords: (),
  abstract-title-weight: "bold",
  leading: 1.27em,
  spacing: 1.27em,
  body,
) = {
  // 默认参数
  fonts = 字体 + fonts

  // 正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  [
    // #v(1.27em)
    #align(center, text(font: fonts.宋体, size: 字号.小二, weight: abstract-title-weight, "Abstract", spacing: 1.27em, top-edge: 0.7em, bottom-edge: -0.3em))
    // #v(1.27em)
    #set par(leading: leading, justify: true, spacing: spacing)
    #par(first-line-indent: 2em, body)
    #set text(font: fonts.宋体, size: 字号.小四)
    *Key Words*: #(("",)+ keywords.intersperse("; ")).sum()
  ]
}

// 测试代码
#postgraduate-abstract-en(
  keywords: ("keyword1", "keyword2", "keyword3"),
  [Abstract内容与中文摘要相对应。一般不少于300个英文实词，篇幅以一页为宜。如需要，字数可以略多。]
)