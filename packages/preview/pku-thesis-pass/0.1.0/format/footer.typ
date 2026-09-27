// ============================================================
// footer.typ — 页脚生成
// 根据 partcounter 阶段显示罗马数字（前置部分）或阿拉伯数字（正文）
// 封面阶段（part == 0）不显示页脚
// 声明页启用 clean-declaration 后清除页码
// ============================================================

#import "const.typ": size
#import "utils.typ": partcounter, skippedstate

/// 生成页脚页码（作为 place 元素放置在页面底部）
#let make-footer() = context {
  let part = partcounter.at(here()).first()
  if part == 0 { return }

  let logical-page = counter(page).at(here()).first()
  if skippedstate.at(here()) and calc.even(logical-page) { return }

  // clean-declaration 检测：若在声明页之后且无更多 heading，隐藏页码
  if (
    query(selector(heading).after(here())).len() == 0
      and query(selector(<__clean_declaration__>)).len() > 0
  ) { return }

  set text(size: size.页码)
  set align(center)

  let page-num = counter(page).at(here()).first()

  place(bottom + center)[
    #set align(bottom)
    #if part == 1 {
      numbering("I", page-num)
    } else {
      str(page-num)
    }
    #v(1.75cm)
  ]
}
