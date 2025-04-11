#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: 1cm, fill: white)
#set text(24pt)

Text text text text text:
#v(1em)
$
  mark(x, tag: #<1>, color: #green)
  #annot(<1>, pos: top + right)[Annotation]
  #annot(<1>, dy: 1em)[Annotation]
$
#v(2em)
text text text text text.
