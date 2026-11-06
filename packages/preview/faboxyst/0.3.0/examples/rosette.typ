// The rosette dedication ornaments as adaptive boxes.
#import "@preview/faboxyst:0.3.0": *

#set page(paper: "a4", fill: rgb("#FBF7ED"))

// The ornaments as content-adaptive boxes, LTR then RTL.
#set text(lang: "fr", dir: ltr, font: "Libertinus Serif", size: 10pt)
#rosettebox(title: [Avis important])[
  Les ornements du cadre s'adaptent à la taille de ce contenu : coins,
  rangs de losanges et médaillons suivent l'échelle calculée.
]
#v(8pt)
#text(lang: "ar", dir: rtl)[#rosettebox(title: [بطاقة])[
  الإطار يتكيّف مع محتواه: يتقلّص الزخرف حين تضيق المسافة.
]]
#v(8pt)
#rosettebox(
  title: [Version épurée],
  diamonds: none,
  medallions: false,
  ink: rgb("#4A3B8C"),
  gold: rgb("#8C7A4A"),
)[Sans losanges ni médaillons, encres personnalisées.]
