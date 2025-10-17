#import "@preview/litfass:0.1.1"
#import litfass.tiling: *

#set page(width: 21cm, height: 10cm)

#let theme = {
  let theme = litfass.themes.basic
  theme.padding = 0.2em
  theme.box.padding = 0.2em
  theme.box.title.background = gray

  theme
}

#let inline-box = litfass.render.inline-box.with(theme: theme)

#let tiling = vs(
  cut: 50%,
  cbx([]),
  hs(cut: 40%, cbx([]), cbx([]))
)

#set align(center)
#grid(
  columns: (1fr, 1fr),
  [
    #let bbox = (width: 20em, height: 15em)
    #inline-box(tiling, ..bbox, stroke: black)
  ],
  [
    #let bbox = (width: 15em, height: 20em)
    #inline-box(tiling, ..bbox, stroke: black)
  ]
)
