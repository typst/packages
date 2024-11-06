#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 2cm, y: .5cm), fill: white)
#set text(24pt)

#show: mannot-init

$ // Need # before color names.
mark(3, color: #red) mark(x, color: #blue)
+ mark(integral x dif x, color: #green)
$
