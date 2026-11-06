// One component per page: reference color, alternate icon, Arabic RTL, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 4.6cm, margin: 0.3cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #stacked-banner-row(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    width: 10.8cm, height: 1.55cm,
    colour: rgb("#E2B917"),
  )
]
#pagebreak()
#align(center + horizon)[
  #stacked-banner-row(
    title: [Important Notice],
    body: [A contrasting cyan accent and warning symbol demonstrate the built-in icon and color options on this standalone row.],
    width: 10.8cm, height: 1.55cm,
    colour: rgb("#079FC2"), icon-style: 1,
  )
]
#pagebreak()
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #stacked-banner-row(
    title: [ملخص الفكرة],
    body: [يعرض هذا الشريط فكرة موجزة مع رمز واضح وتفاصيل عملية تساعد القارئ على فهم المحتوى بسرعة.],
    width: 10.8cm, height: 1.55cm, direction: rtl,
    colour: rgb("#18A88F"), icon-style: 2,
  )
]
#pagebreak()
#set text(lang: "en", dir: ltr)
#print-group[
  #align(center + horizon)[
    #stacked-banner-row(
      title: [Print Preview],
      body: [Monochrome print retains the folded divider, icon block, title, body, and bottom accent in a compact single-row component.],
      width: 10.8cm, height: 1.55cm,
      colour: rgb("#F47712"), icon-style: 3,
    )
  ]
]
