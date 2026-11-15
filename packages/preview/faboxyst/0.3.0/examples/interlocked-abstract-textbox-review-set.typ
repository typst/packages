// Four-page review: color LTR, dark RTL, grayscale print LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #interlocked-abstract-textbox(
    title: [LOREM IPSUM],
    body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat.],
    colour: rgb("#E44724"),
    direction: ltr,
  )
]
#pagebreak()
#set page(fill: rgb("#172833"))
#align(center + horizon)[
  #interlocked-abstract-textbox(
    title: [الأفكار المترابطة],
    body: [تساعد هذه البطاقة على عرض فكرة رئيسية بوضوح. أضيفوا التفاصيل الضرورية، ثم اربطوا النقاط بالخطوة التالية.

استخدموا المساحة لشرح السياق والنتيجة المتوقعة، مع الحفاظ على تسلسل منطقي وسهل القراءة.],
    colour: rgb("#39BCE2"),
    direction: rtl,
  )
]
#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #interlocked-abstract-textbox(
      title: [LOREM IPSUM],
      body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat.],
      colour: rgb("#E44724"),
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #interlocked-abstract-textbox(
      title: [الأفكار المترابطة],
      body: [تساعد هذه البطاقة على عرض فكرة رئيسية بوضوح. أضيفوا التفاصيل الضرورية، ثم اربطوا النقاط بالخطوة التالية.

استخدموا المساحة لشرح السياق والنتيجة المتوقعة، مع الحفاظ على تسلسل منطقي وسهل القراءة.],
      colour: rgb("#39BCE2"),
      direction: rtl,
    )
  ]
]
