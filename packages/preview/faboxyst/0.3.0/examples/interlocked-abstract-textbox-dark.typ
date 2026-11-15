// One mirrored RTL textbox on a dark page, with an alternate cyan banner.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 12.5cm, margin: 0.35cm, fill: rgb("#172833"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #interlocked-abstract-textbox(
    title: [الأفكار المترابطة],
    body: [تساعد هذه البطاقة على عرض فكرة رئيسية بوضوح. أضيفوا التفاصيل الضرورية، ثم اربطوا النقاط بالخطوة التالية.

استخدموا المساحة لشرح السياق والنتيجة المتوقعة، مع الحفاظ على تسلسل منطقي وسهل القراءة.],
    colour: rgb("#39BCE2"),
    direction: rtl,
  )
]
