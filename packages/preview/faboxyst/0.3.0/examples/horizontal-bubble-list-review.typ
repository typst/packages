// Visual review: one Horizontal Bubble List box in light LTR, dark RTL, and print modes.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 12cm, margin: 0.25cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #horizontal-bubble-box(
    bubble-title: [Lorem Ipsum],
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    icon: image("assets/horizontal-bubble-puzzle-white.svg", width: 1.08cm),
    print-icon: image("assets/horizontal-bubble-puzzle-print.svg", width: 1.08cm),
    width: 4.4cm,
    height: 8.9cm,
    direction: ltr,
    colour: rgb("#4CC1EF"),
  )
]

#pagebreak()
#set page(fill: rgb("#001F33"))
#align(center + horizon)[
  #horizontal-bubble-box(
    bubble-title: [فكرة واضحة],
    title: [المعلومة],
    body: [يساعد هذا الإطار على تنظيم التفاصيل المهمة وعرضها بوضوح. ابدأ بالفكرة الأساسية، ثم أضف شرحاً موجزاً يدعم الرسالة ويقربها إلى القارئ. يمكن تخصيص النص والأيقونة واللون بما يتناسب مع موضوع العرض والجمهور المستهدف.],
    icon: image("assets/horizontal-bubble-key-white.svg", width: 1.08cm),
    print-icon: image("assets/horizontal-bubble-key-print.svg", width: 1.08cm),
    width: 4.4cm,
    height: 8.9cm,
    direction: rtl,
    colour: rgb("#3AC6E1"),
    bubble-title-colour: rgb("#0A3B48"),
    title-colour: white,
    text-colour: rgb("#F3F6F7"),
    bubble-title-size: 14pt,
    title-size: 13pt,
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #horizontal-bubble-box(
      bubble-title: [Lorem Ipsum],
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      icon: image("assets/horizontal-bubble-puzzle-white.svg", width: 1.08cm),
      print-icon: image("assets/horizontal-bubble-puzzle-print.svg", width: 1.08cm),
      width: 4.4cm,
      height: 8.9cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #horizontal-bubble-box(
      bubble-title: [فكرة واضحة],
      title: [المعلومة],
      body: [يساعد هذا الإطار على تنظيم التفاصيل المهمة وعرضها بوضوح. ابدأ بالفكرة الأساسية، ثم أضف شرحاً موجزاً يدعم الرسالة ويقربها إلى القارئ. يمكن تخصيص النص والأيقونة واللون بما يتناسب مع موضوع العرض والجمهور المستهدف.],
      icon: image("assets/horizontal-bubble-key-white.svg", width: 1.08cm),
      print-icon: image("assets/horizontal-bubble-key-print.svg", width: 1.08cm),
      width: 4.4cm,
      height: 8.9cm,
      direction: rtl,
      bubble-title-size: 14pt,
      title-size: 13pt,
    )
  ]
]
