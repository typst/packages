// ============================================================
// subfigure.typ — 子图组件
// 提供主图内的子图：subfigure
// ============================================================

/// 子图组件
/// body: 子图内容（通常是 image(...)）
/// caption: 子图题注（显示为 "(a) 子图描述"，可选）
/// lbl: 子图标签（可选，供 @lbl 引用，显示为 "图 2.1(a)"）
/// 子图用独立 kind "subfigure" 编号，随主图出现从 (a)(b)(c)... 重新编号。
/// 子图需放置于主图 figure（#figure(#grid(...), kind: image, caption)）内部。
#let subfigure(body, caption: none, lbl: none, ..args) = {
  let fig = figure(
    body,
    caption: caption,
    kind: "subfigure",
    supplement: [图],
    numbering: "(a)",
    ..args,
  )
  if lbl == none { fig } else { [#fig #label(lbl)] }
}
