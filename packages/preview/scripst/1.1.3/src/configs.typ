#let song = ("CMU Serif", "Linux Libertine", "SimSun")
#let hei = ("CMU Serif", "Linux Libertine", "SIMHEI")
#let kai = ("CMU Serif", "Linux Libertine", "KaiTi")
#let code = "Consolas"
#let smallcap = ("Linux Libertine", "SimSun")

#let font = (
  title: hei,
  author: kai,
  body: song,
  countblock: song,
  heading: hei,
  caption: kai,
  header: smallcap,
  strong: hei,
  emph: kai,
  quote: kai,
  raw: code,
)

#let mycolor = (
  red: rgb("#f44336a0"),
  green: rgb("#4caf50a0"),
  blue: rgb("#2196f3a0"),
  grey: rgb("#9e9e9ea0"),
  purple: rgb("#9c27b0a0"),
  cyan: rgb("#00bcd4a0"),
  orange: rgb("#ff9800a0"),
  violet-light: rgb("#b39ddbaf"),
  violet: rgb("#9575cdb0"),
  violet-dark: rgb("#7e57c2b0"),
  violet-darker: rgb("#673ab7b0"),
  violet-deep: rgb("#5e35b1b0"),
)

#let cb = (
  "def": ((key: "definition"), mycolor.green, "def"),
  "thm": ((key: "theorem"), mycolor.blue, "thm"),
  "prop": ((key: "proposition"), mycolor.violet, "prop"),
  "lem": ((key: "lemma"), mycolor.violet-light, "prop"),
  "cor": ((key: "corollary"), mycolor.violet-dark, "prop"),
  "rmk": ((key: "remark"), mycolor.violet-darker, "prop"),
  "clm": ((key: "claim"), mycolor.violet-deep, "prop"),
  "ex": ((key: "exercise"), mycolor.purple, "ex"),
  "prob": ((key: "problem"), mycolor.orange, "prob"),
  "eg": ((key: "example"), mycolor.cyan, "eg"),
  "note": ((key: "note"), mycolor.grey, "note"),
  "cau": ("⚠️", mycolor.red, "cau"),
  "cb-counter-depth": 2,
)
