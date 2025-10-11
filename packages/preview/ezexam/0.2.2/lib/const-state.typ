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

#let latin-fonts = ("New Computer Modern Math","")
#let doc-fonts = ("Noto Serif SC", "Noto Serif CJK SC", "SimSun",)
#let hei-ti = ("SimHei", "Noto Sans SC", "Noto Sans CJK SC")
#let kai-ti = ("KaiTi",)
#let ROMAN = ("Times New Roman", "TeX Gyre Termes Math",) + doc-fonts

//"exam": 试卷模式; "handouts": 讲义模式(默认)；"solution"：解析模式
#let EXAM = "exam"
#let HANDOUTS = "handouts"
#let SOLUTION = "solution"

#let mode-state = state("mode", HANDOUTS)
#let answer-state = state("answer", false)
#let answer-color-state = state("answer-color", blue)
#let subject-state = state("subject", "")
