// 西安电子科技大学本科毕业设计（论文）Typst 模板 — 正文

#import "layout.typ": *
#import "../utils/style.typ": 字体

#let 图表编号(..n) = context {
  numbering("1", counter(heading).get().first()) + "." + numbering("1", ..n)
}
#let 公式编号(..n) = context {
  "(" + numbering("1", counter(heading).get().first()) + "-" + numbering("1", ..n) + ")"
}

#let 引用(..序号) = super(text(font: ("Times New Roman",), size: 0.9em,
  "[" + 序号.pos().map(str).join(",") + "]"))

#let 题注(前缀, 章, 序, 内容) = {
  set text(font: 字体.宋体, size: 10.5pt,
    top-edge: 基线偏移(10.5pt), bottom-edge: "baseline")
  [#前缀 #章.#序]
  if 内容 != none { h(0.75em); 内容 }
}

#let 图规则(it) = context {
  let 序 = counter(figure.where(kind: image)).at(it.location()).first()
  let 章 = counter(heading).at(it.location()).first()
  let 内容 = if it.caption != none { it.caption.body } else { none }
  block(width: 100%, align(center, it.body))
  v(6pt)
  block(width: 100%, align(center, 题注("图", 章, 序, 内容)))
  v(12pt)
}

#let 表规则(it) = context {
  let 序 = counter(figure.where(kind: table)).at(it.location()).first()
  let 章 = counter(heading).at(it.location()).first()
  let 内容 = if it.caption != none { it.caption.body } else { none }
  block(width: 100%, align(center, 题注("表", 章, 序, 内容)))
  v(6pt)
  block(width: 100%, align(center, it.body))
  v(12pt)
}

#let 章标题(it) = {
  pagebreak(to: "odd", weak: true)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  let 字号 = 16pt
  let 上伸 = 基线偏移(字号)
  v(42.8mm - 上边距 - 上伸)
  // Typst 的 block 段后与 LaTeX afterskip 语义不同；25.4pt 反向测量后使下一行基线对齐实物论文。
  block(width: 100%, below: 25.4pt, align(center, {
    set text(font: 字体.黑体, size: 字号, weight: "regular",
      top-edge: 上伸, bottom-edge: "baseline")
    context {
      let n = counter(heading).at(it.location()).first()
      [第#章序(n)章 #it.body]
    }
  }))
}

#let 节标题(it) = block(above: 18pt, below: 12pt, width: 100%, align(center, {
  set text(font: 字体.宋体, size: 14pt, weight: "regular", top-edge: 基线偏移(14pt), bottom-edge: "baseline")
  let nums = counter(heading).at(it.location())
  numbering("1.1", ..nums); h(0.75em); it.body
}))

#let 小节标题(it, 方式: "1.1.1") = block(above: 12pt, below: 6pt, {
  set text(font: 字体.宋体, size: 14pt, weight: "regular", top-edge: 基线偏移(14pt), bottom-edge: "baseline")
  let nums = counter(heading).at(it.location())
  numbering(方式, ..nums); h(0.75em); it.body
})

#let mainmatter(info: (:), fonts: (:), it) = {
  let 字体集 = 字体 + fonts
  pagebreak(to: "odd", weak: true)
  set page(..本科页面参数(纯题目(info), numbering: "1"))
  counter(page).update(1)
  counter(heading).update(0)

  set text(font: 字体集.宋体, size: 正文号, lang: "zh",
    top-edge: 正文上伸, bottom-edge: "baseline")
  set par(leading: 行隙, spacing: 行隙, justify: true,
    first-line-indent: (amount: 2em, all: true))

  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { "第" + 章序(n.first()) + "章" }
    else if n.len() == 2 { numbering("1.1", ..n) }
    else if n.len() == 3 { numbering("1.1.1", ..n) }
    else { numbering("（1）", n.last()) }
  })
  show heading.where(level: 4): set heading(outlined: false)
  show heading.where(level: 1): 章标题
  show heading.where(level: 2): 节标题
  show heading.where(level: 3): it => 小节标题(it)
  show heading.where(level: 4): it => 小节标题(it, 方式: "（1）")

  show cite: it => super(text(font: ("Times New Roman",), size: 0.9em, it))
  show figure.where(kind: image): 图规则
  show figure.where(kind: table): 表规则
  show table: set table(stroke: 0.5pt)
  set figure(numbering: 图表编号)
  set math.equation(numbering: 公式编号)

  it
}
