// Combined review of the shared wide component: centered/lower number,
// Arabic RTL, and grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 8cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

// Variant 3: number vertically centered, blue panel, yellow numeral.
#align(center + horizon)[
  #kinds-text-box-3(
    number: [3],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
    width: 8.8cm,
    height: 6.2cm,
  )
]
#pagebreak()
// Variant 4 appearance: same component, lower numeral and alternate palette.
#align(center + horizon)[
  #kinds-text-box-3(
    number: [4],
    number-position: "lower",
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
    width: 8.8cm,
    height: 6.2cm,
    colour: rgb("#FFF0A6"),
    shadow-colour: rgb("#F0E38B"),
    number-colour: rgb("#68A1D5"),
  )
]
#pagebreak()
// Mirror the lower-number layout for genuine Arabic RTL.
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #kinds-text-box-3(
    number: [4],
    number-position: "lower",
    title: [عنوان واضح],
    body: [هذا نص توضيحي للفكرة الرابعة. يشرح التفاصيل المهمة ويقدم معلومات مفيدة تساعد القارئ على فهم الموضوع بسهولة.],
    width: 8.8cm,
    height: 6.2cm,
    direction: rtl,
    colour: rgb("#FFF0A6"),
    shadow-colour: rgb("#F0E38B"),
    number-colour: rgb("#68A1D5"),
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #kinds-text-box-3(
      number: [4],
      number-position: "lower",
      title: [عنوان واضح],
      body: [هذا نص توضيحي للفكرة الرابعة. يشرح التفاصيل المهمة ويقدم معلومات مفيدة تساعد القارئ على فهم الموضوع بسهولة.],
      width: 8.8cm,
      height: 6.2cm,
      direction: rtl,
      colour: rgb("#FFF0A6"),
      shadow-colour: rgb("#F0E38B"),
      number-colour: rgb("#68A1D5"),
    )
  ]
]
