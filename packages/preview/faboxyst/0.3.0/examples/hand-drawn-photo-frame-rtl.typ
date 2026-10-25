// One hand-drawn photo frame with genuine Arabic RTL placeholder text.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#align(center + horizon)[
  #hand-drawn-photo-frame(
    width: 7.4cm,
    height: 5.2cm,
    direction: rtl,
    placeholder: [مكان صورتك],
  )
]
