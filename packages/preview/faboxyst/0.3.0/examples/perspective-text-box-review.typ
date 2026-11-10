// Visual review: one perspective panel per page, no multi-box progression.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6.2cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #perspective-text-box(
    title: [Importance in Context],
    body: [Show one important fact clearly. The angled face and shaded edge give the content a little depth without crowding the message.],
    icon: image("assets/perspective-target-black.svg", width: 0.76cm),
    print-icon: image("assets/perspective-target-black.svg", width: 0.76cm),
    width: 6.8cm,
    height: 3.85cm,
    direction: ltr,
    colour: rgb("#53BCE4"),
  )
]

#pagebreak()
#set page(fill: rgb("#20242A"))
#align(center + horizon)[
  #perspective-text-box(
    title: [أهمية الفكرة],
    body: [اعرض حقيقة مهمة بوضوح. يمنح السطح المائل والحافة المظللة المحتوى عمقاً بسيطاً دون تشتيت الرسالة.],
    icon: image("assets/perspective-target-white.svg", width: 0.76cm),
    print-icon: image("assets/perspective-target-black.svg", width: 0.76cm),
    width: 6.8cm,
    height: 3.85cm,
    direction: rtl,
    dark: true,
    colour: rgb("#2A648D"),
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #perspective-text-box(
      title: [Importance in Context],
      body: [Show one important fact clearly. The angled face and shaded edge give the content a little depth without crowding the message.],
      icon: image("assets/perspective-target-black.svg", width: 0.76cm),
      print-icon: image("assets/perspective-target-black.svg", width: 0.76cm),
      width: 6.8cm,
      height: 3.85cm,
      direction: ltr,
      colour: rgb("#53BCE4"),
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #perspective-text-box(
      title: [أهمية الفكرة],
      body: [اعرض حقيقة مهمة بوضوح. يمنح السطح المائل والحافة المظللة المحتوى عمقاً بسيطاً دون تشتيت الرسالة.],
      icon: image("assets/perspective-target-black.svg", width: 0.76cm),
      print-icon: image("assets/perspective-target-black.svg", width: 0.76cm),
      width: 6.8cm,
      height: 3.85cm,
      direction: rtl,
      colour: rgb("#53BCE4"),
    )
  ]
]
