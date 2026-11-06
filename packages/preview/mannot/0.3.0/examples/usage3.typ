#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 2cm, y: 1cm), fill: white)
#set text(24pt)


$
  mark(x, tag: #<1>, color: #green)
  + markhl(f(x), tag: #<2>, color: #purple, stroke: #1pt, radius: #10%)
  + markrect(e^x, tag: #<3>, color: #red, fill: #blue, outset: #.2em)
  + markul(x + 1, tag: #<4>, color: #gray, stroke: #2pt)

  #annot(<1>)[Annotation]
  #annot(<3>, pos: top)[Another annotation]
$
