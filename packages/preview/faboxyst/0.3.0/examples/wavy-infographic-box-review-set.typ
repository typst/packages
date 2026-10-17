// Four pages: color LTR, dark Arabic RTL, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#FAFAFA"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #wavy-infographic-box(
    title: [Idea flow],
    body: [Connect useful details in one lively card. A clear wave silhouette and icon badge help the key message stand out.],
    icon-style: 1, width: 6.2cm, height: 5.45cm,
    colour: rgb("#F49A24"),
  )
]
#pagebreak()
#set page(fill: rgb("#142B3A"))
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #wavy-infographic-box(
    title: [أفكار تنساب بوضوح],
    body: [اجمع التفاصيل المهمة في بطاقة حيوية. يساعد الشكل المتموج والأيقونة الواضحة على إبراز الفكرة الأساسية.],
    icon-style: 3, width: 6.2cm, height: 5.45cm,
    colour: rgb("#118A9A"), title-colour: white, text-colour: white,
    direction: rtl,
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #wavy-infographic-box(
      title: [Idea flow],
      body: [Connect useful details in one lively card. A clear wave silhouette and icon badge help the key message stand out.],
      icon-style: 1, width: 6.2cm, height: 5.45cm,
      colour: rgb("#F49A24"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #wavy-infographic-box(
      title: [أفكار تنساب بوضوح],
      body: [اجمع التفاصيل المهمة في بطاقة حيوية. يساعد الشكل المتموج والأيقونة الواضحة على إبراز الفكرة الأساسية.],
      icon-style: 3, width: 6.2cm, height: 5.45cm,
      colour: rgb("#118A9A"), direction: rtl,
    )
  ]
]
