#import "../style/font.typ": ziti, zihao
#import "../style/distr.typ": distr
#import "../style/uline.typ": uline

#let cover-page(
  date: datetime.today(),
  info: (:),
) = {
  set page(
    background: image("../assets/cover.png", width: 100%),
    header: none
  )

  v(4cm)
  align(
    center,
    text(font: ziti.songti, size: zihao.chuhao, weight: "medium")[本科毕业论文（设计）],
  )
  v(2em)
  align(
    center,
    text(font: ziti.songti, size: zihao.xiaoer, weight: "medium")[UNDERGRADUATE THESIS (PROJECT)],
  )

  v(3cm)

  let info-key(zh) = (
    text(
      distr(zh, w: 4em),
      font: ziti.songti,
      size: 16pt,
    )
  )

  let info-value(zh) = uline(
    25em, 
    text(
      zh,
      font: ziti.songti,
      size: 16pt,
    )
  )

  table(
    stroke: none,
    align: (x, y) => (
      if x >= 1 {
        left
      } else {
        right
      }
    ),
    columns: (15%, 1%, 60%),
    inset: (right: 0em),
    column-gutter: (-0.3em, 1em),
    row-gutter: 0.7em,
    info-key("题目"), text(weight: "bold")[:], info-value(info.title),
    [], [], [],
    [], [], [],
    info-key("学院"), text(weight: "bold")[:], info-value(info.school),
    info-key("专业"), text(weight: "bold")[:], info-value(info.major),
    info-key("学号"), text(weight: "bold")[:], info-value(info.student_id),
    info-key("学生姓名"), text(weight: "bold")[:], info-value(info.name),
    info-key("指导教师"), text(weight: "bold")[:], info-value(info.supervisor),
    info-key("起讫日期"), text(weight: "bold")[:], info-value(info.date),
  )

  linebreak()
}
