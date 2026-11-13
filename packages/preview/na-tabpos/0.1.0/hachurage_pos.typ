// اختبار التهشير والأشرطة في سطر الوضع النسبي
// Test of hatching and bars in the "p" row
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 14pt)
#set page(width: 20cm, height: auto, margin: 1cm)

== "h|" في البداية / hatched at the start
#tabpos(
  variable: $x$, hatching-style: hatch,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $0$, $2$, $+oo$),
  contents: (
    ("h|", $-$, ("0", $+$)),
    ("h|", "-", ($A(2 ; 0)$, "+")),
  ),
)

== "|h" في النهاية / hatched at the end
#tabpos(
  variable: $x$, hatching-style: hatch,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $0$, $2$, $+oo$),
  contents: (
    ($+$, ("0", $-$), "|h"),
    ("+", ($A(0 ; 0)$, "-"), "|h"),
  ),
)

== قيمة ممنوعة / forbidden value ("||")
#tabpos(
  variable: $x$,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $1$, $+oo$),
  contents: (($-$, ("||", $+$)), ("-", ("||", "+"))),
)
