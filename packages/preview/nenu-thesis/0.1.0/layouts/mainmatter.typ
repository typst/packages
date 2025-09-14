#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": font_family, font_size
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/custom-heading.typ": active-heading, current-heading, heading-display
#import "../utils/unpairs.typ": unpairs

//! 正文
//! 一级标题：中文字体为黑体，西文字体为Times New Roman，三号，大纲级别1级，居中对齐，无缩进，段前48磅，段后24磅，1.5倍行距。每一章另起一页。
//! 二级标题：中文字体为黑体，西文字体为Times New Roman，四号，大纲级别2级，两端对齐无缩进，段前6磅，段后0行，1.5倍行距。
//! 三级标题: 中文采用宋体，英文和数字采用Times New Roman字体，均为小四号加粗，大纲级别3级，两端对齐，段前6磅，段后0磅，1.5倍行距。
//! 四级标题: 中文采用宋体，英文和数字采用Times New Roman字体，均为小四号，大纲级别4级，两端对齐，段前0行，段后0行，1.5倍行距。
#let mainmatter(
  // thesis 传入参数
  doctype: "bachelor",
  twoside: false,
  fonts: (:),
  // 其他参数
  leading: 1.5em,
  spacing: 1.5em,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  numbering: custom-numbering.with(first-level: "1 ", depth: 3, "1.1 "),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (font_size.三号, font_size.四号, font_size.小四),
  heading-weight: ("regular", "regular", "bold", "regular"),
  heading-above: (48pt, 6pt, 6pt, 0pt),
  heading-below: (24pt, 0pt),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 页眉
  header-render: auto,
  header-vspace: -.5em,
  display-header: true,
  skip-on-first-level: true,
  stroke-width: .8pt,
  reset-footnote: true,
  //? caption 的 separator
  //! 图名在图号之后空两个半角空格。图题后不加标点。
  separator: "  ",
  //? caption 样式
  //! 中文字体为宋体，英文和数字为Times New Roman字体，五号，居中无缩进，段前0行，段后0行，1.5倍行距。
  caption-style: (leading: 1.5em, justify: true, first-line-indent: 0pt),
  caption-size: font_size.五号,
  // figure 计数
  show-figure: i-figured.show-figure,
  // equation 计数
  show-equation: i-figured.show-equation.with(numbering: "(1-1)"),
  ..args,
  it,
) = {
  //! 0.  标志前言结束
  set page(numbering: "1")

  //! 1.  默认参数
  fonts = font_family + fonts
  if text-args == auto {
    text-args = (font: fonts.宋体, size: font_size.小四)
  }
  //? 1.1 字体与字号
  if heading-font == auto {
    heading-font = (fonts.黑体,)
  }
  //? 1.2 处理 heading- 开头的其他参数
  let heading-text-args-lists = args
    .named()
    .pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 2.  辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  //! 3.  设置基本样式
  //? 3.1 文本和段落样式
  //? 正文：中文字体为宋体，英文和数字为Times New Roman字体，小四号，大纲级别正文文本，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。引文内容可使用楷体。
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    first-line-indent: first-line-indent,
    spacing: spacing,
  )
  show raw: set text(font: fonts.等宽)
  // FIXME Reference: https://github.com/Dherse/codly/issues/73 由于 Typst 的更新导致的 BUG，后续更新 codly 可以解决
  show raw.where(block: true): set par(first-line-indent: 0pt)
  show smartquote: set text(font: fonts.楷体)
  //? 3.2 脚注样式
  //! 在需要注释处标明序号，序号加圆圈放在加注处右上角，“上标”字体标注，如①。脚注中文采用宋体，英文和数字采用Times New Roman字体,小五号字，左对齐，无缩进，段前0行，段后0行，单倍行距。每页重新编号，注释序号均从①开始
  set footnote(numbering: "①")
  show footnote.entry: set text(font: fonts.宋体, size: font_size.小五)
  //? 3.3 设置 figure 的编号
  show heading: i-figured.reset-counters
  show figure: show-figure
  //? 3.4 设置 equation 的编号和假段落首行缩进
  show math.equation.where(block: true): show-equation
  //? 3.5 表格表头置顶
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)
  //! 表单元格内容：居中书写（上下居中，左右居中），中文为宋体，英文和数字为Times New Roman字体，五号字，居中无缩进，段前0行，段后0行，单倍行距。
  show table.cell: set align(center)
  show table.cell: set par(first-line-indent: 0pt, leading: 1em, spacing: 0pt, justify: true)
  show table.cell: set text(font: fonts.宋体, size: font_size.五号)

  //? 图表样式
  set figure(gap: leading)
  set figure.caption(separator: separator)
  show figure.caption: set par(..caption-style)
  show figure.caption: set text(font: fonts.宋体, size: font_size.五号)

  //? 3.6 优化列表显示
  //*     术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: 0pt)

  //! 4.  处理标题
  //? 4.1 设置标题的 Numbering
  set heading(numbering: numbering)
  //? 4.2 设置字体字号并加入假段落模拟首行缩进
  // NOTE 这里的段前段后空的磅数不一定准确，可能需要微调
  show heading: it => {
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(heading-text-args-lists.map(pair => (pair.at(0), array-at(pair.at(1), it.level)))),
    )
    set block(
      above: 1.5em,
      below: 1.5em,
    )
    set par(first-line-indent: first-line-indent, leading: leading, spacing: spacing, justify: justify)
    v(array-at(heading-above, it.level))
    it
    v(array-at(heading-below, it.level))
  }
  //? 4.3 标题居中与自动换页
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
      //? 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if "label" not in it.fields() or str(it.label) != "no-auto-pagebreak" {
        pagebreak(weak: true)
      }
    }
    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  //! 5. 页眉
  //! 论文从正文（引言）开始每页设置页眉，
  //! 中文论文页眉为“东北师范大学博（硕）士学位论文”，英文论文页眉为“NENU PhD & Masters Dissertation”。
  //! 中文采用黑体，英文采用Times New Roman字体，均为小四号，居中无缩进。
  //! 页眉边距1.5厘米，页脚边距1.75厘米。(指代页眉/页脚距离页面边缘的距离)
  set page(
    ..(
      if display-header {
        (
          header: context {
            // 重置 footnote 计数器
            if reset-footnote {
              counter(footnote).update(0)
            }
            set text(font: fonts.黑体, size: font_size.小四)
            set par(first-line-indent: 0pt, leading: leading, spacing: spacing, justify: true)
            set align(center)
            if doctype != "bachelor" {
              if doctype == "master" { "东北师范大学硕士学位论文" } else if doctype == "doctor" {
                "东北师范大学博士学位论文"
              }
              v(header-vspace)
              line(length: 100%, stroke: stroke-width)
            }
          },
          header-ascent: .25cm,
        )
      } else {
        (
          header: {
            // 重置 footnote 计数器
            if reset-footnote {
              counter(footnote).update(0)
            }
          },
        )
      }
    ),
    footer: [
      #set align(center)
      #set text(font: font_family.宋体, size: font_size.五号)
      #context counter(page).display("1")
    ],
    footer-descent: .25cm,
  )

  // context {
  //   if calc.even(here().page()) {
  //     set page(numbering: "I", header: none)
  //     // counter(page).update(1)
  //     pagebreak() + " "
  //   }
  // }

  counter(page).update(1)

  it
}
