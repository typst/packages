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

#let roman-font = (
  (name: "Times New Roman", covers: regex("\w")), // 西文字体
  (name: "TeX Gyre Termes Math", covers: regex("[^𝑗𝑓𝜋∅/]")),
  "XITS Math",
  "Noto Serif CJK SC",
)

#let ncm-font = (
  "New Computer Modern",
  "New Computer Modern Math",
  "Noto Serif CJK SC",
)

#let _heiti-regex = regex("[^a-zA-Z0-9，。、；：？！\"\"''（）《》〈〉…—·]")
#let heiti = (
  (name: "SimHei", covers: _heiti-regex),
  (name: "Noto Sans CJK SC", covers: _heiti-regex),
)

#let kaiti = ("STKaiti",)
