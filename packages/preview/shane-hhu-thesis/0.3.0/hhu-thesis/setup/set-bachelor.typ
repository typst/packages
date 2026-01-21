#import "../utils/utils.typ": ziti, zihao, chinese-numbering, show-cn-fakebold, i-figured, show-math-equation, show-figure
#import "../parts/heading-conf.typ": heading-conf

#let set-bachelor(always-new-page: true, doc) = {
  set page(paper: "a4", margin: (top: 2.7cm, bottom: 3cm, left: 3.2cm, right: 3.2cm))
  set text(font: ziti.宋体, size: zihao.小四, weight: "regular", lang: "zh")
  set par(first-line-indent: 2em, leading: 1.2em, justify: true)

  set enum(numbering: it  => {
    v(0.125em)
    numbering("1.", it)
  })

  show: show-cn-fakebold

  show heading: heading-conf.with(
    always-new-page: always-new-page,
    heading-top-margin: (0.8em, 0.1cm, 0.05cm),
    heading-bottom-margin: (0.5em, 0cm, 0cm),
    heading-text: (
      (font: ziti.黑体, size: zihao.小二, weight: "bold"),
      (font: ziti.黑体, size: zihao.四号, weight: "bold"),
      (font: ziti.黑体, size: zihao.小四, weight: "bold"),
    ),
  )
  show heading.where(level: 1): set heading(supplement: none)

  // 表头位置
  show figure.where(kind: table): set figure.caption(position: top)
  // 表头字体
  show figure.caption: it => [
    #text(font: ziti.黑体, size: zihao.五号, it)
  ]
  // 表格内容字体
  show figure: set text(size: zihao.五号, font: ziti.宋体, weight: "regular")
  // 图表caption数字展示方式
  show figure: i-figured.show-figure.with(numbering: "1-1")
  show figure.where(kind: table): i-figured.show-figure.with(numbering: "1.1")
  show math.equation.where(block: true): i-figured.show-equation
  set math.equation(number-align: bottom)
  // 公式算作单独段落
  show math.equation.where(block: true): show-math-equation
  show figure: show-figure
  // show enum.number: show-enum-num

  set heading(numbering: chinese-numbering)
  set bibliography(style: "gb-7714-2005-numeric")

  doc
}
