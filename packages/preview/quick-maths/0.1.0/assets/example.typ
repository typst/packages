#import "../src/lib.typ": shorthands

#set text(size: 14pt)
#set page(
  width: 8cm,
  height: auto,
  margin: 1em,
  background: box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
  ),
)

#show: shorthands.with(
  ($+-$, $plus.minus$),
  ($|-$, $tack$),
  ($<=$, math.arrow.l.double) // Replaces '≤'
)

$ x^2 = 9 quad <==> quad x = +-3 $
$ A or B |- A $
$ x <= y $
