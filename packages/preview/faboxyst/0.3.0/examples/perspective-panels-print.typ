// Grayscale print preview in LTR and RTL with three variable-width panels.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 9.0cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #perspective-panels(
      (
        (title: [Focus], number: [01], body: [Choose one priority and keep the message clear.], colour: rgb("#F4A51C")),
        (title: [Momentum], number: [02], body: [Track the key measures and share progress with the team.], colour: rgb("#E85A48")),
        (title: [Outcome], number: [03], body: [Connect the final result to the next decision.], colour: rgb("#43B9D3")),
      ),
      panel-widths: (2.8cm, 3.5cm, 2.8cm),
      gaps: (-0.16cm, -0.22cm),
      height: 6.25cm,
      direction: ltr,
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #perspective-panels(
      (
        (title: [الفكرة], number: [٠١], body: [حدّد الهدف بوضوح، وركّز على الأولوية الأهم.], colour: rgb("#3CB9D5")),
        (title: [الخطة], number: [٠٢], body: [قسّم العمل إلى خطوات عملية، ووزّع المسؤوليات.], colour: rgb("#F4C52E")),
        (title: [التنفيذ], number: [٠٣], body: [تابع التقدّم، وراجع النتائج بانتظام.], colour: rgb("#EE654D")),
      ),
      panel-widths: (2.9cm, 3.6cm, 2.9cm),
      gaps: (-0.12cm, -0.20cm),
      height: 6.25cm,
      direction: rtl,
    )
  ]
]
