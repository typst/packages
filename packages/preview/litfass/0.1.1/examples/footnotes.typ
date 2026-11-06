#import "@preview/litfass:0.1.1"

#import litfass.render: inline-box
#import litfass.tiling: *

#set page(width: 15cm, height: 7.5cm)

#let theme = {
  let thm = litfass.themes.basic
  thm.box.title.background = gray
  thm.padding = 0.2em
  thm.box.padding = 0.2em
  thm
}
#let inline-box = inline-box.with(theme: theme)

#set align(center)

#set text(11pt)

#let tiling = vs(
  cut: 50%,
  cbx([
    Lorem ipsum dolor sit amet, consectetur#box-footnote[You can]
    adipiscing elit, sed do eiusmod tempor incididunt#box-footnote[place random footnotes]
    ut labore et dolore magnam aliquam#box-footnote[throughout a box!]
    quaerat voluptatem.
  ]),
  cbx([
    Lorem ipsum dolor sit amet, consectetur#box-footnote[Footnotes are _box-local_.]
    adipiscing elit, sed do eiusmod tempor incididunt#box-footnote[Footnote counters get reset at each box.]
    ut labore et dolore magnam aliquam 
    quaerat voluptatem.

    #type(gray)
  ]),
)

#inline-box(tiling, width: 12cm, height: 5.5cm)
