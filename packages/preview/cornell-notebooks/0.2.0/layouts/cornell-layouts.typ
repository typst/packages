// cornell-layouts.typ
// 康纳尔笔记布局 

#import "../layouts/cornell-lines.typ": cornell-lines

#let cornell-layouts(body) = {
  show: it => {
    set page(
      paper: "a4",
      margin: (left: 1.5cm + 5cm, bottom: 1.5cm + 5.5cm, right: 1.5cm, top: 1.5cm),
      background: cornell-lines()
    )
    it
  }
  body
}
