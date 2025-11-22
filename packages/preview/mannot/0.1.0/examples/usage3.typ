#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 2cm, y: 1cm), fill: white)
#set text(24pt)

#show: mannot-init

$
  mark(x, tag: #<x>)  // Need # before tags.
  #annot(<x>)[Annotation]
$
