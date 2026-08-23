// ============================================================
// header.typ — 页眉生成
// 根据 partcounter 所处的部分（封面/前置/正文/附录）自动选择页眉内容
// 偶数页显示 header-text（如"北京大学博士学位论文"）
// 奇数页显示当前章节标题（或自定义 header 元数据）
// ============================================================

#import "../utils/number.typ": chinesenumbering
#import "../utils/counter.typ": partcounter, skippedstate
#import "headings-meta.typ": get-heading-meta, get-page-headings

/// 生成页眉内容（作为 place 元素放置在页面顶部）
/// header-text: 偶数页统一显示的页眉文本
#let make-header(header-text: none, style: none) = context {
  // 脚注序号按页编排：每页页眉求值时重置脚注计数器
  counter(footnote).update(0)
  let part = partcounter.at(here()).first()
  let logical-page = counter(page).at(here()).first()

  let page-headings = get-page-headings(here())
  let current-page-heading = page-headings.current

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
  let el = page-headings.governing
  if el == none { return }

  let meta = get-heading-meta(el)
  if not meta.at("show-page-marks", default: true) { return }

  set text(size: style.页眉.size)
  set par(spacing: 0pt)
  set align(center)

  place(top + center, dy: style.页眉.垂直位置)[
    #block(width: 100%)[
      #stack(
        dir: ttb,
        spacing: style.页眉.堆叠间距,
        if is-even {
          header-text
        } else {
          let custom-header = meta.at("header", default: none)
          if custom-header == none { custom-header = el.body }
          if el.numbering != none {
            chinesenumbering(
              ..counter(heading).at(el.location()),
              location: el.location(),
            )
            h(style.页眉.编号间距)
          }
          custom-header
        },
        line(stroke: style.页眉.下划线粗细, length: 100%),
      )
    ]
  ]
}
