// Monochrome print variants — one bubble box in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 12cm, margin: 0.25cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
