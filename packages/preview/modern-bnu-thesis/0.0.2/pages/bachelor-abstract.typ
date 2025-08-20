#import "../utils/custom-cuti.typ": fakebold
#import "../utils/style.typ": 字号, 字体
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading

// 本科生中文摘要页
#let bachelor-abstract(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "摘　　要",
  outlined: true,
  anonymous-info-keys: ("author", "supervisor", "supervisor-ii"),
  leading: 1.28em,
  spacing: 1.28em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    (
      title: ("基于 Typst 的", "北京师范大学大学学位论文"),
      author: "张三",
      department: "某学院",
      major: "某专业",
      supervisor: ("李四", "教授"),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 3.  内置辅助函数
  let info-value(key, body) = {
    if (not anonymous or (key not in anonymous-info-keys)) {
      body
    }
  }

  // 4.  正式渲染
  pagebreak(weak: true)


  [
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true, spacing: spacing)
    // #show par: set block()

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(font: 字体.宋体, size: 字号.三号)

      #v(1em)

      #text((("",) + info.title).sum(),weight: "extrabold")
    ]

    #v(15pt)

    #align(center)[
      #set text(font: 字体.宋体, size: 字号.小三)
      #text(weight:"bold")[摘　　要]
    ]

    #[
      #set par(first-line-indent: (amount: 2em, all: true))
      #body
    ]




    #v(1em)

    #h(2em)#text(font: 字体.等宽, size: 字号.小四, "关键词：",weight: "bold")#(("",) + keywords.intersperse("；")).sum()
  ]

  if twoside {
    pagebreak()
    counter(page).update(n => { (n - 1) })
    set page(numbering: none)
    ""
  }
}
