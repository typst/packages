// ordinary-layouts.typ
// 普通文档布局

#let ordinary-layouts = (
  page-settings: (
    paper: "a4",
    margin: (left: 1.5cm + 6.5cm, bottom: 1.5cm + 5.5cm, right: 1.5cm, top: 1.5cm),
  ),
  
  header: context {
    set text(font: ("Times New Roman", "kaiti"))
    if counter(page).at(here()).first() == 0 { return }

    let elems = query(heading.where(level: 1).after(here()))
    let before-elems = query(heading.where(level: 1).before(here()))

    let chapter-title = ""

    if elems != () and elems.first().location().page() == here().page() {
      chapter-title = elems.first().body
    } else if before-elems != () {
      chapter-title = before-elems.last().body
    }

    if chapter-title == "" { return }

    align(center)[#emph(chapter-title)] // 居中显示章节标题

    v(-8pt)
    align(center)[#line(length: 105%, stroke: (thickness: 1pt, dash: "solid"))]
  },
  
  footer: context {
    if counter(page).at(here()).first() == 0 { return }
    let page-width = 21cm  // A4纸宽度
    place(
      bottom + left,
      dx: page-width / 5.5,
      dy: -0.25cm,
      text(size: 10pt)[#align(center, counter(page).display("1 / 1", both: true))]
    )
  }
)
