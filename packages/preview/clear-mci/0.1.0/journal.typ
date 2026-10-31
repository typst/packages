// clear-mci — 面向《现代化工》的社区 Typst 模板（非期刊官方认证）
//
// 本文件是唯一的样式源码：所有排版规则、可复用组件与主入口都在这里。
// 正文请写在 main.typ（初始化后）或 paper.typ（本仓库开发验证用）中，
// 通过 `#show: mci.with(...)` 应用本模板，并按需调用下方组件。
//
// 默认配置刻意与既有排版一致：正文 12pt、行距/段距 15.2pt、首行缩进 2em、
// 一级标题默认另起一页、图表与公式自动编号、参考文献使用项目内置 CSL。

// ============================================================
// 配置
// ============================================================

#let _default-config = (
  // 中文正文字体（英文用 en-font 回退在前）
  body-font: "SimSun",
  // 中文题名字体
  cn-title-font: "SimHei",
  // 英文字体（同时作为中英混排时的拉丁字体）
  en-font: "Times New Roman",
  // 数学字体
  math-font: "Cambria Math",
  // 一级标题是否另起一页（用户偏好，默认开启）
  heading-1-pagebreak: true,
)

// 当前生效配置。主函数 mci 会在文档开头写入；组件用 context 读取。
// 未应用 mci 时，组件回退到上面的默认值。
#let _config = state("mci-config", _default-config)

// ============================================================
// 题名、摘要、关键词、表注等可独立调用的组件
// 均通过 context 读取当前配置，用户无需在每次调用时重复传字体。
// ============================================================

// 中文题名
#let title-cn(body) = context {
  let c = _config.get()
  block(width: 100%, inset: (top: 9.7pt))[
    #align(center)[
      #set text(font: (c.en-font, c.cn-title-font), size: 18pt, weight: "bold")
      #set par(leading: 18.8pt)
      // 中文标题加描边，模拟 Word 的加粗观感
      #show regex("\\p{Han}+"): set text(stroke: 0.51pt)
      #body
    ]
  ]
}

// 中文摘要
#let abstract-cn(body) = context {
  let c = _config.get()
  block(above: 16pt, below: 0pt)[
    #set par(justify: true, leading: 15.2pt)
    // 单段块内 first-line-indent 不生效，改用 h(2em) 实现首行缩进
    #h(2em)
    #text(font: c.body-font, stroke: 0.34pt)[摘 要:]
    #body
  ]
}

// 中文关键词
#let keyword-cn(body) = context {
  let c = _config.get()
  block(above: 15pt, below: 0pt)[
    #set par(justify: true, leading: 15.2pt)
    #h(2em)
    #text(font: c.body-font, stroke: 0.34pt)[关键词:]
    #body
  ]
}

// 英文题名
#let title-en(body) = context {
  let c = _config.get()
  block(width: 100%, inset: (top: 5pt), below: 22pt)[
    #align(center)[
      #set text(font: c.en-font, size: 18pt, weight: "bold")
      #set par(justify: false, first-line-indent: 0pt, leading: 19.2pt)
      #body
    ]
  ]
}

// 英文摘要
#let abstract-en(body) = context {
  let c = _config.get()
  block(above: 0pt, below: 0pt)[
    #set text(font: c.en-font, size: 12pt, weight: "regular")
    #set par(
      justify: true,
      leading: 15.45pt,
      first-line-indent: (amount: 0em, all: true),
    )
    #text(weight: "bold")[Abstract:]#body
  ]
}

// 英文关键词
#let keyword-en(body) = context {
  let c = _config.get()
  block(above: 18pt, below: 0pt)[
    #set text(font: c.en-font, size: 12pt, weight: "regular")
    #set par(justify: true, leading: 15.45pt, first-line-indent: 0em)
    #text(weight: "bold")[Key words:]#body
  ]
}

// 图注 / 表题 / 表注共用的题注样式
#let _caption-style(body) = context {
  let c = _config.get()
  set text(font: (c.en-font, c.body-font), size: 10pt)
  set par(first-line-indent: 0pt, justify: false, leading: 9pt, spacing: 0pt)
  align(center, body)
}

// 表注（不参与编号，置于表下）
#let table-note(body) = block(
  width: 100%,
  above: 6pt,
  below: 10pt,
  _caption-style(body),
)

