#import "@preview/litfass:0.1.0"

#import litfass.render: inline-box
#import litfass.tiling: *

#set page(width: 15cm, height: 11cm)

#let theme = {
  let thm = litfass.themes.basic
  thm.box.background = gray
  thm.padding = 0.2em
  thm.box.padding = 0.2em
  thm
}
#let inline-box = inline-box.with(theme: theme)

#set align(center)

#set text(11pt)
#let highlight-box-style = (
  background: rgb("ffbbb2"),
  title: (
    background: rgb("7a1e1e")
  )
)
#let tiling = vs(
  cut: 50%,
  cbx(lorem(12), title: [foo]),
  hs(
    cut: 40%,
    cbx(lorem(5)), cbx(lorem(6), title: [bar]),
    theme: (box: highlight-box-style)
  )
)

#inline-box(tiling, width: 12cm, height: 8cm)
