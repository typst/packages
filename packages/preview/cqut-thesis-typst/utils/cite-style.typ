// 引用、链接样式
#let custom-link = (it) => {
  let color = blue
  if type(it.dest) == str {
    color = green
  }
  underline(stroke: color, offset: 2pt, it)
}

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