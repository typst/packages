#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 2cm, y: 1cm), fill: white)
#set text(24pt)

#show: mannot-init

$
  mark(1, tag: #<num>) / mark(x + 1, tag: #<den>, color: #blue)
  + mark(2, tag: #<quo>, color: #red)

  #annot(<num>, pos: top)[Numerator]
  #annot(<den>)[Denominator]
  #annot(<quo>, pos: right, yshift: 1em)[Quotient]
$
