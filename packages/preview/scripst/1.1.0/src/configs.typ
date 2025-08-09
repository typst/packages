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

#let color = (
  red: rgb("#f62d2d53"),
  green: rgb("#72ab68ab"),
  blue: rgb("#817ffab7"),
  grey: rgb("#c2c2c2ad"),
  purple-grey: rgb("#6f68abab"),
  purple: rgb("#ac2df653"),
  green-blue: rgb("#2dab8cab"),
)

#let cb = (
  "thm": ("Theorem", color.blue),
  "def": ("Definition", color.green),
  "prob": ("Problem", color.purple),
  "prop": ("Proposition", color.purple-grey),
  "ex": ("Example", color.green-blue),
  "note": ("Note", color.grey),
  "cau": ("⚠️", color.red),
)
