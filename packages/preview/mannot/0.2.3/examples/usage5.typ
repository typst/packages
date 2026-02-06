#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 2cm, y: .5cm), fill: white)
#set text(24pt)


#v(3em)
$
  mark(x, tag: #<t1>, color: #purple)
  + markrect(2y, tag: #<t2>, color: #red, padding: #.2em)
  + markul(z+1, tag: #<t3>, stroke: #.1em)
  + marktc(C, tag: #<t4>, color: #olive)

  #annot(<t1>, pos: left)[Set pos \ to left.]
  #annot(<t2>, pos: top, yshift: 1em)[Set pos to top, and yshift to 1em.]
  #annot(<t3>, pos: right, yshift: 1em)[Set pos to right,\ and yshift to 1em.]
  #annot(<t4>, pos: top + left, yshift: 3em)[Set pos to top+left,\ and yshift to 3em.]
$
#v(2em)
