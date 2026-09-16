// ============================================================
// 通用图表布局组件
//
// 设计原则：
// - helper 只负责布局，不绑定具体图片路径或绘图库。
// - body 可以是 image、figure、plot、table、mermaid 或任意 Typst 内容。
// - 所有组件都可独立导入，也可由 template-landscape.typ 统一导出。
// ============================================================

#let chart-border = rgb("#d8dde3")
#let chart-background = rgb("#f8fafc")
#let chart-title-color = rgb("#1a4971")
#let chart-muted-color = rgb("#667085")

// 单个图表卡片。
// body 是位置参数，因此应放在所有命名参数之后：
// #chart-card(title: [标题], height: 6cm)[图表内容]
#let chart-card(
  title: none,
  subtitle: none,
  badge: none,
  height: auto,
  fill: chart-background,
  stroke: 0.7pt + chart-border,
  radius: 5pt,
  inset: 10pt,
  body,
) = block(
  width: 100%,
  height: height,
  fill: fill,
  stroke: stroke,
  radius: radius,
  inset: inset,
  breakable: false,
)[
  #if title != none or badge != none {
    grid(
      columns: (1fr, auto),
      gutter: 8pt,
      align: horizon,
      if title != none {
        text(size: 10.5pt, weight: "bold", fill: chart-title-color, title)
      } else { [] },
      if badge != none {
        box(
          fill: rgb("#e8f1fb"),
          radius: 20pt,
          inset: (x: 7pt, y: 3pt),
          text(size: 7.5pt, fill: chart-title-color, badge),
        )
      } else { [] },
    )
    v(3pt)
  }
  #if subtitle != none {
    text(size: 8pt, fill: chart-muted-color, subtitle)
    v(7pt)
  }
  #body
]

// 图表占位符，适合在模板设计阶段使用。
#let chart-placeholder(
  label: [图表区域],
  height: 5.5cm,
  fill: white,
) = block(
  width: 100%,
  height: height,
  fill: fill,
  stroke: (paint: chart-border, thickness: 0.7pt, dash: "dashed"),
  radius: 4pt,
)[
  #align(center + horizon)[
    #text(size: 9pt, fill: chart-muted-color)[#label]
  ]
]

// 基础 Grid。items 是内容数组，例如：
// #chart-grid((card-a, card-b, card-c), columns: 3)
#let chart-grid(
  items,
  columns: 2,
  gutter: 12pt,
  row-gutter: none,
  align: top,
) = grid(
  columns: columns,
  column-gutter: gutter,
  row-gutter: if row-gutter == none { gutter } else { row-gutter },
  align: align,
  ..items,
)

// 常用等宽列快捷方式。
#let chart-grid-2(items, gutter: 12pt) = chart-grid(
  items,
  columns: (1fr, 1fr),
  gutter: gutter,
)

#let chart-grid-3(items, gutter: 12pt) = chart-grid(
  items,
  columns: (1fr, 1fr, 1fr),
  gutter: gutter,
)

#let chart-grid-4(items, gutter: 10pt) = chart-grid(
  items,
  columns: (1fr, 1fr, 1fr, 1fr),
  gutter: gutter,
)

// 左右对比，ratio 控制两侧宽度，例如 ratio: (2fr, 1fr)。
#let chart-compare(
  left,
  right,
  ratio: (1fr, 1fr),
  gutter: 12pt,
) = grid(
  columns: ratio,
  gutter: gutter,
  align: top,
  left,
  right,
)

// 一张主图 + 右侧上下两张辅助图。
#let chart-featured(
  featured,
  side-top,
  side-bottom,
  ratio: (2fr, 1fr),
  gutter: 12pt,
) = grid(
  columns: ratio,
  rows: (auto, auto),
  column-gutter: gutter,
  row-gutter: gutter,
  align: top,
  grid.cell(rowspan: 2, featured),
  side-top,
  side-bottom,
)

// 上方一张通栏图，下方并排若干图表。
#let chart-hero-row(
  hero,
  items,
  columns: 3,
  gutter: 12pt,
) = grid(
  columns: (1fr,),
  row-gutter: gutter,
  hero,
  chart-grid(items, columns: columns, gutter: gutter),
)

// 图表与说明文字并排，适用于需要在右侧解释结论的页面。
#let chart-with-notes(
  chart,
  notes,
  chart-width: 2fr,
  notes-width: 1fr,
  gutter: 14pt,
) = grid(
  columns: (chart-width, notes-width),
  gutter: gutter,
  align: top,
  chart,
  block(
    width: 100%,
    fill: rgb("#f5f6f8"),
    radius: 5pt,
    inset: 12pt,
    notes,
  ),
)

