// The rosette dedication ornaments: page frame and adaptive boxes.
#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", fill: rgb("#FBF7ED"))

// Page 1: the frame on every page, RTL dedication like the source sheet.
#show: rosette-pages.with(margin: 1.1cm)
#set text(lang: "ar", dir: rtl, font: "Amiri", size: 13pt, fill: rosette-ink)

#v(2.2cm)
#align(center, text(size: 30pt, weight: "bold")[إهداء])
#v(1.2cm)
#align(center)[إلى والديَّ العزيزين،]
#align(center)[إلى من كان دعاؤهما نورًا يرافق خطواتي،]
#align(center)[وحبّهما سندًا في كلّ مراحل حياتي.]
#v(6pt)
#align(center)[إلى عائلتي، موطن الأمان والطمأنينة،]
#align(center)[وأساتذتي الذين أناروا لي دروب المعرفة،]
#align(center)[وأصدقائي الذين شاركوني التعب والأمل.]

// Page 2: the same ornaments as content-adaptive boxes, LTR then RTL.
#pagebreak()
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
