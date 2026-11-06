// One Folder Text Blocks component — dark-page RTL, with the source template's bright palette.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11cm, height: 7.2cm, margin: 0.4cm, fill: rgb("#002335"))
#set text(font: "DejaVu Sans", size: 9pt, fill: white)
#show: faboxyst.with(theme: themes.notebook)

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
