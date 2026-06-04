#import "../style/font.typ": ziti, zihao
#import "../style/distr.typ": distr
#import "../style/uline.typ": uline

#let cover-page(
  info: (:),
) = {
  set page(
    background: image("../assets/cover.png", width: 100%),
    header: none,
  )
  set par(first-line-indent: 2em, spacing: 0em, leading: 0em)

  align(
    center,
    text(font: ziti.songti, size: zihao.chuhao, stroke: 0.2pt)[
      #v(2.6em)
      本科毕业论文（设计）
    ],
  )
  align(
    center,

    text(font: ziti.songti, size: zihao.xiaoer)[
      #v(1.3em)
      UNDERGRADUATE#h(1em)THESIS (PROJECT)
      #v(7em)
    ],
  )

  let info-key(zh) = (
    text(
      distr(zh, w: 4em),
      font: ziti.songti,
      size: 16pt,
    )
  )

  let info-value(zh) = uline(
    260pt,
    text(
      zh,
      font: ziti.songti,
      size: 16pt,
    ),
  )

  let quote = table.cell(inset: (top: 0.7em), text(stroke: 1pt)[:])

  table(
    align: (x, y) => (
      if x >= 1 {
        left
      } else {
        right
      }
    ),
    stroke: none,
    columns: (15%, 1%, 60%),
    inset: (right: 0em),
    column-gutter: (-0.3em, 1em),
    info-key("题目"), quote, info-value(info.title),
    [#v(1.3em)], [], [],
    info-key("学院"), quote, info-value(info.school),
    info-key("专业"), quote, info-value(info.major),
    info-key("学号"), quote, info-value(info.student_id),
    info-key("学生姓名"), quote, info-value(info.name),
    info-key("指导教师"), quote, info-value(info.supervisor),
    info-key("起讫日期"), quote, info-value(info.date),
  )
}
