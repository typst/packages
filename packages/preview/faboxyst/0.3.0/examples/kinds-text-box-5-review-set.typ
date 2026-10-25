// Review the shared 2/5 layout: original style 2, style-5 palette preset,
// genuine Arabic RTL, and grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 7cm, height: 9cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

// Reference style 2 baseline.
#align(center + horizon)[
  #kinds-text-box-2(
    number: [2],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
    width: 3.9cm,
    height: 7.2cm,
  )
]
#pagebreak()
// Reference style 5, using the same reusable component with another palette.
#align(center + horizon)[
  #kinds-text-box-2(
    number: [5],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.],
    width: 3.9cm,
    height: 7.2cm,
    colour: rgb("#A9D8F4"),
    shadow-colour: rgb("#8FC3E6"),
    number-colour: rgb("#FFE86D"),
    number-size: 29pt,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #kinds-text-box-2(
    number: [5],
    title: [عنوان واضح],
    body: [نص موجز يشرح الفكرة الخامسة ويعرض أهم تفاصيلها للقارئ بوضوح.],
    width: 3.9cm,
    height: 7.2cm,
    direction: rtl,
    colour: rgb("#A9D8F4"),
    shadow-colour: rgb("#8FC3E6"),
    number-colour: rgb("#FFE86D"),
    number-size: 29pt,
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #kinds-text-box-2(
      number: [5],
      title: [عنوان واضح],
      body: [نص موجز يشرح الفكرة الخامسة ويعرض أهم تفاصيلها للقارئ بوضوح.],
      width: 3.9cm,
      height: 7.2cm,
      direction: rtl,
      colour: rgb("#A9D8F4"),
      shadow-colour: rgb("#8FC3E6"),
      number-colour: rgb("#FFE86D"),
      number-size: 29pt,
    )
  ]
]
