// Visual review of one faithfully proportioned Folder Text Blocks card: LTR, RTL dark, and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.2cm, margin: 0.4cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #folder-text-block(
    title: [Lorem Ipsum],
    body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
    icon: image("assets/folder-text-block-burger-brown.svg", width: 1.60cm),
    print-icon: image("assets/folder-text-block-burger-black.svg", width: 1.60cm),
    number: [1],
    width: 7cm,
    height: 4.55cm,
    direction: ltr,
    colour: rgb("#F6A51A"),
  )
]

#pagebreak()
#set page(fill: rgb("#002335"))
#align(center + horizon)[
  #folder-text-block(
    title: [عنوان المرحلة],
    body: [توضح هذه البطاقة فكرة واحدة ضمن تسلسل واضح، مع عنوان قصير ونص موجز وأيقونة مرتبطة بالمحتوى.],
    icon: image("assets/folder-text-block-burger-teal.svg", width: 1.60cm),
    print-icon: image("assets/folder-text-block-burger-black.svg", width: 1.60cm),
    number: [2],
    width: 7cm,
    height: 4.55cm,
    direction: rtl,
    dark: true,
    colour: rgb("#35BFD0"),
  )
]

#pagebreak()
#set page(fill: white)
#print-group[
  #align(center + horizon)[
    #folder-text-block(
      title: [Lorem Ipsum],
      body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.],
      icon: image("assets/folder-text-block-burger-brown.svg", width: 1.60cm),
      print-icon: image("assets/folder-text-block-burger-black.svg", width: 1.60cm),
      number: [1],
      width: 7cm,
      height: 4.55cm,
      direction: ltr,
    )
  ]
]

#pagebreak()
#print-group[
  #align(center + horizon)[
    #folder-text-block(
      title: [عنوان المرحلة],
      body: [توضح هذه البطاقة فكرة واحدة ضمن تسلسل واضح، مع عنوان قصير ونص موجز وأيقونة مرتبطة بالمحتوى.],
      icon: image("assets/folder-text-block-burger-teal.svg", width: 1.60cm),
      print-icon: image("assets/folder-text-block-burger-black.svg", width: 1.60cm),
      number: [2],
      width: 7cm,
      height: 4.55cm,
      direction: rtl,
    )
  ]
]
