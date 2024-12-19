// 引用样式
#let custom-cite = (it) => {
  box(
    width: auto,
    height: auto,
    fill: none,
    stroke: 1.0pt + black,
    inset: 2pt,
    text(fill: green, it)
  )
}