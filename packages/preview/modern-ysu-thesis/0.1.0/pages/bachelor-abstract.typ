#import "../utils/custom-cuti.typ": fakebold
#import "../utils/style.typ": 字号, 字体
#import "../utils/indent.typ": fake-par
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/custom-heading.typ": header-display

// 本科生中文摘要页
#let bachelor-abstract(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "摘　要",
  outlined: true,
  anonymous-info-keys: ("author", "supervisor", "supervisor-ii"),
  leading: 22pt,
  spacing: 1.28em,
  body,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
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
  pagebreak(weak: true,to:"odd" )
  [
    
    #set text(font: fonts.宋体, size: 字号.小四)
    #set par(leading: leading, justify: true)
    #show par: set block(spacing: spacing)

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)
    #align(center)[
      #v(1em)
      #set text(font:fonts.黑体,size: 字号.小二, weight: "bold")
      #v(0.8em)
      摘　要
    ]

    #[
      #set par(first-line-indent: 2em)
      #fake-par
      #body
    ]

    #v(1em)
    #grid(columns: (auto,auto),
    text(font:fonts.黑体,)[关键词：],
    keywords.intersperse("；").sum(),
    )
  ]
}