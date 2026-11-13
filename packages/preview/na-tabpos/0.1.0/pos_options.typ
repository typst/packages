// اختبار خيارات سطر الوضع النسبي : pos-height, arc-width, الكلمات
// Test of the "p" row options: pos-height, arc-width, words
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 14pt)
#set page(width: 20cm, height: auto, margin: 1cm)

#let body = (
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)

== pos-height: 2cm
#tabpos(variable: $x$, pos-height: 2cm, ..body)

== arc-width: 0.6
#tabpos(variable: $x$, arc-width: 0.6, ..body)

== second: $(Delta)$ ، above / below / cross / at-point (English)
#set text(lang: "en")
#tabpos(
  variable: $x$,
  second: $(Delta)$,
  above: [above], below: [below], cross: [crosses], at-point: [at the point],
  ..body,
)
