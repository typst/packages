#import "/src/lib.typ": *
#import "@preview/cetz:0.3.4"

#set page(width: auto, height: auto, margin: (bottom: 2cm, rest: 1cm), fill: white)
#set text(24pt)

$
  mark(x, tag: #<x>) + mark(y, tag: #<y>)

  #annot-cetz((<x>, <y>), cetz, {
    import cetz.draw: *
    content((0, -1), [CeTZ], anchor: "north-west", name: "a")
    line("x", "a") // You can refer the marked content.
    line("y", "a")
  })
$
