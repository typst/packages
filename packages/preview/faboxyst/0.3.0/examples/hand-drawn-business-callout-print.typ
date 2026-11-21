// One monochrome print callout with genuine Arabic RTL copy.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 4.6cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)
#set text(lang: "ar", dir: rtl)

#print-group[
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
]
