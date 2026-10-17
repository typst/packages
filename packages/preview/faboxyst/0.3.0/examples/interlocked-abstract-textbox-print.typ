// Grayscale print preview with one box in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
