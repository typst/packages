// Hand-drawn speech bubbles — monochrome print gallery, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.print)

= Hand-Drawn Speech Bubbles — print, LTR
#v(0.25cm)
#print-group[
  #hand-drawn-speech-bubbles(
    steps: (
      (kind: "quote", title: [Lorem Ipsum], body: [A memorable quotation, short enough to be easy to recall.]),
      (kind: "speech", title: [Dialogue], body: [A direct message, clear enough to invite a response.]),
      (kind: "thought", title: [New idea], body: [A useful reflection that opens a possibility.]),
    ),
    width: 22cm,
    direction: ltr,
  )
]

#v(0.30cm)
= Same bubbles — print, RTL
#v(0.25cm)
#print-group[
  #hand-drawn-speech-bubbles(
    steps: (
      (kind: "quote", title: [اقتباس], body: [كلمات موجزة تترك أثراً وتلخّص الفكرة الأساسية.]),
      (kind: "speech", title: [حوار], body: [اعرض الرسالة ببساطة وشارك وجهة نظرك.]),
      (kind: "thought", title: [فكرة], body: [تأمّل الملاحظات الجديدة وحدّد ما يستحق المتابعة.]),
    ),
    width: 22cm,
    direction: rtl,
  )
]
