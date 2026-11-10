// One standalone display card per page: orange, cyan, Arabic RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 6cm, height: 7.7cm, margin: 0.4cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #text-box-display-card(
    title: [LOREM IPSUM],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor.],
    width: 4.8cm, height: 6.8cm, colour: rgb("#F68C1F"), icon-style: 0,
  )
]
#pagebreak()
#align(center + horizon)[
  #text-box-display-card(
    title: [SKIING],
    body: [A cool blue card with a built-in winter-sport pictogram and a sculpted, contrasting footer banner.],
    width: 4.8cm, height: 6.8cm, colour: rgb("#42BCE2"), icon-style: 1,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #text-box-display-card(
    title: [تمرين اليوغا],
    body: [تجمع هذه البطاقة بين رمز واضح ونص موجز، مع اتجاه عربي ومحاذاة مناسبة داخل مساحة مستقلة قابلة لإعادة الاستخدام.],
    width: 4.8cm, height: 6.8cm, direction: rtl,
    colour: rgb("#C9361F"), text-colour: white, icon-style: 2,
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #text-box-display-card(
      title: [PRINT SAMPLE],
      body: [Monochrome output preserves the raised icon tile, card silhouette, and layered footer banner.],
      width: 4.8cm, height: 6.8cm, icon-style: 3,
    )
  ]
]
