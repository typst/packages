#import "../utils/custom-cuti.typ": fakebold
#import "../utils/style.typ": font-family, font-size
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading

//! 英文摘要页
//! 1. 标题：Times New Roman，三号，加粗，大纲级别1级，居中无缩进，段前48磅，段后24磅，1.5倍行距。
//! 2. 内容：Times New Roman，小四号，大纲级别正文文本，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。外文中使用半角标点符号，且标点符号后面应该有一个半角空格。
//! 3. Key words：Times New Roman，小四号加粗，其后关键词为Times New Roman，小四号，大纲级别正文文本，两端对齐，悬挂缩进5.95字符，段前0行，段后0行，1.5倍行距。每一关键词之间用半角分号分开“;”最后一个关键词后不打标点符号。关键词前空1行，空白行的字号为小四号。
#let abstract-en(
  // thesis 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "Abstract",
  outlined: true,
  anonymous-info-keys: ("author-en", "supervisor-en", "supervisor-ii-en"),
  leading: 1.5em,
  spacing: 1.5em,
  body,
) = {
  // 1.  默认参数
  fonts = font-family + fonts

  // 2.  正式渲染
  [
    #pagebreak(weak: true, to: if twoside { "odd" })

    // 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #v(48pt)
      #set text(size: font-size.三号, weight: "bold")
      #v(24pt)
      Abstract
    ]

    #set text(font: fonts.宋体, size: font-size.小四)
    #set par(leading: leading, justify: true, spacing: spacing, first-line-indent: (amount: 2em, all: true))

    #body

    #v(1em)
    #grid(
      columns: (5.95em, auto),
      column-gutter: 0em,
      fakebold[Key words:], (("",) + keywords.intersperse("; ")).sum(),
    )
  ]
}
