#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 4cm, y: 1cm), fill: white)
#set text(24pt)


$
  mark(x, tag: #<t1>, color: #purple)
  + markrect(2y, tag: #<t2>, color: #red, padding: #.2em)
  + markul(z+1, tag: #<t3>, stroke: #.1em)
  + marktc(C, tag: #<t4>, color: #olive)

  #annot(<t1>)[annotation]
  #annot(<t4>)[another annotation]
$

