// Grayscale print preview, with genuine Arabic RTL copy on page two.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#print-group[
  #align(center + horizon)[
    #pencil-sketch-box(
      title: [A useful idea],
      body: [Gather observations, sketch a direction, and refine the details together.],
      width: 7.2cm, height: 2.70cm, colour: rgb("#C99D20"),
    )
  ]
]
#pagebreak()
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #pencil-sketch-box(
      title: [فكرة مفيدة],
      body: [اجمع الملاحظات، وارسم اتجاهًا أوليًا، ثم حسّن التفاصيل مع الفريق.],
      width: 7.2cm, height: 2.70cm, direction: rtl,
      colour: rgb("#C99D20"),
    )
  ]
]
