// Grayscale print preview: LTR and Arabic RTL versions of the single open card.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #folding-card-box(
      number: [01], title: [Target the next milestone],
      front-text: [Keep the next action visible while the team works toward the outcome.],
      body: [Bring the right people together, agree on a clear outcome, and make the next step easy to act on.],
      width: 7.8cm, colour: rgb("#079ED9"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #folding-card-box(
      number: [٠٢], title: [الخطوة التالية],
      front-text: [سجّل الإجراء الأساسي وتابع تقدّم الفريق نحو النتيجة المطلوبة.],
      body: [اجمع الفريق حول نتيجة واضحة، واتفقوا على إجراء عملي يقود إلى المرحلة التالية.],
      width: 7.8cm, colour: rgb("#F05A32"), direction: rtl,
    )
  ]
]
