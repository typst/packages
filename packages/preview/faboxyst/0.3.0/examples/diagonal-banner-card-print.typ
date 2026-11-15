// Print versions — one diagonal banner card in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9.5cm, margin: 0.3cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #diagonal-banner-card-box(
      title: [Lorem Ipsum],
      items: (
        [Lorem ipsum dolor sit amet, consectetur adipiscing elit.],
        [Nibh est vel auctor, convallis ornare. A magna maecenas.],
        [Suspendisse viverra sodales mauris in.],
      ),
      number: "01",
      icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
      print-icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
      width: 4.8cm,
      height: 6.8cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #diagonal-banner-card-box(
      title: [فكرة واضحة],
      items: (
        [نقطة أساسية تساعد على فهم الفكرة.],
        [تفصيل موجز يدعم السياق ويوضح الهدف.],
        [خطوة تالية قابلة للتنفيذ والقياس.],
      ),
      number: "٠١",
      icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
      print-icon: image("assets/diagonal-banner-rocket-black.png", width: 0.78cm),
      width: 4.8cm,
      height: 6.8cm,
      direction: rtl,
    )
  ]
]
