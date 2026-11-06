// Three single-component checks: color LTR, genuine Arabic RTL, and print RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 4.6cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #hand-drawn-business-callout(
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.],
    width: 9cm,
    height: 2.1cm,
    icon-style: 0,
    colour: rgb("#EC4E60"),
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #hand-drawn-business-callout(
    body: [يساعد التواصل الواضح على تنسيق العمل، ومشاركة الأفكار، والوصول إلى نتيجة مشتركة.],
    width: 9cm,
    height: 2.1cm,
    icon-style: 1,
    colour: rgb("#F9B333"),
    direction: rtl,
  )
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #hand-drawn-business-callout(
      body: [يساعد التواصل الواضح على تنسيق العمل، ومشاركة الأفكار، والوصول إلى نتيجة مشتركة.],
      width: 9cm,
      height: 2.1cm,
      icon-style: 1,
      colour: rgb("#32AEDA"),
      direction: rtl,
    )
  ]
]
