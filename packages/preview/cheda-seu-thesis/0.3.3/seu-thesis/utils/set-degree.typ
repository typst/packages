#import "numbering-tools.typ": chinese-numbering
#import "packages.typ": show-cn-fakebold, i-figured
#import "show-heading.typ": show-heading
#import "bilingual-bibliography.typ": show-bibliography
#import "show-equation-degree.typ": show-math-equation-degree
#import "fonts.typ": 字体, 字号

#let set-degree(always-new-page: true, bilingual-bib: true, doc) = {
  set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm))
  set text(font: 字体.宋体, size: 字号.小四, weight: "regular", lang: "zh")
  set par(first-line-indent: (amount: 2em, all: true), leading: 9.6pt, justify: true, spacing: 9.6pt)
  
  show: show-cn-fakebold

  show: show-bibliography.with(bilingual: bilingual-bib)

  show heading: show-heading.with(
    always-new-page: always-new-page,
    heading-top-margin: (1cm, 0.1cm, 0.05cm),
    heading-bottom-margin: (1cm, 0cm, 0cm),
    heading-text: (
      (font: 字体.黑体, size: 字号.三号, weight: "regular"),
      (font: 字体.宋体, size: 字号.四号, weight: "bold"),
      (font: 字体.黑体, size: 字号.小四, weight: "regular"),
    ),
  )
  show heading.where(level: 1): set heading(supplement: none)
  // 标题写入 state 的保存逻辑在 show-heading.typ

  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set text(size: 字号.五号, font: 字体.宋体, weight: "regular")
  show figure: i-figured.show-figure.with(numbering: "1-1")
  show figure.where(kind: table): i-figured.show-figure.with(numbering: "1.1")
  show math.equation.where(block: true): i-figured.show-equation
  set math.equation(number-align: bottom)
  // 研究生院要求：公式首行的起始位置空四格。
  show math.equation.where(block: true): show-math-equation-degree

  set heading(numbering: chinese-numbering)

  doc
}