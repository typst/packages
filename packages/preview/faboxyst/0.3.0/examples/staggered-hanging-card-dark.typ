// One Staggered Hanging Card — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 10cm, margin: 0.3cm, fill: rgb("#001624"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #staggered-hanging-card-box(
    title: [فكرة واضحة],
    body: [تعرض هذه البطاقة فكرة واحدة بشكل واضح، مع تفاصيل موجزة تساعد على فهمها وتذكرها. يمكن تخصيص العنوان والنص بما يناسب موضوع العرض.],
    clip: image("assets/staggered-binder-clip.svg", width: 0.56cm),
    print-clip: image("assets/staggered-binder-clip.svg", width: 0.56cm),
    width: 5.4cm,
    height: 6.3cm,
    direction: rtl,
    card-colour: rgb("#F2B741"),
    title-colour: rgb("#191919"),
    text-colour: rgb("#191919"),
  )
]
