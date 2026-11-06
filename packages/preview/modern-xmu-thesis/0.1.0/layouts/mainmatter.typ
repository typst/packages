#import "@preview/i-figured:0.2.4"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/hydra:0.6.0": hydra
#import "../utils/style.typ": 字号, 字体
#import "../utils/unpairs.typ": unpairs

#let mainmatter(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 1.5 * 15.6pt - 0.7em,
  justify: true,
  first-line-indent: (amount: 2em, all: true),
  numbering: numbly("第{1:一}章   ", "{1}.{2} "),
  // 正文字体与字号参数
  text-args: auto,
  // 标题字体与字号
  heading-font: auto,
  heading-size: (字号.小三, 字号.四号, 字号.小四),
  heading-weight: ("regular",),
  heading-above: (2 * 15.6pt - 0.7em, 2 * 15.6pt - 0.7em),
  heading-below: (2 * 15.6pt - 0.7em, 1.5 * 15.6pt - 0.7em),
  heading-pagebreak: (true, false),
  heading-align: (center, auto),
  // 页眉
  header-render: auto,
  header-vspace: 0em,
  display-header: false,
  skip-on-first-level: true,
  stroke-width: 0.5pt,
  reset-footnote: true,
  // caption 的分隔符
  separator: "  ",
  // caption 样式
  caption-style: strong,
  caption-text-size: 字号.五号,
  // figure 计数
  show-figure: i-figured.show-figure,
  // equation 计数
  show-equation: i-figured.show-equation,
  ..args,
  it,
) = {
  // 0.  标志前言结束
  set page(footer: none)
  pagebreak(weak: true, to: if twoside { "odd" })

  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "厦门大学本科毕业论文模板"),
    title-en: "An XMU Undergraduate Thesis Template\nPowered by Typst",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    department: "某学院",
    major: "某专业",
    supervisor: ("李四", "教授"),
    submit-date: datetime.today(),
  ) + info
  // 1.1 字体与字号
  if (text-args == auto) {
    text-args = (font: fonts.宋体, size: 字号.小四)
  }
  if (heading-font == auto) {
    heading-font = (fonts.黑体,)
  }
  // 1.2 处理 heading- 开头的其他参数
  let heading-text-args-lists = args.named().pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (pair.at(0).slice("heading-".len()), pair.at(1)))

  // 2.  辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  // 3.  设置基本样式
  // 3.1 文本和段落样式
  set text(..text-args)
  set par(
    leading: leading,
    spacing: spacing,
    justify: justify,
    first-line-indent: first-line-indent,
  )
  show raw: set text(font: fonts.等宽)
  // 3.2 脚注样式
  set footnote(numbering: "①")
  show footnote.entry: set text(font: fonts.宋体, size: 字号.小五)
  // 3.3 设置 figure 的编号
  show heading: i-figured.reset-counters
  show figure: show-figure
  // 3.4 设置 equation 的编号
  show math.equation.where(block: true): show-equation
  // 3.5 表格表头置顶 + 不用冒号用空格分割 + 样式
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(font: fonts.宋体, size: caption-text-size)

  // 4.  处理标题
  // 4.1 设置标题的 Numbering
  set heading(numbering: numbering)
  // 4.2 设置字体字号
  show heading: it => {
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(heading-text-args-lists
        .map((pair) => (pair.at(0), array-at(pair.at(1), it.level))))
    )
    set block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
    )
    it
  }
  // 4.3 标题居中与自动换页
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
      // 如果打上了 no-auto-pagebreak 标签，则不自动换页
      if "label" not in it.fields() or str(it.label) != "no-auto-pagebreak" {
        pagebreak(weak: true)
        block() // 用于使页顶处的 heading 的 above 属性生效
      }
    }
    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  // 5.  页眉配置
  set page(..(
    header: {
      // 重置 footnote 计数器
      if reset-footnote {
        counter(footnote).update(0)
      }
      context {
        set text(font: fonts.宋体, size: 字号.小五)
        align(
          center,
          if calc.odd(here().page()) {
            hydra(skip-starting: false, use-last: true, 1)
          } else {
            info.title.join()
          },
        )
      }
      // 分隔线
      place(bottom, dy: 0.35em, line(length: 100%, stroke: 0.5pt))
    },
  ))

  set page(footer: context {
    set text(font: fonts.宋体, size: 字号.小五)
    align(center, counter(page).display("1"))
  })
  counter(page).update(1)
  it
}
