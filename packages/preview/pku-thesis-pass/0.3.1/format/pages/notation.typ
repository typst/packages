// ============================================================
// notation.typ — 主要符号对照表
// 提供主要符号对照表页面，放在目录（及图/表/代码/公式列表）之后、正文之前。
// 内容使用 Typst 原生术语语法：`/ 符号: 说明`，
// 空行用于分组（如符号、希腊字母、缩略词等）。
// ============================================================

#import "../layouts/headings.typ": front-heading

/// 主要符号对照表
/// title: 页面标题（默认"主要符号对照表"）
/// columns: 列宽模板，默认 4 列（两对"符号 + 说明"并排），
///          也可传 2 列 `(auto, 1fr)` 恢复每行一对的排法
/// row-gutter: 行间距
/// group-gutter: 分组（空行）之间的额外间距
/// body: 内容，使用 `/ 符号: 说明` 语法，空行分组
#let notation-page(
  title: "主要符号对照表",
  columns: (auto, 1fr, auto, 1fr),
  style: none,
  body,
) = {
  front-heading(title)

  set par(first-line-indent: 0em)

  // 列数（每对占 2 列）。默认双栏 = 4 列。
  let col-count = columns.len()

  // 将内容子元素映射为 grid 单元格：
  //   terms.item -> (符号, 说明) 两个单元格
  //   parbreak   -> 独立成行的空单元格，产生分组间距。
  //   若一组条目数为奇数（如 3 条占 1.5 行），先插入一个补齐剩余列的
  //   空单元格强制换行，再插入跨全部列数的空行，保证空行不被吞掉。
  let (out, _) = body.children.fold(((), 0), (acc, it) => {
    let (o, used) = acc
    if it.func() == terms.item {
      (o + (it.term, it.description), calc.rem(used + 2, col-count))
    } else if it.func() == parbreak {
      let rest = col-count - used
      let gap = grid.cell(none, colspan: col-count, inset: (y: (style.符号表.group-gutter - style.符号表.row-gutter) / 2))
      if rest == col-count {
        (o + (gap,), 0)
      } else {
        (o + (grid.cell(none, colspan: rest), gap), 0)
      }
    } else {
      (o, used)
    }
  })

  block(width: 100%, grid(
    columns: columns,
    align: left,
    column-gutter: style.符号表.列间距,
    row-gutter: style.符号表.row-gutter,
    ..out,
  ))
}
