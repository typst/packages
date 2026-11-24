// Genuine Arabic RTL on a dark page; caption below and the pointer faces down.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: rgb("#142B3A"))
#set text(font: "DejaVu Sans", size: 9pt, lang: "ar", dir: rtl)
#show: faboxyst.with(theme: themes.notebook + (dir: rtl, lang: "ar"))

#align(center + horizon)[
  #feature-callout-box(
    title: [تسريع المراجعة],
    body: [اكتشف التأخير مبكرًا وحافظ على استمرار القرارات من خلال متابعة يومية سريعة.],
    icon-style: 1,
    width: 7.6cm,
    size: 3.8cm,
    colour: rgb("#197DBB"),
    title-colour: white,
    text-colour: white,
    label-position: "below",
    direction: rtl,
  )
]
