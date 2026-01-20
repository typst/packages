#import "@preview/i-figured:0.2.4"
#import "@preview/equate:0.3.2": *
#import "@preview/theorion:0.4.1": *
#import "../utils/theoriom.typ": *
#import "@preview/lovelace:0.3.0": *
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.10": *
#import "../utils/style.typ": zihao, ziti
#import "../utils/figurex.typ": preset
#import "../utils/header.typ": tust-page-header

#let heading-font = ziti.heiti

#let mainmatter(
  doctype: "bachelor",
  twoside: false,
  enable-avoid-orphan-headings: false,
  auto-section-pagebreak-space: 15%,
  use-standard-code-format: true,
  info: (:),
  body,
) = {
  set page(
    numbering: "1",
    margin: (top: 25mm, bottom: 20mm, left: 25mm, right: 20mm),
  )
  counter(page).update(1)

  set heading(numbering: "1.1", supplement: none)

  show heading.where(level: 1): it => {
    set text(font: heading-font, weight: "bold", size: zihao.xiaosan)
    set par(first-line-indent: 0em, leading: 20pt)
    set align(center)
    pagebreak()
    v(40pt)
    if it.numbering == none {
      it.body
    } else {
      "第" + counter(heading).display() + "章" + h(1em) + it.body
    }
    v(20pt)
  }

  show heading.where(level: 2): it => {
    set text(font: heading-font, weight: "bold", size: zihao.sihao)
    set par(first-line-indent: 0em, leading: 20pt)
    v(24pt)
    counter(heading).display() + h(1em) + it.body
    v(6pt)
  }

  show heading.where(level: 3): it => {
    set text(font: heading-font, weight: "bold", size: zihao.xiaosi)
    set par(first-line-indent: 0em, leading: 20pt)
    v(12pt)
    counter(heading).display() + h(1em) + it.body
    v(6pt)
  }

  show heading.where(level: 4): it => {
    set text(font: heading-font, weight: "bold", size: zihao.sihao)
    set par(first-line-indent: 0em, leading: 16pt)
    v(1pt)
    counter(heading).display() + h(1em) + it.body
    v(2pt)
  }

  // 列表格式设置
  set list(indent: 2em, body-indent: 0.5em)
  set enum(indent: 2em, body-indent: 0.5em)

  show: preset

  show heading: i-figured.reset-counters.with(extra-kinds: (
    "image",
    "image-en",
    "table",
    "table-en",
    "algorithm",
    "algorithm-en",
    "code",
  ))
  show figure: i-figured.show-figure.with(
    extra-prefixes: (image: "img:", algorithm: "algo:", table: "tbl:", code: "code:"),
    numbering: if doctype == "bachelor" { "1-1" } else { "1.1" },
  )

  set math.equation(numbering: (..nums) => numbering(
    if doctype == "bachelor" { "(1-1)" } else { "(1.1)" },
    counter(heading).get().first(),
    ..nums,
  ), supplement: [式])
  show: equate.with(breakable: true, sub-numbering: false)
  set math.equation(number-align: end + bottom)
  show math.equation: set block(above: 6pt, below: 6pt)

  show cite: set text(font: "Times New Roman")
  
  // 应用定理环境的show规则
  show: show-theorion
  
  // 代码块格式设置
  show: codly-init.with()
  if use-standard-code-format {
    // 使用规范格式（无语言标签、无背景）
    codly(
      languages: codly-languages,
      zebra-fill: none,
      stroke: none,
      radius: 0pt,
      inset: 0pt,
      display-name: false,
      display-icon: false,
    )
    show raw.where(block: true): it => {
      set text(font: ziti.songti, size: zihao.wuhao)
      set par(leading: 4pt, spacing: 0pt, first-line-indent: 0pt)
      block(above: 12pt, below: 12pt, inset: (left: 2em), it)
    }
    show raw.where(block: false): set text(font: ziti.songti)
  } else {
    // 使用codly默认样式
    codly(languages: codly-languages)
  }

  tust-page-header(
    heading: info.at("heading", default: "天津科技大学本科毕业设计"),
  )[#body]
}
