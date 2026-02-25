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

#let roman = (
  (name: "Times New Roman", covers: regex("\w")), // 西文字体
  (name: "TeX Gyre Termes", covers: regex("\w")), // 无 Times New Roman 字体时使用
  "TeX Gyre Termes Math", // 数学字体
  "Noto Serif CJK SC",
)

#let heiti = (
  (name: "SimHei", covers: regex("[^a-zA-Z0-9]")),
  (name: "Noto Sans CJK SC", covers: regex("[^a-zA-Z0-9]")),
)

#let EXAM = "exam"
#let HANDOUTS = "handouts"
#let SOLUTION = "solution"
#let mode-state = state("mode", HANDOUTS)

#let answer-state = state("answer", false)
#let answer-color-state = state("answer-color", blue)

#let subject-state = state("subject", none)

#let chapter-pages-state = state("chapter-pages", ()) // 章节的第一页、最后一页、总页码
#let page-restart-state = state("page-restart", 0)
