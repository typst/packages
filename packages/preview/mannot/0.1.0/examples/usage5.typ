#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 4cm, y: 1cm), fill: white)
#set text(24pt)

#show: mannot-init

#let rmark = mark.with(color: red)
#let gmark = mark.with(color: green)
#let bmark = mark.with(color: blue)

$
  integral_rmark(0, tag: #<i0>)^bmark(1, tag: #<i1>)
  mark(x^2 + 1, tag: #<i2>) dif gmark(x, tag: #<i3>)

  #annot(<i0>)[Begin]
  #annot(<i1>, pos: top)[End]
  #annot(<i2>, pos: top + right)[Integrand]
  #annot(<i3>, pos: right, yshift: .6em)[Variable]
$
