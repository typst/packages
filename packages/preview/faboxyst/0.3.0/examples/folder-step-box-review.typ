// Visual review: one layered folder box per page, not the source's three-card row.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 5.8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #folder-step-box(
    title: [Plan the Work],
    body: [Capture the key actions, owners, and timing in one easy-to-scan folder.],
    icon: image("assets/folder-step-clipboard-navy.svg", width: 0.62cm),
    print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
    number: [01],
    width: 5.9cm,
    front-height: 3.3cm,
    folder-height: 2.55cm,
    direction: ltr,
    colour: rgb("#78AA78"),
  )
]

#pagebreak()
#set page(fill: rgb("#002335"))
#align(center + horizon)[
  #folder-step-box(
    title: [تنظيم العمل],
    body: [اجمع المهام والمسؤوليات والمواعيد في صندوق واحد يسهل الرجوع إليه.],
    icon: image("assets/folder-step-clipboard-white.svg", width: 0.62cm),
    print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
    number: [01],
    width: 5.9cm,
    front-height: 3.3cm,
    folder-height: 2.55cm,
    direction: rtl,
    dark: true,
    colour: rgb("#27B9C9"),
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #folder-step-box(
      title: [Plan the Work],
      body: [Capture the key actions, owners, and timing in one easy-to-scan folder.],
      icon: image("assets/folder-step-clipboard-navy.svg", width: 0.62cm),
      print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
      number: [01],
      width: 5.9cm,
      front-height: 3.3cm,
      folder-height: 2.55cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #folder-step-box(
      title: [تنظيم العمل],
      body: [اجمع المهام والمسؤوليات والمواعيد في صندوق واحد يسهل الرجوع إليه.],
      icon: image("assets/folder-step-clipboard-white.svg", width: 0.62cm),
      print-icon: image("assets/folder-step-clipboard-black.svg", width: 0.62cm),
      number: [01],
      width: 5.9cm,
      front-height: 3.3cm,
      folder-height: 2.55cm,
      direction: rtl,
    )
  ]
]
