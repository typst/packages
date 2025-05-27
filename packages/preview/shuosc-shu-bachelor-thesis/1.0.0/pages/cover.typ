#import "../style/font.typ": ziti, zihao
#import "../style/distr.typ": distr
#import "../style/uline.typ": uline

#let cover-page(
  info: (:),
  title-line-length: 260pt,
) = context {
  set page(
    background: scale(107.8%, origin: top + center)[#image("../assets/cover.png")],
    header: none,
  )
  set par(first-line-indent: 2em, spacing: 0em, leading: 0em)

  align(
    center,
    text(font: ziti.songti.get(), size: zihao.chuhao, stroke: 0.2pt)[
      #v(2.8em)
      本科毕业论文（设计）
    ],
  )
  align(
    center,
    text(font: ziti.songti.get(), size: zihao.xiaoer)[
      #v(1.3em)
      UNDERGRADUATE#h(1em)THESIS (PROJECT)
      #v(5em)
    ],
  )

  let colon = "："

  set text(
    font: ziti.songti.get(),
    size: 16pt,
  )

  let title-key(zh) = text(distr(zh, w: 4em))
  let title-value(zh) = uline(title-line-length, text(zh))
  table(
    align: center + horizon,
    stroke: none,
    columns: (auto, auto, auto),
    column-gutter: (-0.3em, 0.3em),
    inset: (right: 0em),
    title-key("题目"), colon, title-value(info.title),
  )

  v(2em)

  set text(
    font: ziti.songti.get(),
    size: 16pt,
  )
  let info-key(zh) = text(distr(zh, w: 4em))
  let info-value(zh) = uline(260pt, text(zh))
  table(
    align: center + horizon,
    stroke: none,
    rows: 1.9em,
    columns: (auto, auto, auto),
    column-gutter: (-0.3em, 0.3em),
    inset: (right: 0em),
    info-key("学院"), colon, info-value(info.school),
    info-key("专业"), colon, info-value(info.major),
    info-key("学号"), colon, info-value(info.student_id),
    info-key("学生姓名"), colon, info-value(info.name),
    info-key("指导教师"), colon, info-value(info.supervisor),
    info-key("起讫日期"), colon, info-value(info.date),
  )
}
