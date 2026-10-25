// Monochrome print variants — a single half-framed box in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9.5cm, height: 10.8cm, margin: 0.25cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #half-framed-text-box(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.],
      icon: image("assets/half-framed-target-yellow.svg", width: 0.50cm),
      print-icon: image("assets/half-framed-target-print.svg", width: 0.50cm),
      width: 5.2cm,
      height: 7.7cm,
      direction: ltr,
    )
  ]
]

#pagebreak()

#print-group[
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
    )
  ]
]
