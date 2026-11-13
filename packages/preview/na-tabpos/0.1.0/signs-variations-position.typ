// إشارة المشتقة ثم التغيّرات ثم الفرق ثم الوضع النسبي في جدول واحد
// Derivative sign, variations, difference and relative position in one table
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 16pt)
#set page(width: 20cm, height: auto, margin: 1cm)

#tabpos(
  variable: $x$,
  label: (
    ([$f'(x)$], "s"),
    ([$f(x)$], "v"),
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $0$, $+oo$),
  contents: (
    ($-$, ("||", $-$)),
    (
      (center, $0$),
      (bottom, top, "||", $-oo$, $+oo$),
      (center, $0$),
    ),
    ($+$, ("||", $-$)),
    ("+", ("||", "-")),
  ),
)
