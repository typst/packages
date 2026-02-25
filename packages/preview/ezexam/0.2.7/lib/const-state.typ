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

#let main-font = ("New Computer Modern Math", "Noto Serif CJK SC")
#let heiti = ("SimHei", "Heiti SC", "Noto Sans CJK SC")
#let roman = ((name: "Times New Roman", covers: regex("\w")), "TeX Gyre Termes Math") + main-font


// "exam": 试卷模式; "handouts": 讲义模式(默认)；"solution"：解析模式
#let EXAM = "exam"
#let HANDOUTS = "handouts"
#let SOLUTION = "solution"

#let mode-state = state("mode", HANDOUTS)
#let answer-state = state("answer", false)
#let answer-color-state = state("answer-color", blue)
#let subject-state = state("subject", "")
