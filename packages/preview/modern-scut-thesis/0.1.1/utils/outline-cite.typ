// 目录类页面（目录、插图目录、表格目录）中的引用处理
//
// 标题或图题中的 @cite 会随目录条目在前言部分再次渲染：直接渲染会提前登记引用、
// 抢占顺序编号；简单隐藏又丢失信息。这里将目录中的引用替换为其在正文中的顺序编号
// 文本（如“[14]”）：目录条目是原引用的副本，不参与引擎编号；编号按正文首次引用
// 顺序自行计算（副本位于前言页，按页码小于 mainmatter-start 过滤）。

#let outline-cite(it) = context {
  let start = query(<mainmatter-start>)
  if start.len() == 0 { return }
  let start-page = start.first().location().page()
  let order = ()
  for c in query(cite) {
    if c.location().page() >= start-page {
      let k = str(c.key)
      if k not in order { order.push(k) }
    }
  }
  let n = order.position(k => k == str(it.key))
  if n != none [\[#(n + 1)\]]
}
