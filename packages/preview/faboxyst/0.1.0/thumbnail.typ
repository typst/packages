#import "/lib.typ": *
#set page(width: 12.4cm, height: auto, margin: 5.5mm, fill: rgb("#FAFBFC"))
#set text(font: "DejaVu Sans", size: 8.6pt)
#show: faboxyst.with(theme: themes.notebook)

#grid(columns: (1fr, 1fr), gutter: 3.6mm, row-gutter: 3.4mm,
  fabox(title: [Note], width: 100%)[A titled coloured box.],
  {
    numbox-reset()
    numbox[A one-line question.]
  },
  ribbonbox(title: [Example], width: 100%)[Yellow plate, blue band.],
  chalkbox(title: [Lemma], width: 100%)[$ a^2 + b^2 = c^2 $],
  sashbox([Hello World!],kind: "arch", incline: 0.15), 
  screwbox([$ a^2+b^2=c^2 $], angle: 35deg)

)