// ============================================================
// 主入口
// ============================================================
//
// 用法：
//   #import "@preview/clear-mci:0.1.0": *
//   #show: mci.with(body-font: "SimSun", heading-1-pagebreak: false)
//
// 所有参数可选，默认值即既有排版。

#let mci(
  body,
  body-font: "SimSun",
  cn-title-font: "SimHei",
  en-font: "Times New Roman",
  math-font: "Cambria Math",
  heading-1-pagebreak: true,
) = {
  // 1) 写入当前配置，供可独立调用的组件读取
  context _config.update(_ => (
    body-font: body-font,
    cn-title-font: cn-title-font,
    en-font: en-font,
    math-font: math-font,
    heading-1-pagebreak: heading-1-pagebreak,
  ))

  // 2) 页面
  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 3.18cm, right: 3.18cm),
  )

  // 3) 下标：使用相对单位，使标题与正文中的下标都自然下沉
  set sub(
    typographic: false,
    size: 0.65em,
    baseline: 0.07em,
  )

  // 4) 全局正文：中文正文 + 英文字体、字号、行距、首行缩进
  set text(font: (en-font, body-font), size: 12pt, weight: "regular")
  set par(
    justify: true,
    leading: 15.2pt,
    spacing: 15.2pt,
    first-line-indent: (amount: 2em, all: true),
  )

  // 5) 标题编号与格式（固定 1.1.1 共三级；引言的不编号由正文声明）
  set heading(numbering: "1.1.1")
  show heading: it => {
    let level = it.level
    let above = (16pt, 28pt, 16pt).at(level - 1)
    let below = (28pt, 30pt, 16pt).at(level - 1)

    // 一级标题另起一页（用户偏好，可关闭）
    if level == 1 and heading-1-pagebreak {
      pagebreak(weak: true)
    }

    block(
      width: 100%,
      above: above,
      below: below,
      sticky: true,
    )[
      #set text(font: (en-font, body-font), size: 12pt, weight: "bold")
      #set par(first-line-indent: 0pt, justify: false)
      #show regex("\\p{Han}+"): set text(stroke: 0.34pt)

      // 仅当该标题自身声明了 numbering 时才显示编号；
      // 不匹配任何具体章节名称。
      #let label = [
        #if it.numbering != none {
          context counter(heading).display(it.numbering)
          h(0.25em)
        }#it.body
      ]

      #if level == 1 {
        align(center, label)
      } else {
        h(2em)
        label
      }
    ]
  }

  // 6) 图、表
  set figure(numbering: "1", supplement: [图], gap: 6pt)
  set figure.caption(position: bottom, separator: h(1em))
  show figure.where(kind: table): set figure(supplement: [表])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set par(first-line-indent: 0pt, justify: false)
  show figure.caption: _caption-style

  // 表格默认不画网格线，三线表的横线由表内 table.hline 指定
  set table(stroke: none, inset: (x: 4pt, y: 6pt), align: center)
  show table: set par(first-line-indent: 0pt, justify: false, leading: 7.65pt)

  // 7) 公式：自动编号，编号右对齐
  set math.equation(
    numbering: "(1)",
    number-align: right + horizon,
    supplement: [式],
  )
  show math.equation.where(block: true): set text(font: math-font, size: 12pt)

  // 8) 参考文献模块格式（CSL 由正文通过 bibliography(style:) 指定）
  show bibliography: it => {
    set text(font: (en-font, body-font), size: 12pt, hyphenate: false)
    set par(
      justify: true,
      first-line-indent: 0pt,
      leading: 7.65pt,
      spacing: 7.65pt,
    )

    // 只作用于参考文献模块内部的标题
    show heading.where(level: 1): h => {
      align(center, text(font: body-font, size: 12pt, stroke: 0.34pt, h.body))
      v(0.5em)
    }

    // BibTeX 中的原生下标/上标写法（如 #sub[2]）在渲染时转为真正的上下标
    show regex("#sub\\[[^\\]]+\\]"): item => {
      sub(
        typographic: false,
        size: 0.65em,
        baseline: 0.07em,
        item.text.slice(5, -1),
      )
    }
    show regex("#super\\[[^\\]]+\\]"): item => {
      super(
        typographic: false,
        baseline: 0.35em,
        size: 0.65em,
        item.text.slice(7, -1),
      )
    }

    it
  }

  body
}
