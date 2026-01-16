
// ================================
// 字体配置
// ================================

#let font = (
  // 中文字体
  zh_shusong: "SimSun",
  zh_zhongsong: "STZhongsong",
  zh_kai: "KaiTi",
  zh_hei: "SimHei",
  zh_fangsong: "STFangsong",
  // 英文字体
  en_sans_serif: "New Computer Modern",
  en_serif: "New Computer Modern",
  en_typewriter: "Courier New",
  en_code: "Consolas",
)

// ================================
// 字号配置
// ================================

#let font-size = (
  s2: 18pt, // 二号
  n3: 16pt, // 三号
  s3: 15pt, // 小三
  n4: 14pt, // 四号
  s4: 12pt, // 小四
  n5: 10.5pt, // 五号
  s5: 9pt, // 小五
)

// ================================
// 样式配置
// ================================

#let config = (
  // 字号设置
  text-size: font-size.n5,
  author-size: font-size.n5,
  title-size: font-size.s2,
  title1-size: font-size.s3,
  title2-size: font-size.n4,
  title3-size: font-size.s4,
  // 字体设置
  title-font: (font.en_serif, font.zh_hei),
  author-font: (font.en_sans_serif, font.zh_shusong),
  body-font: (font.en_serif, font.zh_shusong),
  heading-font: (font.en_serif, font.zh_zhongsong),
  caption-font: (font.en_serif, font.zh_kai),
  header-font: (font.en_serif, font.zh_kai),
  strong-font: (font.en_serif, font.zh_hei),
  emph-font: (font.en_serif, font.zh_kai),
  raw-font: (font.en_code, font.zh_hei),
  // 间距设置
  spacing: 1.02em,
  leading: 1.02em,
  indent: 2em,
  small-space: 1em,
  block-space: 0.75em,
  // 颜色设置
  raw-color: rgb("#f0f0f0"),
  problem-color: rgb(241, 241, 255),
  summary-color: rgb(240, 248, 255),
  // 列表样式
  list-marker: ([•], [◦], [▶]),
  enum-numbering: ("1.", "(1)", "①", "a."),
  // 表格样式
  table-stroke: 0.08em,
  table-header-stroke: 0.05em,
)

// ================================
// 全局状态
// ================================

// 全局title状态
#let title-state = state("document-title", "")

// ================================
// 工具函数
// ================================

// 偏微分符号
#let pardiff(x, y) = $frac(partial #x, partial #y)$

// ================================
// 学术组件
// ================================

// 通用框组件
#let custom-block(
  title: none,
  color: rgb(245, 245, 245),
  it,
) = {
  set text(font: config.emph-font)
  set par(first-line-indent: (amount: config.indent, all: false))
  let body = if title != none {
    strong(title) + h(config.block-space) + it
  } else {
    it
  }

  block(
    fill: color,
    inset: 8pt,
    radius: 2pt,
    width: 100%,
    body,
  )
}

// 题目框
#let problem-counter = counter("problem")
#let problem = custom-block.with(
  title: [
    #problem-counter.step()
    题目 #context problem-counter.display().
  ],
  color: config.problem-color,
)

// 解答框
#let solution(it) = {
  set enum(numbering: "(1)")
  set par(first-line-indent: (amount: config.indent, all: false))
  let body = [*解答.*] + h(config.block-space) + it
  block(
    inset: 8pt,
    below: config.leading,
    width: 100%,
    body,
  )
}

// 总结框
#let summary = custom-block.with(
  title: [总结.],
  color: config.summary-color,
)

// 三线表格
#let three-line-table(it) = {
  if it.children.any(c => c.func() == table.hline) {
    return it
  }

  let meta = it.fields()
  meta.stroke = none
  meta.remove("children")

  let header = it.children.find(c => c.func() == table.header)
  let cells = it.children.filter(c => c.func() == table.cell)

  if header == none {
    let columns = meta.columns.len()
    header = table.header(..cells.slice(0, columns))
    cells = cells.slice(columns)
  }

  return table(
    ..meta,
    table.hline(stroke: config.table-stroke),
    header,
    table.hline(stroke: config.table-header-stroke),
    ..cells,
    table.hline(stroke: config.table-stroke),
  )
}

#let header-style(heading) = {
  set text(font: config.header-font)
  let title = title-state.get()
  block(
    width: 100%,
    stroke: (bottom: 1pt + gray),
    inset: (bottom: 4pt),
    grid(
      columns: (1fr, 1fr),
      align(left, title), align(right, heading),
    ),
  )
}

