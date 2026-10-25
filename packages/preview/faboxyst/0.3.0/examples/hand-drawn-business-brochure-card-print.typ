// One grayscale print portrait card with Arabic RTL content.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 16cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.print)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #hand-drawn-business-brochure-card(
    width: 8.5cm,
    min-height: 12.4cm,
    direction: rtl,
    title: [عنوان المنشور],
    photo-placeholder: [مكان صورتك],
    bullet-items: (
      [هذا نص موجز يشرح المعلومة الأولى.],
      [هذا نص موجز يشرح المعلومة الثانية.],
      [هذا نص موجز يشرح المعلومة الثالثة.],
      [هذا نص موجز يشرح المعلومة الرابعة.],
    ),
  )
]
