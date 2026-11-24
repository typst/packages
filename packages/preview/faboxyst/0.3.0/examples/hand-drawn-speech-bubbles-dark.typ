// Hand-drawn speech bubbles — dark slide, mirrored RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#032A3B"))
#set text(font: "DejaVu Sans", size: 8pt, fill: white)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[فقاعات مرسومة يدوياً — شريحة داكنة]
#v(1.70cm)
#hand-drawn-speech-bubbles(
  steps: (
    (kind: "quote", title: [اقتباس ملهم], body: [كلمات موجزة تترك أثراً واضحاً وتلخّص الفكرة الأساسية.]),
    (kind: "speech", title: [حوار مباشر], body: [اعرض الرسالة ببساطة، وشارك وجهة نظرك مع الآخرين.]),
    (kind: "thought", title: [فكرة جديدة], body: [اترك مساحة للتأمل، ودوّن الملاحظات التي تستحق المتابعة.]),
  ),
  width: 22cm,
  direction: rtl,
  dark: true,
)
