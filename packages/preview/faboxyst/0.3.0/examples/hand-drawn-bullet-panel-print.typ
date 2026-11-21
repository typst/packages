// One grayscale print panel with Arabic RTL list items.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #hand-drawn-bullet-panel(
    width: 8.2cm,
    direction: rtl,
    grayscale: true,
    items: (
      [هذا نص موجز يشرح المعلومة الأولى.],
      [هذا نص موجز يشرح المعلومة الثانية.],
      [هذا نص موجز يشرح المعلومة الثالثة.],
      [هذا نص موجز يشرح المعلومة الرابعة.],
    ),
  )
]
