// Review the shared 1/6 layout: yellow style 1, white style 6,
// Arabic RTL, and grayscale print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.5cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

// Reference style 1 baseline.
#align(center + horizon)[
  #kinds-text-box-1(
    number: [1],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.],
    width: 6.7cm,
    height: 6.9cm,
  )
]
#pagebreak()
// Reference style 6, same structure with the white/blue palette.
#align(center + horizon)[
  #kinds-text-box-1(
    number: [6],
    title: [YOUR TITLE],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.],
    width: 6.7cm,
    height: 6.9cm,
    colour: white,
    shadow-colour: rgb("#D8EAF5"),
    number-colour: rgb("#68A1D5"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #kinds-text-box-1(
    number: [6],
    title: [عنوان واضح],
    body: [نص موجز يشرح الفكرة السادسة ويعرض أهم تفاصيلها للقارئ بوضوح.],
    width: 6.7cm,
    height: 6.9cm,
    direction: rtl,
    colour: white,
    shadow-colour: rgb("#D8EAF5"),
    number-colour: rgb("#68A1D5"),
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #kinds-text-box-1(
      number: [6],
      title: [عنوان واضح],
      body: [نص موجز يشرح الفكرة السادسة ويعرض أهم تفاصيلها للقارئ بوضوح.],
      width: 6.7cm,
      height: 6.9cm,
      direction: rtl,
      colour: white,
      shadow-colour: rgb("#D8EAF5"),
      number-colour: rgb("#68A1D5"),
    )
  ]
]
