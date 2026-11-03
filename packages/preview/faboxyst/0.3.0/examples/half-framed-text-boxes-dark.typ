// One Half-Framed Text Boxes component — dark-page RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9.5cm, height: 10.8cm, margin: 0.25cm, fill: rgb("#2C3440"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #half-framed-text-box(
    title: [رؤية واضحة],
    body: [تساعد هذه المساحة على عرض الفكرة بوضوح، وتنظيم المعلومات المهمة في بطاقة واحدة سهلة القراءة. يمكن تخصيص العنوان والأيقونة والألوان بما يلائم المحتوى والجمهور المستهدف، مع التركيز على النقاط الأساسية والرسالة التي تريد إيصالها.

استخدم الفقرة الثانية لإضافة شرح أو مثال مختصر، مع الحفاظ على تسلسل منطقي بين النقاط. يمكنك ذكر نتيجة أو توصية، وتوضيح السياق، وإبراز التفاصيل الضرورية من دون تشتيت القارئ بمعلومات جانبية.],
    icon: image("assets/half-framed-timer-blue.svg", width: 0.50cm),
    print-icon: image("assets/half-framed-timer-print.svg", width: 0.50cm),
    width: 5.2cm,
    height: 7.7cm,
    direction: rtl,
    colour: rgb("#4CC1EF"),
  )
]
