// Three independent checks: color LTR, Arabic RTL, and grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hand-drawn-photo-frame(
    width: 7.4cm,
    height: 5.2cm,
    placeholder: [Your photo here],
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #hand-drawn-photo-frame(
    width: 7.4cm,
    height: 5.2cm,
    direction: rtl,
    placeholder: [مكان صورتك],
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #hand-drawn-photo-frame(
      width: 7.4cm,
      height: 5.2cm,
      direction: rtl,
      placeholder: [مكان صورتك],
    )
  ]
]
