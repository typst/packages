// One Folder Text Boxes component — dark-page RTL, with the source's vivid cards.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.8cm, margin: 0.4cm, fill: rgb("#002335"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

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
