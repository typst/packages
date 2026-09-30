// 顺序编码制参考文献引用、
//、同一处引用多篇文献时，连续序号起讫间用短横线"-"（U+002D）
// 连接，如 [255-256]、[1-4]。gb-7714-2015-numeric CSL 默认用 en dash"–"（U+2013）连接连续
//
// 序号上标（[1] 置于上标）由 gb-7714-2015-numeric CSL 默认提供，无需模板干预。
// 多篇合并（[1,2] 英文逗号、[1-4] 短横线）由 CSL 在相邻 cite 时自动处理，
// 前提是用 @a@b 紧邻书写或 #cite(<a>)#cite(<b>) 相邻调用，勿用分号隔开。
//
// 判据：参考文献引用的 it.element 恒为 none（bibliography entry 不是文档内可定位元素），
// 而图表（figure）、公式（equation）、标题（heading）等文档内引用的 it.element 为对应元素
// （前向引用亦然——Typst 多遍编译会解析所有文档内 label）。故 it.element == none 精确区分
// 参考文献引用，不会误伤图表/公式/标题引用，也不会误伤目录页码引用（其 element 为 heading）。
// show regex 仅在返回的 it 作用域内生效，不影响全文其他 en dash，亦不影响文后参考文献
// 著录条目（其页码范围本就用 hyphen，且不经过 show ref）。

#let citation-range-hyphen(it) = {
  if it.element == none {
    // 参考文献引用：连续序号 en dash → hyphen
    show regex("\u{2013}"): "-"
    it
  } else {
    // 图表/公式/标题等文档内引用：原样返回
    it
  }
}
