#import "style.typ": 字体, 字号

#let table-stroke = 0.5pt

#set page(numbering: "1")
#set par(leading: 1em)

// 封面
#{
  set align(center)

  v(5em)

  image("master-proposal-logo.png", width: 7cm)

  v(2em)

  par(text(
    font: 字体.黑体,
    size: 字号.一号,
    weight: "bold",
    "某某学院\n硕士研究生论文开题报告",
  ))

  v(8em)

  let info-inset = 0pt

  let info-key(body) = {
    rect(width: 100%, inset: info-inset, stroke: none, text(
      font: 字体.黑体,
      size: 字号.三号,
      weight: "bold",
      body,
    ))
  }

  let info-value(body) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: table-stroke + black),
      text(
        font: 字体.黑体,
        size: 字号.三号,
        bottom-edge: "descender",
        body,
      ),
    )
  }

  grid(
    columns: (100pt, 150pt),
    column-gutter: -5pt,
    row-gutter: 15pt,
    info-key[论 文 题 目], info-value[题目],
    info-key[作 者 姓 名], info-value[张三],
    info-key[作 者 学 号], info-value[1234567890],
    info-key[专 业 名 称], info-value[某专业],
    info-key[研 究 方 向], info-value[某方向],
    info-key[指 导 教 师], info-value[李四],
  )

  v(10em)

  text(
    font: 字体.黑体,
    size: 字号.三号,
    weight: "bold",
    "二0　　年　　月　　日",
  )
}

#pagebreak(weak: true)

// 主体
#align(center, text(
  font: 字体.黑体,
  size: 字号.三号,
  weight: "bold",
  "开题报告",
))

#set text(font: 字体.宋体, size: 字号.五号)
#set underline(offset: 0.1em)

#table(
  columns: (2em, 1fr),
  align: (center + horizon, auto),
  stroke: table-stroke,
  inset: 10pt,
)[
  题 \ \ 目
][
  #v(5em)
][
  题 \ \ 目 \ \ 来 \ \ 源 \ \ 及 \ \ 类 \ \ 型
][
  #v(25em)
][
  研 \ \ 究 \ \ 背 \ \ 景 \ \ 及 \ \ 意 \ \ 义
][
  #v(1fr)
][
  国 \ \ 内 \ \ 外 \ \ 现 \ \ 状 \ \ 及 \ \ 分 \ \ 析
][
  #v(1fr)
][
  研 \ \ 究 \ \ 目 \ \ 标 \ \ 、 \ \ 研 \ \ 究 \ \ 内 \ \ 容 \ \ 和 \ \ 拟 \ \ 解 \ \ 决 \ \ 的 \ \ 关 \ \ 键 \ \ 问 \ \ 题
][
  #v(1fr)
][
  研 \ \ 究 \ \ 方 \ \ 法 \ \ 、 \ \ 设 \ \ 计 \ \ 及 \ \ 试 \ \ 验 \ \ 方 \ \ 案 \ \ 、 \ \ 可 \ \ 行 \ \ 性 \ \ 分 \ \ 析
][
  #v(1fr)
][
  计 \ \ 划 \ \ 进 \ \ 度 \ \ 和 \ \ 质 \ \ 量 \ \ 保 \ \ 证
][
  #v(1fr)
][
  预 \ \ 期 \ \ 成 \ \ 果 \ \ 与 \ \ 创 \ \ 新 \ \ 点
][
  #v(1fr)
][
  参 \ \ 考 \ \ 文 \ \ 献 \ \ ︵ \ \ 不 \ \ 少 \ \ 于 \ \ 20 \ \  篇 \ \ ︶
][
  #v(1fr)
][
  导 \ \ 师 \ \ 意 \ \ 见
][
  #v(28em)
][
  考 \ \ 核 \ \ 小 \ \ 组 \ \ 意 \ \ 见 \ \ 及 \ \ 结 \ \ 论
][
  #v(20em)

  是否进入论文写作：#h(1em) 是 #sym.ballot #h(2em) 否 #sym.ballot

  // 是否进入论文写作：#h(1em) 是 #sym.ballot.x #h(2em) 否 #sym.ballot

  #v(5em)

  签字：#underline("　" * 10) #h(1em) #underline("　" * 10) #h(1em) #underline("　" * 10) #h(1em)

  #v(3em)

  日期：#h(4em) 年 #h(2em) 月 #h(2em) 日
]

*注：需向导师提供电子版开题报告，可打印粘贴。*
