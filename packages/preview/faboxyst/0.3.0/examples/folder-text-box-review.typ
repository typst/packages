// Visual review of one Folder Text Boxes card: LTR, RTL dark, and monochrome print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.8cm, margin: 0.4cm, fill: rgb("#F1EFEF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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

#pagebreak()
#set page(fill: rgb("#002335"))
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
    dark: true,
    colour: rgb("#4BBCE5"),
  )
]

#pagebreak()
#set page(fill: white)
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
    )
  ]
]