#let prev-header = context {
  let headings = query(heading.where(level: 1).before(here()))
  if headings.len() == 0 {
    return
  }
  let level = counter(heading.where(level: 1)).display("一")
  let heading = level + h(config.small-space) + headings.last().body
  header-style(heading)
}

#let next-header = context {
  let headings = query(heading.where(level: 1).after(here()))
  if headings.len() == 0 {
    return
  }
  let count = counter(heading.where(level: 1)).get().first() + 1
  let level = numbering("一", count)
  let heading = level + h(config.small-space) + headings.first().body
  header-style(heading)
}

// 标题
#let make-title(
  title: "",
  author: "",
  date: none,
  abstract: none,
  keywords: (),
) = {
  set par(spacing: 1.2em, leading: 1.2em)
  // 主标题
  align(center)[
    #block(
      text(
        font: config.title-font,
        weight: "bold",
        config.title-size,
        title,
      ),
    )
    #v(0.5em)
  ]

  // 作者
  if author != "" {
    set text(config.author-size, font: config.author-font)
    align(center, author)
  }

  // 日期
  if date != none {
    date = if date == auto {
      datetime.today().display("[year]年[month]月[day]日")
    } else {
      date
    }
    set text(config.author-size, font: config.author-font)
    align(center, date)
  }

  // 摘要和关键词
  if abstract != none [
    *摘要：* #abstract

    #if keywords != () [
      *关键字：* #keywords.join("；")
    ]
  ]
}

// ================================
// 主模板函数
// ================================

#let project(
  title: "",
  author: "",
  date: none,
  abstract: none,
  keywords: (),
  body,
) = {
  title-state.update(title)
  show table: three-line-table

  // 文档设置
  set document(author: author, title: title, date: date, keywords: keywords)

  // 页面设置
  set page(
    numbering: "1",
    number-align: center,
    header: prev-header,
    header-ascent: config.leading,
  )

  // 基础样式设置
  set heading(numbering: "1.1")
  set text(
    font: config.body-font,
    lang: "zh",
    region: "cn",
    size: config.text-size,
  )
  set par(
    first-line-indent: (amount: 2em, all: true),
    justify: true,
    leading: config.leading,
    spacing: config.spacing,
  )
  set enum(
    indent: config.indent,
    full: true,
    numbering: (..n) => {
      n = n.pos()
      let level = n.len()
      let number = config.enum-numbering.at(level - 1, default: "1.")
      numbering(number, ..n.slice(level - 1))
    },
  )
  set list(
    indent: config.indent,
    marker: config.list-marker,
  )
  set math.equation(numbering: "(1)")
  set underline(evade: false)
  set bibliography(style: "gb-7714-2015-numeric")

  // ================================
  // 标题样式
  // ================================

  show heading: set text(font: config.heading-font)
  show heading: set block(above: 1.3em, below: 1.3em)
  show heading: it => block({
    if it.numbering != none {
      counter(heading).display() + h(config.small-space)
    }
    it.body
  })

  show heading.where(level: 1): it => {
    set align(center)
    set text(config.title1-size)
    set heading(numbering: "一")
    it
  }
  show heading.where(level: 2): set text(config.title2-size)
  show heading.where(level: 3): set text(config.title3-size)

  // ================================
  // 元素样式
  // ================================

  // 数学公式：无标签则不编号
  show math.equation: it => {
    set block(breakable: true)
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("_")
    ] else {
      it
    }
  }

  // 图表样式
  show figure: set text(font: config.caption-font)
  show figure.where(kind: table): set figure.caption(position: top)
  show table: set text(font: config.body-font)

  // 列表样式
  show list: it => {
    set list(indent: 0em)
    set enum(indent: 0em)
    it
  }
  show enum: it => {
    set list(indent: 0em)
    set enum(indent: 0em)
    it
  }
  show terms: set text(font: config.caption-font)

  // 文字样式
  show strong: set text(font: config.strong-font)
  show emph: set text(font: config.emph-font)
  show ref: set text(red)
  show link: it => {
    set text(blue)
    underline(it)
  }

  // 代码样式
  show raw: set text(font: config.raw-font, size: config.text-size)
  show raw.where(block: true): set block(
    width: 100%,
    fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    stroke: luma(200) + 0.5pt,
  )

  // ================================
  // 文档标题部分
  // ================================
  make-title(
    title: title,
    author: author,
    date: date,
    abstract: abstract,
    keywords: keywords,
  )

  // 正文内容
  body
}
