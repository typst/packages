#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": font_family, font_size

//! 目录
//! 目录为学位论文各章节标题的顺序列表。目录另起一页，每行均由标题名称和页码组成，列至三级标题。目录从中文摘要开始，至论文结束。目录标题要求简明扼要，概括阐述内容的重点，无标点符号。
//! 1. 标题: 黑体，三号，居中无缩进，“目录”二字中间空2个汉字字符或4个半角空格，大纲级别一级，段前48磅，段后24磅，1.5倍行距。
//! 编码规则：“摘要”至“符号和缩略语说明”部分用大写罗马数字编排页码，从正文（引言）开始单独编排页码，页码号用阿拉伯数字标注，引言第一页页码为“1”，页码位于页面下方居中无缩进，采用Times New Roman字体，五号字。
//! 2. 内容: 一级目录中文字体为黑体，二级和三级目录中文字体为宋体，英文和数字为Times New Roman字体，小四号，两端对齐，段前0行，段后0行，1.5倍行距。
//! 一级目录项首行无缩进，左右缩进0字符
//! 二级目录项首行无缩进，左缩进1字符，右缩进0字符
//! 三级目录项首行无缩进，左缩进2字符，右缩进0字符

#let outline-page(
  // thesis 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 4,
  title: "目　　录",
  outlined: true,
  title-vspace: 24pt,
  title-text-args: auto,
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: font_size.小四,
  // 字体与字号
  font: auto,
  size: (font_size.小四, font_size.小四),
  // 垂直间距
  above: (6pt, 2pt),
  below: (16pt, 16pt),
  indent: (0pt, 12pt, 12pt),
  // 全都显示点号
  fill: (repeat([.], gap: 0.15em),),
  gap: 0.3em,
  ..args,
) = {
  //? 1.  默认参数
  fonts = font_family + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: font_size.三号, weight: "bold")
  }
  //? 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  //? 字体与字号
  if font == auto {
    font = (fonts.黑体, fonts.宋体)
  }

  //? 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  //? 默认显示的字体
  set text(font: reference-font, size: reference-size)

  {
    set align(center)
    set par(leading: 1.5em)
    v(48pt)
    text(..title-text-args, title)
    //* 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

  //? 目录样式
  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())
  show outline.entry: entry => block(
    above: above.at(entry.level - 1, default: above.last()),
    below: below.at(entry.level - 1, default: below.last()),
    link(
      entry.element.location(),
      entry.indented(
        none,
        {
          text(
            font: font.at(entry.level - 1, default: font.last()),
            size: size.at(entry.level - 1, default: size.last()),
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
            },
          )
          box(width: 1fr, inset: (x: .25em), fill.at(entry.level - 1, default: fill.last()))
          entry.page()
        },
        gap: 0pt,
      ),
    ),
  )

  // 显示目录
  outline(title: none, depth: depth)
}
