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

#let NCMM = "New Computer Modern Math"
#let source-han = (NCMM, "Source Han Serif", "SimSun")
#let hei-ti = (NCMM, "SimHei")
#let kai-ti = (NCMM, "KaiTi")

//"exam": 试卷模式; "handouts": 讲义模式(默认)；"solution"：解析模式
#let EXAM = "exam"
#let HANDOUTS = "handouts"
#let SOLUTION = "solution"

#let mode-state = state("mode", HANDOUTS)
#let answer-state = state("answer", false)
#let answer-color-state = state("answer-color", blue)
#let subject-state = state("subject", "")