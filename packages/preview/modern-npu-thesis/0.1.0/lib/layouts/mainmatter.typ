#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字体, 字号
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/custom-heading.typ": active-heading, heading-display
#import "../utils/unpairs.typ": unpairs
#import "../utils/header.typ": graduate-header-title, header-render
#import "../layouts/preface.typ": heading-above as level1-heading-above, heading-below as level1-heading-below

#let mainmatter(
  // documentclass 传入参数
  twoside: false,
  doctype: "bachelor",
  fonts: (:),
  // 其他参数
  leading: 0.9em,
  spacing: 1.0em,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  numbering: custom-numbering.with(
    first-level: n => [#("第" + str(n) + "章　")],
    depth: 4,
    "1.1 ",
  ),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.三号, 字号.四号, 字号.小四),
  heading-weight: ("regular", "regular", "regular"),
  // 一级标题使用统一配置，二三级保持原有值
  heading-above: (level1-heading-above, 2 * 15.6pt - 0.7em, 2 * 15.6pt - 0.7em),
  heading-below: (level1-heading-below, 1.5 * 15.6pt - 0.7em, 1.5 * 15.6pt - 0.7em),
  heading-pagebreak: (true, false, false),
  heading-align: (center, auto, auto),
  // 页眉
  display-header: false,
  stroke-width: 0.5pt,
  reset-footnote: true,
  // caption 的 separator
  separator: "  ",
  // caption 样式（宋体五号不加粗）
  caption-style: it => it,
  caption-size: 字号.五号,
  // figure 计数
  show-figure: i-figured.show-figure.with(numbering: "1-1"),
  // equation 计数
  show-equation: i-figured.show-equation.with(
    numbering: (..nums) => text(font: "Times New Roman")[#numbering("(1-1)", ..nums)],
  ),
  ..args,
  it,
) = {
  numbering = custom-numbering.with(
    first-level: n => [第 #n 章#h(0.7em)],
    depth: 4,
    "1.1 ",
  )
  // 1.  默认参数（提前初始化 fonts）
  fonts = 字体 + fonts
  if text-args == auto {
    text-args = (font: fonts.宋体, size: 字号.小四)
  }
  // 1.1 字体与字号
  if heading-font == auto {
    heading-font = (fonts.黑体,)
  }

  // 双面打印时确保正文从奇数页开始
  pagebreak(weak: true, to: if twoside { "odd" })

  // 重置页码为阿拉伯数字从1开始
  counter(page).update(1)
  set page(
    footer: context align(center)[
      #set text(size: 字号.小五)
      #counter(page).display("1")
    ],
  )

  // 2.  处理 heading- 开头的其他参数
  let heading-text-args-lists = args
    .named()
    .pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 3.  辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  // 4.  设置基本样式
  // 4.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    first-line-indent: first-line-indent,
    spacing: spacing,
  )
  show raw: set text(font: fonts.等宽)
  // 4.2 脚注样式
  show footnote.entry: set text(font: fonts.宋体, size: 字号.五号)
  // 4.3 设置 figure 的编号
  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure.with(numbering: "1-1")
  // 4.4 设置 equation 的编号和假段落首行缩进
  show math.equation.where(block: true): show-equation
  // 4.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(font: fonts.宋体, size: 字号.五号)
  // figure 内部文本（如子图标题）使用宋体五号
  show figure: set text(font: fonts.宋体, size: 字号.五号)
  // 表格内容使用五号字体
  show table: set text(font: fonts.宋体, size: 字号.五号)
  // 4.6 优化列表显示
  //     术语列表 terms 不应该缩进
  show terms: set par(first-line-indent: 0pt)

  // 5.  处理标题
  // 5.1 设置标题的 Numbering
  set heading(numbering: numbering)
  // 5.2 设置字体、字号、换页及段前段后间距
  show heading: it => {
    if it.level == 1 {
      counter(figure.where(kind: "algorithm")).update(0)
    }

    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(heading-text-args-lists.map(pair => (pair.at(0), array-at(pair.at(1), it.level)))),
    )

    let needs-pagebreak = false
    if array-at(heading-pagebreak, it.level) {
      if "label" not in it.fields() or str(it.label) != "no-auto-pagebreak" {
        needs-pagebreak = true
      }
    }

    if needs-pagebreak {
      if it.level == 1 {
        // 如果是双面打印，一级标题换页需要跳转到奇数页
        pagebreak(weak: true, to: if twoside { "odd" })
      } else {
        pagebreak(weak: true)
      }
      // 手动添加页首被忽略的顶部间距
      v(array-at(heading-above, it.level))
    }

    // 设置段前段后间距。如果有换页，则 block() 的 above 设为 0pt 防止双倍间距
    let current-block-above = if needs-pagebreak { 0pt } else { array-at(heading-above, it.level) }
    let current-block-below = array-at(heading-below, it.level)

    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      set block(above: current-block-above, below: current-block-below)
      it
    } else {
      set block(above: current-block-above, below: current-block-below)
      it
    }
  }

  // 6.  处理页眉
  set page(..(
    if display-header {
      (
        header: context {
          // 重置 footnote 计数器
          if reset-footnote {
            counter(footnote).update(0)
          }
          let loc = here()
          // 判断是否为研究生
          let is-graduate = doctype == "master" or doctype == "doctor"
          // 页眉内容
          let header-content = if twoside and calc.rem(loc.page(), 2) == 0 and is-graduate {
            // 偶数页：显示论文标题
            graduate-header-title(doctype)
          } else {
            // 奇数页或单面打印：显示当前章标题
            heading-display(active-heading(level: 1, prev: false))
          }
          // 使用统一的页眉格式
          header-render(header-content, fonts: fonts)
        },
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
  ))

  it
}
