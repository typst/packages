// Batch review: four individually rendered boxes in color, then grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Serif", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

// Style 57 — inclined outline and solid slanted icon panel.
#align(center + horizon)[
  #six-boxes-tilted-box(
    title: [Business], body: [Activity of making money by producing goods and services.],
    icon-style: 0, width: 7.4cm, badge-side: "left", colour: rgb("#F1840B"),
  )
]
#pagebreak()
// Style 58 — double-outline card and centered semicircular tab.
#align(center + horizon)[
  #six-boxes-folder-card(
    title: [Process], body: [A clear sequence of steps helps the team accomplish its goal.],
    icon-style: 1, width: 4.8cm, colour: rgb("#9E2737"),
  )
]
#pagebreak()
// Style 59 — offset horizontal band and circular icon badge.
#align(center + horizon)[
  #six-boxes-banded-box(
    title: [Target], body: [Know the audience and define the intended outcome.],
    icon-style: 2, width: 7.2cm, badge-side: "right", colour: rgb("#1E6685"),
  )
]
#pagebreak()
// Style 60 — square icon card with a top tab, bottom pointer, and caption.
#align(center + horizon)[
  #six-boxes-pointer-card(
    title: [Growth], body: [Expand an idea into lasting value.],
    icon-style: 3, width: 2.9cm, box-size: 1.78cm, colour: rgb("#43834A"),
  )
]
#set text(lang: "ar", dir: rtl)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #six-boxes-tilted-box(
      title: [الأعمال], body: [تساعد الأعمال المنظمة على تحقيق نتائج نافعة ومستدامة.],
      icon-style: 0, width: 7.4cm, badge-side: "start", direction: rtl,
      colour: rgb("#F1840B"),
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #six-boxes-folder-card(
      title: [العملية], body: [تساعد الخطوات الواضحة على إنجاز العمل وتحقيق الهدف.],
      icon-style: 1, width: 4.8cm, direction: rtl, colour: rgb("#9E2737"),
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #six-boxes-banded-box(
      title: [الهدف], body: [يساعد الهدف الواضح على اختيار الخطوة التالية بثقة.],
      icon-style: 2, width: 7.2cm, badge-side: "start", direction: rtl,
      colour: rgb("#1E6685"),
    )
  ]
]
#pagebreak()
#print-group[
  #align(center + horizon)[
    #six-boxes-pointer-card(
      title: [النموّ], body: [يساعد التطوير المستمر على تحويل الأفكار إلى قيمة نافعة.],
      icon-style: 3, width: 2.9cm, box-size: 1.78cm, direction: rtl,
      colour: rgb("#43834A"),
    )
  ]
]
