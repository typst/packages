// Three independent checks: color LTR, Arabic RTL, and grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hand-drawn-bullet-panel(
    width: 8.2cm,
    grayscale: false,
    items: (
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
      [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.],
    ),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #hand-drawn-bullet-panel(
    width: 8.2cm,
    direction: rtl,
    grayscale: false,
    items: (
      [هذا نص موجز يشرح المعلومة الأولى.],
      [هذا نص موجز يشرح المعلومة الثانية.],
      [هذا نص موجز يشرح المعلومة الثالثة.],
      [هذا نص موجز يشرح المعلومة الرابعة.],
    ),
  )
]
#pagebreak()
#align(center + horizon)[
  #hand-drawn-bullet-panel(
    width: 8.2cm,
    direction: rtl,
    grayscale: true,
    colour: luma(224),
    stroke-colour: luma(52),
    text-colour: luma(35),
    bullet-colour: luma(26),
    items: (
      [هذا نص موجز يشرح المعلومة الأولى.],
      [هذا نص موجز يشرح المعلومة الثانية.],
      [هذا نص موجز يشرح المعلومة الثالثة.],
      [هذا نص موجز يشرح المعلومة الرابعة.],
    ),
  )
]
