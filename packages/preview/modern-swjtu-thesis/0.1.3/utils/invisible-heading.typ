// 用于创建一个不可见的标题，用于给 outline 加上短标题
#let invisible-heading(..args) = {
  set text(size: 0pt, fill: white)
  heading(numbering: none, ..args)
}