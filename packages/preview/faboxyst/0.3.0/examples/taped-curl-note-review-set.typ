// Four pages: pastel LTR, pastel Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #taped-curl-note(
    body: [• You can replace this sample text.#linebreak()• Capture one useful idea.#linebreak()• Return to it when needed.],
    width: 5.9cm, height: 6.8cm,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #taped-curl-note(
    body: [• دوّن الفكرة المهمة.#linebreak()• أضف ملاحظة قصيرة.#linebreak()• عُد إليها عند الحاجة.],
    width: 5.9cm, height: 6.8cm, direction: rtl,
    paper: rgb("#F1DADD"), tape-colour: rgb("#D39299"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#print-group[
  #align(center + horizon)[
    #taped-curl-note(
      body: [• You can replace this sample text.#linebreak()• Capture one useful idea.#linebreak()• Return to it when needed.],
      width: 5.9cm, height: 6.8cm,
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #taped-curl-note(
      body: [• دوّن الفكرة المهمة.#linebreak()• أضف ملاحظة قصيرة.#linebreak()• عُد إليها عند الحاجة.],
      width: 5.9cm, height: 6.8cm, direction: rtl,
      paper: rgb("#F1DADD"), tape-colour: rgb("#D39299"),
    )
  ]
]
