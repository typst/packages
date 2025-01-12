// cornell-lines.typ
// 康奈尔笔记风格的线条

#let cornell-lines() = {
  // 左侧垂直线
  place(
    left,
    dx: 6cm,
    line(
      start: (0pt, 0pt),
      end: (0pt, 85%),
      stroke: 0.5pt
    )
  )
  // 底部水平线
  place(
    bottom,
    dy:-4.45cm,
    line(
      start: (0pt, 0pt),
      end: (100%, 0pt),
      stroke: 0.5pt
    )
  )
}
