// 西安电子科技大学配套材料 — 共用版式
//
// 数值依据：docs/配套材料规格.md
// 这里只服务开题报告、中期考核和通用课程实验报告，不复用学位论文的版心。

#import "../utils/style.typ": 字体

#let 纸张宽 = 210mm
#let 纸张高 = 297mm

#let 正文号 = 12pt
#let 行盒 = 20pt
#let 基线偏移(字号: 正文号) = (行盒 - 字号) / 2 + 0.88 * 字号
#let 正文上伸 = 基线偏移()
#let 行隙 = 行盒 - 正文上伸

#let 单行高(字号: 正文号) = 基线偏移(字号: 字号)

#let 字体集(overrides) = 字体 + overrides

#let 取值(数据, 键, 默认: none) = {
  if type(数据) == dictionary {
    数据.at(键, default: 默认)
  } else {
    默认
  }
}

#let 有内容(值) = 值 != none and 值 != [] and 值 != ""

#let 内容(数据, 键, 默认: none) = {
  let 值 = 取值(数据, 键, 默认: 默认)
  if 有内容(值) { 值 } else { [] }
}

#let 日期文字(值) = {
  if type(值) == dictionary {
    let 年 = 值.at("year", default: none)
    let 月 = 值.at("month", default: none)
    if 年 != none and 月 != none {
      if type(月) == int { str(年) + " 年 " + str(月) + " 月" } else { 值.at("text", default: "") }
    } else {
      值.at("text", default: "")
    }
  } else if 值 == none {
    ""
  } else {
    str(值)
  }
}

#let 文档页(
  info: (:),
  fonts: (:),
  lang: "zh",
  fallback: false,
  margin-top: 2.54cm,
  margin-bottom: 2.54cm,
  margin-left: 2.54cm,
  margin-right: 2.54cm,
  it,
) = {
  let 字体表 = 字体集(fonts)
  set document(
    title: if type(info.at("title", default: "")) == array {
      info.title.join("")
    } else {
      info.at("title", default: "")
    },
    author: info.at("author", default: ""),
  )
  set page(
    paper: "a4",
    width: 纸张宽,
    height: 纸张高,
    margin: (
      top: margin-top,
      bottom: margin-bottom,
      left: margin-left,
      right: margin-right,
    ),
    header: none,
    footer: none,
    numbering: none,
  )
  set text(
    font: 字体表.宋体,
    size: 正文号,
    lang: lang,
    fallback: fallback,
    top-edge: 正文上伸,
    bottom-edge: "baseline",
  )
  set par(
    leading: 行隙,
    spacing: 行隙,
    justify: true,
    first-line-indent: (amount: 2em, all: true),
  )
  it
}

#let 正文样式(
  body,
  fonts: (:),
  lang: "zh",
  indent: true,
  justify: true,
) = {
  let 字体表 = 字体集(fonts)
  set text(
    font: 字体表.宋体,
    size: 正文号,
    lang: lang,
    top-edge: 正文上伸,
    bottom-edge: "baseline",
  )
  set par(
    leading: 行隙,
    spacing: 行隙,
    justify: justify,
    first-line-indent: if indent { (amount: 2em, all: true) } else { 0pt },
  )
  show heading.where(level: 1): it => block(
    above: 0pt,
    below: 0pt,
    text(font: 字体表.黑体, size: 正文号, weight: "bold", it.body),
  )
  show heading.where(level: 2): it => block(
    above: 6pt,
    below: 0pt,
    text(font: 字体表.黑体, size: 正文号, weight: "bold", it.body),
  )
  body
}

#let 留白(行数: 4) = v(行数 * 行盒, weak: true)

#let 标题(
  body,
  fonts: (:),
  size: 18pt,
  font: none,
  weight: "bold",
  align-body: center,
) = align(
  align-body,
  text(
    font: if font == none { 字体集(fonts).黑体 } else { font },
    size: size,
    weight: weight,
    top-edge: 单行高(字号: size),
    bottom-edge: "baseline",
    body,
  ),
)

#let 小标题(文字, fonts: (:)) = block(
  above: 0pt,
  below: 0pt,
  text(font: 字体集(fonts).黑体, size: 正文号, weight: "bold", 文字),
)

#let 提示(文字, fonts: (:)) = block(
  above: 0pt,
  below: 0pt,
  text(font: 字体集(fonts).宋体, size: 10.5pt, fill: luma(90), 文字),
)

#let 下划线() = place(bottom + left, line(length: 100%, stroke: 0.5pt))

#let 填写行(
  label,
  value,
  label-width: 34mm,
  value-size: 14pt,
  fonts: (:),
  bold-label: true,
) = {
  let 字体表 = 字体集(fonts)
  grid(
    columns: (label-width, 1fr),
    column-gutter: 5mm,
    align: (left + bottom, left + bottom),
    text(
      font: 字体表.宋体,
      size: value-size,
      weight: if bold-label { "bold" } else { "regular" },
      label,
    ),
    box(
      width: 100%,
      {
        下划线()
        align(center, text(font: 字体表.宋体, size: value-size, value))
      },
    ),
  )
}

#let 顶部学号(info, fonts: (:)) = align(
  right,
  text(
    font: 字体集(fonts).宋体,
    size: 10.5pt,
    weight: "bold",
    [学号　#box(width: 38mm, {
      下划线()
      align(center, text(size: 12pt, weight: "regular", info.at("student-id", default: "")))
    })],
  ),
)

#let 表单块(
  title: none,
  body,
  fonts: (:),
  first: false,
  blank-lines: 0,
  inset: 5pt,
) = {
  let 字体表 = 字体集(fonts)
  block(
    width: 100%,
    breakable: true,
    above: 0pt,
    below: 0pt,
    inset: inset,
    stroke: if first {
      (top: 0.5pt, bottom: 0.5pt, left: 0.5pt, right: 0.5pt)
    } else {
      (bottom: 0.5pt, left: 0.5pt, right: 0.5pt)
    },
  )[
    #if title != none [
      #小标题(title, fonts: fonts)
      #v(4pt, weak: true)
    ]
    #if blank-lines > 0 [ #留白(blank-lines) ]
    #body
  ]
}

#let 小节(label, value, fonts: (:), hint: none, blank-lines: 0) = {
  v(4pt, weak: true)
  小标题(label, fonts: fonts)
  if hint != none {
    v(1pt, weak: true)
    提示(hint, fonts: fonts)
  }
  v(2pt, weak: true)
  if 有内容(value) {
    正文样式(value, fonts: fonts)
  } else if blank-lines > 0 {
    留白(blank-lines)
  }
}

#let 签名区(
  labels: ("指导教师签名：",),
  date-label: "年　　月　　日",
  fonts: (:),
  gap: 8pt,
) = {
  for label in labels {
    v(gap, weak: true)
    align(right, text(font: 字体集(fonts).宋体, size: 正文号, label))
    v(2pt, weak: true)
    align(right, text(font: 字体集(fonts).宋体, size: 正文号, date-label))
  }
}

#let 选项行(selected, options: ("优秀", "良好", "合格", "不合格"), fonts: (:)) = {
  let 字体表 = 字体集(fonts)
  let 标记(option) = box(
    width: 8pt,
    height: 8pt,
    inset: 0pt,
    stroke: 0.5pt,
    fill: if selected == option { black } else { none },
  )
  grid(
    columns: (1fr, 1fr),
    row-gutter: 2pt,
    align: left,
    ..options.map(option => [
      #标记(option)
      #h(3pt)
      #text(font: 字体表.宋体, size: 正文号, option)
    ]),
  )
}
