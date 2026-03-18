#import "@preview/litfass:0.1.1"

#import litfass.render: inline-box
#import litfass.tiling: *

#set page(width: 30cm, height: 11cm)

#let theme = {
  let thm = litfass.themes.basic
  thm.box.background = gray
  thm.padding = 0.2em
  thm.box.padding = 0.2em
  thm
}
#let inline-box = inline-box.with(theme: theme)
#let tiling = vs(
  cut: 50%,
  cbx(lorem(12), title: [foo]),
  hs(cut: 40%, cbx(lorem(5)), cbx(lorem(6), title: [bar]))
)

#set align(center)

#grid(
  columns: 2,
  align: center,
  gutter: 2em,
  [ 
    #set text(11pt)
    #inline-box(tiling, width: 12cm, height: 8cm)
  ],
  [
    #set text(11pt)
    #let new-theme = {
      let thm = theme
      thm.box.title.background = rgb("1e7a63")
      thm.background = gray
      thm.box.background = white
      thm
    }
    #inline-box(tiling, width: 12cm, height: 8cm, theme: new-theme)
  ]
)
