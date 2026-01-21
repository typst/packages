#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 4cm, y: 1cm), fill: white)
#set text(24pt)

#show: mannot-init

$
  mark(integral x dif x, tag: #<i>, color: #green)
  + mark(3, tag: #<3>, color: #red) mark(x, tag: #<x>, color: #blue)

  #annot(<i>, pos: left)[Set pos to left.]
  #annot(<i>, pos: top + left)[Top left.]
  #annot(<3>, pos: top, yshift: 1.2em)[Use yshift.]
  #annot(<x>, pos: right, yshift: 1.2em)[Auto arrow.]
$
