// Three independent checks: color LTR, Arabic RTL, grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 16cm, margin: 0.45cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hand-drawn-business-brochure-card(
    width: 8.5cm,
    min-height: 12.4cm,
    title: [Lorem ipsum],
    photo-placeholder: [Your photo here],
    bullet-items: (
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
#pagebreak()
#print-group[
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
