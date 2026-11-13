// اختبار ارتفاع سطر الفرق : 1 سم افتراضيًا
// Test of the difference-row height: 1 cm by default
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 14pt)
#set page(width: 20cm, height: auto, margin: 1cm)

#let t(..opts) = tabpos(
  variable: $x$,
  ..opts,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $0$, $+oo$),
  contents: (($-$, ("0", $+$)), ("-", ("0", "+"))),
)

== الافتراضي (1cm) / default (1cm)
#t()

== diff-height: 0.5cm
#t(diff-height: 0.5cm)

== diff-height: 2cm
#t(diff-height: 2cm)

== diff-height: none (ارتفاع تلقائي / automatic)
#t(diff-height: none)

== ارتفاع مكتوب في السطر نفسه له الأولوية / height written in the row has priority (1.5cm)
#tabpos(
  variable: $x$,
  label: (([$f(x) - y$], 1.5cm, "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $0$, $+oo$),
  contents: (($-$, ("0", $+$)), ("-", ("0", "+"))),
)
