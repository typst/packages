// Check the generic fabox dog-ear shadow in colour, Arabic RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #fabox(
    title: [Folded note], width: 7.4cm, height: 3.6cm,
    colour: rgb("#D9A943"), frame: rgb("#594326"),
    back: rgb("#FCF6E8"), fold: true, fold-size: 0.82,
    shadow: "plain", shadow-colour: luma(105), rule-between: false,
  )[
    A folded corner should cast a soft edge-following shadow.
  ]
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #fabox(
    title: [ملاحظة مطوية], width: 7.4cm, height: 3.6cm,
    colour: rgb("#D9A943"), frame: rgb("#594326"),
    back: rgb("#FCF6E8"), fold: true, fold-size: 0.82,
    shadow: "plain", shadow-colour: luma(105), rule-between: false,
  )[
    ينبغي أن يتبع الظل حافة الطي بوضوح ونعومة.
  ]
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #fabox(
      title: [Folded note], width: 7.4cm, height: 3.6cm,
      colour: rgb("#D9A943"), frame: rgb("#594326"),
      back: rgb("#FCF6E8"), fold: true, fold-size: 0.82,
      shadow: "plain", shadow-colour: luma(105), rule-between: false,
    )[
      A folded corner should cast a soft edge-following shadow.
    ]
  ]
]
