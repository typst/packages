// ============================================================
// footer.typ — 页脚生成
// 根据 partcounter 部分显示罗马数字（前置部分）或阿拉伯数字（正文/附录）
// 封面部分（part == 0）不显示页脚
// 本页管辖标题的 show-page-marks 元数据为 false 时清除页码（如声明页 clean-declaration）
// ============================================================

#import "../utils/counter.typ": partcounter, skippedstate
#import "headings-meta.typ": get-heading-meta, get-page-headings

/// 生成页脚页码（作为 place 元素放置在页面底部）
#let make-footer(style: none) = context {
  let part = partcounter.at(here()).first()
  if part == 0 { return }

  let logical-page = counter(page).at(here()).first()
  if skippedstate.at(here()) and calc.even(logical-page) { return }

  // clean-declaration 检测：本页管辖标题的 show-page-marks 为 false 时隐藏页码
  let governing = get-page-headings(here()).governing
  if governing != none {
    let meta = get-heading-meta(governing)
    if not meta.at("show-page-marks", default: true) {
      return
    }
  }

  set text(size: style.页码.size)
  set align(center)

  let page-num = counter(page).at(here()).first()

  place(bottom + center)[
    #set align(bottom)
    #if part == 1 {
      numbering("I", page-num)
    } else {
      str(page-num)
    }
    #v(style.页码.垂直位置)
  ]
}
