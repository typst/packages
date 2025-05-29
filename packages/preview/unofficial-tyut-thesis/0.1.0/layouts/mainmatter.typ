#import "@preview/numbly:0.1.0": numbly
#import "@preview/pointless-size:0.1.1": zh
#import "@preview/i-figured:0.2.4"
#import "@preview/cuti:0.3.0": show-cn-fakebold

#let mainmatter(
  twoside: false,
  leading: 1.5 * 15.6pt - 0.7em,
  spacing: 1.5 * 15.6pt - 0.7em,
  justify: true,
  text-args: auto,
  heading-font: auto,
  first-line-indent: (amount: 2em, all: true),
  mono-font: ("Courier New", "LXGW WenKai Mono GB"),
  numbering: numbly(
    "{1}. ",
    "{1}.{2} ",
    "{1}.{2}.{3} ",
    "{1}.{2}.{3}.{4} ",
    "{1}.{2}.{3}.{4}.{5} ",
    "{1}.{2}.{3}.{4}.{5}.{6} ",
  ),
  heading-weight: ("regular",),
  heading-above: (2 * 15.6pt - 0.7em, 2 * 15.6pt - 0.7em),
  heading-below: (2 * 15.6pt - 0.7em, 1.5 * 15.6pt - 0.7em),
  heading-pagebreak: (true, false),
  heading-size: (zh(-3), zh(4), zh(-4)),
  heading-align: (center, auto),
  show-figure: i-figured.show-figure.with(numbering: "1-1"),
  show-equation: i-figured.show-equation.with(numbering: "(1-1)"),
  caption-style: none,
  caption-size: zh(5),
  separator: "  ",
  ..args,
  it,
) = {
  // 辅助函数
  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }
  let unpairs(pairs) = {
    let dict = (:)
    for pair in pairs {
      dict.insert(..pair)
    }
    dict
  }

  let heading-text-args-lists = args
    .named()
    .pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (
      pair.at(0).slice("heading-".len()),
      pair.at(1),
    ))

  // 页码设置
  set page(numbering: (..nums) => text(size: zh(-5), [#nums.at(0)]))
  counter(page).update(1)

  // 字体
  if text-args == auto {
    text-args = (font: ("Times New Roman", "SimSun"), size: zh(-4))
  }
  if heading-font == auto {
    heading-font = (("Times New Roman", "SimHei"),)
  }

  // 标题设置
  set heading(numbering: numbering)
  show heading: it => {
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: array-at(heading-weight, it.level),
      ..unpairs(heading-text-args-lists.map(pair => (pair.at(0), array-at(pair.at(1), it.level)))),
    )
    set block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
    )
    it
  }
  // 章节标题居中并自动换页
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
      pagebreak(weak: true)
    }
    if array-at(heading-align, it.level) != auto {
      set align(array-at(heading-align, it.level))
      it
    } else {
      it
    }
  }

  // 正文样式
  show: show-cn-fakebold
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    first-line-indent: first-line-indent,
    spacing: spacing,
  )
  show raw: set text(font: mono-font)
  show raw.where(block: true): set par(leading: 0.55em)

  // 脚注样式
  show footnote.entry: set text(font: ("Times New Roman", "SimSun"), size: zh(5))

  // figure 编号
  show heading: i-figured.reset-counters
  show heading: i-figured.reset-counters.with(extra-kinds: ("algo",))
  show figure: i-figured.show-figure.with(extra-prefixes: (algo: "alg:"))

  // 公式编号
  show math.equation.where(block: true): show-equation
  set math.equation(supplement: "公式")

  // 表格
  show figure.where(kind: table): set figure.caption(position: top)
  set figure.caption(separator: separator)
  if caption-style == none {
    caption-style = (font: ("Times New Roman", "SimHei"))
  }
  show figure.caption: it => text(size: caption-size, ..caption-style, it)

  // 去除空行连接时中文中间的空格
  // https://www.w3.org/TR/clreq/#table_of_punctuation_marks
  let han-or-punct = "[-\p{sc=Hani}。．，、：；！‼？⁇⸺——……⋯⋯～–—·・‧/／「」『』“”‘’（）《》〈〉【】〖〗〔〕［］｛｝＿﹏●•]"
  show regex(han-or-punct + " " + han-or-punct): it => {
    let (a, _, b) = it.text.clusters()
    a + b
  }

  it
}
