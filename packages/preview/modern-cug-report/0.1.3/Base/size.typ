#import "base.typ": is-scalar, merge-dict


#let font = (
  四号: 14pt,
  小四: 12pt,
  五号: 10.5pt,
)


// 必须要定义为show function才能生效
#let set-size(it, config) = {
  set text(size: config.text)

  show math.equation: set text(size: config.math.text)
  show math.equation.where(block: true): set text(size: config.math.block)

  show figure.caption: set text(size: config.figure) // 图名
  show figure.caption.where(kind: table): set text(size: config.table) // 表名

  // 不要在全局设置 table.cell 样式，会导致后续无法覆盖
  // 使用 table-default 或 table-styled 函数来应用样式
  show raw: set text(size: config.raw)

  show heading.where(level: 1): set text(size: config.heading.H1)
  show heading.where(level: 2): set text(size: config.heading.H2)
  show heading.where(level: 3): set text(size: config.heading.H3)
  show heading.where(level: 4): set text(size: config.heading.H4)
  show heading.where(level: 5): set text(size: config.heading.H5)
  show heading.where(level: 6): set text(size: config.heading.H6)
  it
}

#let default-size(text: 13pt) = {
  (
    text: text,
    math: (
      text: text - 0.5pt, // 插入正文的公式
      block: text - 0.5pt, // 单独一行的公式
    ),
    figure: text - 1pt, // 图件标题
    table: text - 1pt, // 表格标题
    raw: text - 2pt, // 代码
    heading: (
      default: text, //
      H1: text + 1.5pt, // default + 1
      H2: text + 1.0pt, // default
      H3: text + 0.5pt, // default
      H4: text + 0.5pt, // default
      H5: text + 0.5pt, // default
      H6: text + 0.5pt, // default
    ),
  )
}

#let define-size(text, config) = {
  let base_size = default-size(text: text)
  merge-dict(base_size, config)
}

// 为表格应用自定义样式（统一函数，可用于默认或特殊表格）
#let table-styled(tbl, config: (text: 11pt, math: 10pt)) = {
  show table.cell: it => {
    set text(size: config.text)
    show math.equation: set text(size: config.math)
    it
  }
  tbl
}
