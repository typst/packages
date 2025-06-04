#import "../imports.typ": show-cn-fakebold

// 文稿设置，可以进行一些像页面边距这类的全局设置
#let meta(
  // from entry
  info: (:),
  // options
  lang: "zh",
  region: "cn",
  margin: (x: 89pt),
  fallback: false, // 字体缺失时使用 fallback，不显示豆腐块
  // self
  it,
) = {
  // 1.  默认参数
  info = (
    (
      title: ("基于 Typst 的", "清华大学学位论文"),
      author: "张三",
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  基本的样式设置
  show: show-cn-fakebold

  set text(fallback: fallback, lang: lang, region: region)

  set page(margin: margin)

  // 4.  PDF 元信息
  set document(
    title: (("",) + info.title).sum(),
    author: info.author,
  )

  it
}

#let doc(
  // from entry
  fonts: (:),
  // options
  indent: 2em,
  justify: true,
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 1.5 * 15.6pt - 0.7em,
  code-block-leading: 1em,
  code-block-spacing: 1em,
  // self
  it,
) = {
  set par(
    justify: justify,
    leading: leading,
    spacing: spacing,
    first-line-indent: (amount: indent, all: true),
  )

  set list(indent: indent)

  show raw: set text(font: fonts.Mono)

  show raw.where(block: true): set par(
    leading: code-block-leading,
    spacing: code-block-spacing,
  )

  show terms: set par(first-line-indent: 0em)

  it
}
