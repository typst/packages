// D_f = ]-oo ; -2[ U ]2 ; +oo[  : جزء محذوف من الوسط بتهشير
// A hatched gap in the middle of the domain
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 16pt)
#set page(width: 20cm, height: auto, margin: 1cm)

#tabpos(
  variable: $x$,
  hatching-style: hatch,
  label: (
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-2$, $2$, $+oo$),
  contents: (
    ($-$, "|h|", $+$),
    ("-", "|h|", "+"),
  ),
)
