#import "../utils/custom-cuti.typ": fakebold
#import "../utils/style.typ": font_family, font_size
#import "../utils/double-underline.typ": double-underline
#import "../utils/invisible-heading.typ": invisible-heading

//! 中文摘要页
//! 1. 标题：中文字体为黑体，三号，大纲级别1级，居中无缩进，“摘要”二字中间空2个汉字字符或4个半角空格，段前48磅，段后24磅，1.5倍行距。
//! 2. 内容：中文字体为宋体，英文和数字为Times New Roman字体，小四号，大纲级别正文文本，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。
//! 关键词：宋体小四号加粗，其后关键词中文字体为宋体，英文和数字为Times New Roman字体，小四号，大纲级别正文文本，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。每一关键词之间用全角分号隔开“；”最后一个关键词后不打标点符号。关键词前空1行，空白行的字号为小四号。

#let abstract(
  // thesis 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  keywords: (),
  outline-title: "摘　　要",
  outlined: true,
  anonymous-info-keys: ("author", "supervisor", "supervisor-ii"),
  leading: 1.5em,
  spacing: 1.5em,
  body,
) = {
  //? 1.  默认参数
  fonts = font_family + fonts

  //? 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  [
    //* 标记一个不可见的标题用于目录生成
    #invisible-heading(level: 1, outlined: outlined, outline-title)

    #align(center)[
      #set text(font: fonts.黑体, size: font_size.三号, weight: "bold")
      #set par(leading: leading)
      #v(48pt)
      #fakebold(base-weight: "regular")[#outline-title]
      #v(24pt)
    ]

    #set text(font: fonts.宋体, size: font_size.小四)
    #set par(leading: leading, justify: true, spacing: spacing, first-line-indent: (amount: 2em, all: true))

    #body


    #v(1em)

    #fakebold[关键词：]#(("",) + keywords.intersperse("；")).sum()
  ]
}
