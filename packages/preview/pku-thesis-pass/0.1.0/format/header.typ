// ============================================================
// header.typ — 页眉生成
// 根据 partcounter 所处的阶段（封面/前置/正文）自动选择页眉内容
// 偶数页显示 header-text（如"北京大学博士学位论文"）
// 奇数页显示当前章节标题（或自定义 header 元数据）
// ============================================================

#import "const.typ": size
#import "utils.typ": chinesenumbering, partcounter, skippedstate
#import "headings.typ": get-heading-meta

/// 生成页眉内容（作为 place 元素放置在页面顶部）
/// header-text: 偶数页统一显示的页眉文本
#let make-header(header-text: none) = context {
  let part = partcounter.at(here()).first()
  let logical-page = counter(page).at(here()).first()
  let physical-page = here().page()

  // 查找当前页上/下最近的 1 级标题
  let headings-after = query(selector(heading.where(level: 1)).after(here()))
  let headings-before = query(selector(heading.where(level: 1)).before(here()))

  let current-page-heading = if headings-after.len() > 0 {
    let next = headings-after.first()
    if next.location().page() == physical-page { next } else { none }
  } else { none }

  // 检测是否为前置/正文的首个 heading（此时奇数页也应显示页眉）
  let is-front-first = if current-page-heading != none {
    let meta = get-heading-meta(current-page-heading)
    meta.at("part", default: none) == 1
  } else { false }

  let is-body-first = (
    current-page-heading != none
      and current-page-heading.numbering != none
      and part < 2
  )

  if part == 0 and not (is-front-first or is-body-first) { return }

  // 封面阶段或跳过页不显示
  let is-odd = if is-body-first or is-front-first {
    true
  } else {
    calc.odd(logical-page)
  }
  let is-even = not is-odd

  if skippedstate.at(here()) and is-even { return }

  // 确定显示的章节元素
  let el = if current-page-heading != none {
    current-page-heading
  } else if headings-before.len() > 0 {
    headings-before.last()
  } else { return }

  let meta = get-heading-meta(el)
  if not meta.at("show-header", default: true) { return }

  set text(size: size.页眉)
  set par(spacing: 0pt)
  set align(center)

  place(top + center, dy: 2cm)[
    #block(width: 100%)[
      #stack(
        dir: ttb,
        spacing: 3pt,
        if is-even {
          header-text
        } else {
          let header-text = meta.at("header", default: none)
          if header-text == none { header-text = el.body }
          if el.numbering != none {
            chinesenumbering(
              ..counter(heading).at(el.location()),
              location: el.location(),
            )
            h(0.5em)
          }
          header-text
        },
        line(stroke: 0.75pt, length: 100%),
      )
    ]
  ]
}
