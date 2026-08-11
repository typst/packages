#import "@preview/itemize:0.1.1" as el
#set page(width: 150mm, height: auto, margin: 25pt)
#let item = [
  + one
  + two
    + #lorem(10)
    + + #lorem(10)
      + #lorem(10)
    + - #lorem(10)
      - #lorem(10)
  + tree
]

#show: el.set-default()
#set enum(numbering: "(1).(a).(i)")
#item

// change the label color
#show: el.set-default(fill: (red, blue, green, auto))
#item

// change the label size
#show: el.set-default(size: (20pt, 16pt, 14pt, auto))
#item

// change the body-indent and indent
#show: el.set-default(body-indent: (auto, 0.5em), indent: (auto, 0em, 1em, auto))
#item

// use the default style
#show: el.set-default()
#item
