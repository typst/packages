#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ"


#let cover(
  author,
  college,
  major,
  class,
  id,
  teacher,
  date,
) = {
  set align(center)
  set text(font: fonts.sans, size: zh(3))

  v(13pt)
  box(image("../../assets/gzu_logo.png"))
  h(25pt)
  box(image("../../assets/gzu_name.png"))
  v(1fr)
  text(size: zh(2))[本科毕业论文（设计）]
  v(1fr)
  show title: set text(zh(-2))
  title[论文（设计）题目：#context document.title]
  v(1fr)

  context {
    table(
      columns: (auto, auto),
      rows: 1.1cm,
      inset: ((x: 5pt, y: 0.5pt), (x: 1em, y: 1.0pt)),
      align: bottom + center,
      stroke: (none, (bottom: 0.5pt + text.fill)),
      [学#h(2em)院：], college,
      [专#h(2em)业：], major,
      [班#h(2em)级：], class,
      [学#h(2em)号：], id,
      [学生姓名：], author,
      [指导教师：], teacher,
    )
  }
  v(3.9em)
  date.display("[year]年[month]月[day]日")
  v(3.5em)
  pagebreak(weak: true)
}
