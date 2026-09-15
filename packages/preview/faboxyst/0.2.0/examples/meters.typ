// ===========================================================================
//  examples/meters.typ — the little difficulty meters of faboxyst.
//
//    typst compile examples/meters.typ --root .
//
//  Four instruments, one API: a speedometer gauge, a thermometer, a phone
//  battery and signal bars. They are inline boxes, so they sit beside an
//  exercise statement or inside a table cell. The colour ramps green to
//  red on its own (a battery ramps the other way: empty is the alarm).
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(width: 16cm, height: 22cm, margin: 1.2cm)

= The four instruments

#grid(columns: (auto, auto, auto, auto, auto), column-gutter: 0.45cm,
  align: center,
  meter(3, style: "gauge"),
  meter(3, style: "thermo"),
  meter(3, style: "battery"),
  meter(3, style: "wifi", size: 1.1cm),
  meter(4, style: "cible", size: 1.1cm),
)

#v(0.3cm)
The same reading, 1 to 5 on the gauge, and the ramp that follows it:

#grid(columns: (auto, auto, auto, auto, auto), column-gutter: 0.5cm,
  align: center,
  ..range(1, 6).map(i => meter(i, style: "gauge", size: 1.2cm)),
)

= Beside an exercise

#let exo(n, diff, body) = block(width: 100%, inset: 0.35cm,
  stroke: (left: 2pt + luma(75)),
  [#text(weight: "bold")[Exercice #n] #h(0.4cm) #difficulty(diff, size: 1.1cm) #h(0.5fr) #body])

#exo(1, 1)[Développer $(x+1)^2$.]
#v(0.15cm)
#exo(2, 3)[Résoudre $x^2 - 5x + 6 = 0$.]
#v(0.15cm)
#exo(3, 5)[Montrer que $sum_(k=1)^n k^3 = (n(n+1)/2)^2$.]

= Styles and overrides

A fixed colour, a custom label, a bigger size:

#meter(4, style: "thermo", colour: rgb("#7209B7"), label: [chaud !])
#h(0.5cm)
#meter(2, style: "battery", size: 2.4cm, label: [2/5 charges])
#h(0.5cm)
#meter(4, style: "bars", track: luma(88))

= En RTL, miroir

#set text(dir: rtl, lang: "ar")

المقاييس تنقلب مع الاتجاه: عمود البطارية وعلامات الترمومتر وصف الأعمدة:

#v(0.3cm)
#grid(columns: (auto, auto, auto, auto), column-gutter: 0.7cm,
  align: center,
  meter(4, style: "gauge"),
  meter(4, style: "thermo"),
  meter(1, style: "battery"),
  meter(4, style: "bars"),
)

#v(0.3cm)
صعوبة التمرين بجانب نصه: #difficulty(4, size: 1.1cm) ثم نص عربي يجري من اليمين.
