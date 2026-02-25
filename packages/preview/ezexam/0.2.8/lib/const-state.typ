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

// #let main-font = ("New Computer Modern Math", "Noto Serif CJK SC")
#let heiti = ("SimHei", "Heiti SC", "Noto Sans CJK SC")
#let roman = (
  (name: "Times New Roman", covers: regex("\w")),
  (name: "TeX Gyre Termes", covers: regex("\w")),
  "TeX Gyre Termes Math",
  "Noto Serif CJK SC",
)

#let EXAM = "exam" // 试卷模式
#let HANDOUTS = "handouts" // 讲义模式(默认)
#let SOLUTION = "solution" // 解析模式

#let mode-state = state("mode", HANDOUTS)
#let answer-state = state("answer", false)
#let answer-color-state = state("answer-color", blue)
#let subject-state = state("subject", "")
