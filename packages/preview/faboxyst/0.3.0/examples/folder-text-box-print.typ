// Monochrome print variants — a single folder box in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #folder-text-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      icon: image("assets/folder-text-box-bulb-brown.svg", width: 1.30cm),
      print-icon: image("assets/folder-text-box-bulb-black.svg", width: 1.30cm),
      number: [01],
      width: 7cm,
      height: 5.42cm,
      direction: ltr,
      colour: rgb("#F7931E"),
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #folder-text-box(
      title: [لوريم إيبسوم],
      body: [نص موجز يشرح الفكرة بوضوح، مع مساحة لأهم التفاصيل وأيقونة تساعد على تمييز هذا المربع.],
      icon: image("assets/folder-text-box-target-teal.svg", width: 1.30cm),
      print-icon: image("assets/folder-text-box-target-black.svg", width: 1.30cm),
      number: [02],
      width: 7cm,
      height: 5.42cm,
      direction: rtl,
      colour: rgb("#4BBCE5"),
    )
  ]
]
