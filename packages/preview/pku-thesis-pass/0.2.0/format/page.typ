// ============================================================
// page.typ — 页面基础设置
// 封装 set page / set text / set figure / 脚注 / show rule 等
// 全局排版基础设施，供 config.typ 编排时调用
// ============================================================

#import "@preview/itemize:0.2.0" as itemize
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.10": codly-languages

#import "const.typ": font, size
#import "utils.typ": appendixcounter, chaptercounter, chinesenumbering, sym-circle, sym-square, sym-rhombus
#import "headings.typ": heading-show-rule
#import "header.typ": make-header
#import "footer.typ": make-footer
#import "show.typ": _figure-show-rule, _ref-show-rule

/// 页面基础设置函数
/// 在 #show: setup 处被 config() 调用，作用于全文
/// 参数全部由 config() 传入，保持关注点分离
#let page-setup(
  font: font,
  header-text: none,
  preview: true,
  first-line-indent: 2em,
  smartpagebreak: none,
  merged-supplements: (:),
  codly-args: (:),
  body: none,
) = {
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 2.5cm, left: 2.6cm, right: 2.6cm),
    header: make-header(header-text: header-text),
    footer: make-footer(),
  )
  set text(font: font.宋体, size: size.正文, lang: "zh")
  set heading(numbering: chinesenumbering)

  set figure(
    numbering: (..nums) => context {
      if appendixcounter.at(here()).first() < 10 {
        numbering("1.1", chaptercounter.at(here()).first(), ..nums)
      } else {
        numbering("A.1", chaptercounter.at(here()).first(), ..nums)
      }
    },
  )

  set math.equation(
    numbering: (..nums) => context {
      set text(font: font.宋体)
      if appendixcounter.at(here()).first() < 10 {
        numbering("(1.1)", chaptercounter.at(here()).first(), ..nums)
      } else {
        numbering("(A.1)", chaptercounter.at(here()).first(), ..nums)
      }
    },
  )

  set footnote(numbering: "①")
  show footnote: set super(size: 0.65em)
  show footnote.entry: it => {
    let loc = it.note.location()
    set text(font: font.宋体, size: size.脚注)
    set par(
      justify: true,
      leading: 1.2em,  // 模拟单倍行距
      spacing: 0pt,
      hanging-indent: 1.5em,
      first-line-indent: 0pt,
    )
    numbering(it.note.numbering, ..counter(footnote).at(loc))
    h(0.5em)
    it.note.body
  }

  show strong: it => text(font: font.黑体, weight: "bold", it.body)
  show emph: it => text(font: font.楷体, style: "italic", it.body)
  show raw: set text(font: font.代码, size: size.五号, top-edge: "ascender")
  show: codly-init.with()
  codly(languages: codly-languages, ..codly-args)

  show link: it => if type(it.dest) == str and preview {
    text(fill: blue)[#it]
  } else { it }

  show: itemize.default-enum-list.with(
    indent: (first-line-indent, 0.5em),
    label-baseline: "center",
    list-config: (
      label-format: it => [#(
        sym-circle(6pt), sym-square(6pt), sym-rhombus(6pt),
      ).at(calc.rem(it.level - 1, 3))],
    ),
  )

  show heading: it => heading-show-rule(it, smartpagebreak)
  show figure: set block(breakable: true)
  show figure: it => _figure-show-rule(it, merged-supplements)
  show ref: it => _ref-show-rule(it, merged-supplements)

  body
}
