// Four pages: color LTR, Arabic RTL dark, grayscale LTR, grayscale Arabic RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#FAFAFA"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #feature-callout-box(
    title: [Accelerate review],
    body: [Catch delays early and keep decisions moving with a quick daily check.],
    icon-style: 0, width: 7.6cm, size: 3.8cm,
    colour: rgb("#55C4DD"), label-position: "above",
  )
]
#pagebreak()
#set page(fill: rgb("#142B3A"))
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #feature-callout-box(
    title: [تسريع المراجعة],
    body: [اكتشف التأخير مبكرًا وحافظ على استمرار القرارات من خلال متابعة يومية سريعة.],
    icon-style: 1, width: 7.6cm, size: 3.8cm,
    colour: rgb("#197DBB"), title-colour: white, text-colour: white,
    label-position: "below", direction: rtl,
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #feature-callout-box(
      title: [Accelerate review],
      body: [Catch delays early and keep decisions moving with a quick daily check.],
      icon-style: 0, width: 7.6cm, size: 3.8cm,
      colour: rgb("#55C4DD"), label-position: "above",
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #feature-callout-box(
      title: [تسريع المراجعة],
      body: [اكتشف التأخير مبكرًا وحافظ على استمرار القرارات من خلال متابعة يومية سريعة.],
      icon-style: 1, width: 7.6cm, size: 3.8cm,
      colour: rgb("#197DBB"), label-position: "below", direction: rtl,
    )
  ]
]
