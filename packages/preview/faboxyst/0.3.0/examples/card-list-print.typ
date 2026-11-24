// Print examples — one layered card in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10.5cm, height: 11.5cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #card-list-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      icon: image("assets/card-list-briefcase-yellow.png", width: 1.65cm),
      print-icon: image("assets/card-list-briefcase-black.png", width: 1.65cm),
      width: 4.8cm,
      height: 6.8cm,
      direction: ltr,
      tilt: 12deg,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #card-list-box(
      title: [فكرة مميزة],
      body: [تعرض هذه البطاقة الفكرة بوضوح، وتترك مساحة لشرحها بإيجاز مع رمز بصري يرسخ معناها.],
      icon: image("assets/card-list-briefcase-cyan.png", width: 1.65cm),
      print-icon: image("assets/card-list-briefcase-black.png", width: 1.65cm),
      width: 4.8cm,
      height: 6.8cm,
      direction: rtl,
      tilt: 12deg,
    )
  ]
]
