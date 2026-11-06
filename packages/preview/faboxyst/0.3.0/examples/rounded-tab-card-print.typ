// Print preview: one box per page in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9cm, height: 9cm, margin: 0.3cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

// print-group pages are emitted in reverse order; author RTL first so the
// exported PDF reads LTR, then RTL.
#print-group[
  #align(center + horizon)[
    #rounded-tab-card-box(
      title: [فكرة واضحة],
      body: [تجمع الفكرة الواضحة التفاصيل المهمة حول هدف واحد، وتساعد الفريق على فهم الأولويات واختيار الخطوة التالية.],
      icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
      print-icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
      width: 6cm,
      body-height: 4.8cm,
      direction: rtl,
    )
  ]
]

#pagebreak()

#print-group[
  #align(center + horizon)[
    #rounded-tab-card-box(
      title: [Bright Idea],
      body: [A clear idea brings the important details into focus and gives a team a practical next step to follow.],
      icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
      print-icon: image("assets/rounded-tab-lightbulb.svg", width: 0.62cm),
      width: 6cm,
      body-height: 4.8cm,
      direction: ltr,
    )
  ]
]
