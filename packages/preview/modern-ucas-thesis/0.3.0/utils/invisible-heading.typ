// 用于创建一个不可见的标题，用于给 outline 加上短标题。
// 用 hide() 而非 0pt 白字实现：hide 后的标题仍可被 query 查到
// （含 location().page()，页眉逻辑依赖此），但不进入 PDF 文本层，
// 复制/检索时不会出现重复标题；block(above/below: 0pt) + 0pt 字号
// 使其不占版面高度。
#let invisible-heading(..args) = {
  hide(block(
    above: 0pt,
    below: 0pt,
    text(size: 0pt, heading(numbering: none, ..args)),
  ))
}
