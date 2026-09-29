// 正文布局：标题、页眉、行距
#import "@preview/i-figured:0.2.4"
#import "../utils/style.typ": 字号, 字体, 正文字体, 正文字号, 正文行距, 正文段间距, 首行缩进, 辅助字体, 辅助字号, 章标题字体, 章标题字号, 节一级标题字号, 节二级标题字号, 节三级标题字号, 节标题字体
#import "../utils/custom-numbering.typ": custom-numbering
#import "../utils/section-break.typ": section-break
#import "../utils/custom-heading.typ": heading-display, active-heading, current-heading
#import "../utils/unpairs.typ": unpairs
#import "../utils/theorem.typ": theorem, lemma, corollary, definition, proposition, example, remark, proof, theorem-counter, lemma-counter, corollary-counter, definition-counter, proposition-counter, example-counter
#import "@preview/great-theorems:0.1.2": great-theorems-init
#import "@preview/headcount:0.1.1": reset-counter
#import "../utils/algorithm.typ": style-algorithm
#import "@preview/zebraw:0.6.3": zebraw
#import "@preview/cuti:0.4.0": show-cn-fakebold

#let mainmatter(
  doctype: "master",
  twoside: false,
  open-right: false,
  fonts: (:),
  info: (:),
  leading: 正文行距,
  spacing: 正文段间距,
  justify: true,
  first-line-indent: 首行缩进,
  numbering: custom-numbering.with(first-level: "第一章 ", depth: 4, "1.1 "),
  text-args: (font: 正文字体, size: 正文字号),
  // SCUT：章居中黑体，节居左黑体；段前段后各 0.5 行，随字号自动缩放
  heading-font: (章标题字体, 节标题字体, 节标题字体, 节标题字体),
  heading-size: (章标题字号, 节一级标题字号, 节二级标题字号, 节三级标题字号),
  heading-weight: ("regular",),
  heading-above: (2em,) * 4,
  heading-below: (2em,) * 4,
  heading-pagebreak: (true, false),
  heading-align: (center, left, left, left),
  // 页眉：偶数页学校名，奇数页章标题，1.5pt 下划线，不跳章首页
  header-render: auto,
  header-vspace: 0em,
  display-header: true,
  skip-on-first-level: false,
  stroke-width: 1.5pt,
  reset-footnote: true,
  separator: "  ",
  caption-style: it => it,
  caption-size: 字号.五号,
  show-figure: i-figured.show-figure.with(numbering: "1-1"),
  show-equation: i-figured.show-equation.with(numbering: "(1-1)"),
  ..args,
  it,
) = {
  section-break(open-right: open-right)
  set page(numbering: "1")

  // 结构标签：供 scripts/build.* 定位查重版（for-check）抽页范围
  [#metadata(none) <mainmatter-start>]

  fonts = 字体 + fonts

  // 收集用户传入的 heading-* 扩展参数
  let heading-text-args-lists = args.named().pairs()
    .filter((pair) => pair.at(0).starts-with("heading-"))
    .map((pair) => (pair.at(0).slice("heading-".len()), pair.at(1)))

  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  // 正文样式
  set text(..text-args)
  set par(
    leading: leading,
    justify: justify,
    first-line-indent: first-line-indent,
    spacing: spacing,
  )
  show raw: set text(font: fonts.等宽)
  show: show-cn-fakebold
  show: zebraw

  // 脚注、图表编号、公式编号
  show footnote.entry: set text(font: 辅助字体, size: 辅助字号)
  show heading: i-figured.reset-counters
  show figure: show-figure
  show math.equation.where(block: true): show-equation

  // 表格：手动三线表，caption 置顶，空格代替冒号
  show figure.where(kind: table): set figure.caption(position: top)
  set figure.caption(separator: separator)
  show figure.caption: caption-style
  show figure.caption: set text(font: 辅助字体, size: 辅助字号)

  // 算法伪代码
  show: style-algorithm

  // 定理环境
  show: great-theorems-init

  show terms: set par(first-line-indent: 0pt)

  // 中文排版惯例：列表符号与段落首行缩进对齐
  let list-indent = if type(first-line-indent) == dictionary {
    first-line-indent.amount
  } else {
    first-line-indent
  }
  set list(indent: list-indent)
  set enum(indent: list-indent)

  // 标题编号
  set heading(numbering: numbering)

  // 隐藏带 no-numbering 标签的标题编号（如结论章不加章号）
  // 用选择器 show-set 而非重建 heading，避免目录与 PDF 书签出现重复条目
  show heading.where(label: <no-numbering>): set heading(numbering: none)

  // 标题字体、字号、段间距
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

  // 标题换页与对齐
  show heading: it => {
    if array-at(heading-pagebreak, it.level) {
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

  // 定理计数器随章重置（放在最后一条 heading show rule）
  show heading: reset-counter(theorem-counter, levels: 1)
  show heading: reset-counter(lemma-counter, levels: 1)
  show heading: reset-counter(corollary-counter, levels: 1)
  show heading: reset-counter(definition-counter, levels: 1)
  show heading: reset-counter(proposition-counter, levels: 1)
  show heading: reset-counter(example-counter, levels: 1)

  // 页眉页脚
  let degree-name = if doctype == "doctor" { "博士学位论文" } else { "硕士学位论文" }
  let school-header = info.school-name + degree-name

  set page(
    footer: context {
      set text(font: 辅助字体, size: 辅助字号)
      align(center, stack(
        counter(page).display("1"),
        v(15mm),
      ))
    },
    ..(if display-header {
      (
        header: context {
          if reset-footnote {
            counter(footnote).update(0)
          }
          let loc = here()
          let cur-heading = current-heading(level: 1)
          if not skip-on-first-level or cur-heading == none {
            if header-render == auto {
              set text(font: 辅助字体, size: 辅助字号)
              let header-text = if twoside and calc.rem(loc.page(), 2) == 0 {
                school-header
              } else {
                heading-display(active-heading(level: 1, prev: false))
              }
              align(center, stack(
                v(15mm),
                header-text,
                v(0.25em),
                line(length: 100%, stroke: stroke-width + black),
              ))
            } else {
              header-render(loc)
            }
            v(header-vspace)
          }
        }
      )
    } else {
      (
        header: {
          if reset-footnote {
            counter(footnote).update(0)
          }
        }
      )
    }),
  )

  counter(page).update(1)

  it
}
