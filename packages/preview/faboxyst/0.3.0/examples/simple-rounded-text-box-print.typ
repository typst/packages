// Print examples — one rounded text box in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10.5cm, height: 8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #simple-rounded-text-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      icon: image("assets/simple-rounded-bike-white.png", width: 0.92cm),
      print-icon: image("assets/simple-rounded-bike-black.png", width: 0.92cm),
      width: 7.8cm,
      height: 5.2cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #simple-rounded-text-box(
      title: [فكرة واضحة],
      body: [نص موجز يشرح الفكرة ويدعمها بتفاصيل عملية، في مساحة مرتبة يسهل قراءتها وتخصيصها.],
      icon: image("assets/simple-rounded-bike-black.png", width: 0.92cm),
      print-icon: image("assets/simple-rounded-bike-black.png", width: 0.92cm),
      width: 7.8cm,
      height: 5.2cm,
      direction: rtl,
    )
  ]
]
