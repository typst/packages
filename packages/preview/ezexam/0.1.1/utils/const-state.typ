#let a3 = (
  paper: "a3",
  margin: 1in,
  columns: 2,
  flipped: true,
)

#let a4 = (
  paper: "a4",
  margin: 1in,
  columns: 1,
  flipped: false,
)

#let math-font = "New Computer Modern Math"
#let page-font = (math-font, "Source Han Serif")
#let hei-ti = (math-font, "SimHei")
#let kai-ti = (math-font, "KaiTi")

//"exam": 试卷模式; "lecture": 讲义模式(默认)
#let EXAM = "exam"
#let LECTURE = "lecture"
#let mode-state = state("mode", LECTURE)
#let answer-state = state("answer", false)
#let answer-color-state = state("answer-color", blue)
#let subject-state = state("subject", "")

// 定义虚线盒子及多选样式
#let multi = text(maroon)[（多选）]
#let dotbox(body, color: blue) = {
  box(
    outset: .35em,
    radius: 3pt,
    stroke: (
      thickness: .5pt,
      dash: "dotted",
      paint: color,
    ),
    text(font: kai-ti, color, body),
  )
  h(.8em)
}

