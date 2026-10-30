// Print-theme regression: the Blockst-style monochrome palette must not
// change logical start/end placement under an RTL direction.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 15cm, height: auto, margin: 1cm)
#set text(lang: "ar", dir: rtl, font: "DejaVu Sans", size: 11pt)
#set par(leading: 0.65em)
#show: faboxyst.with(theme: "print")

= طباعة أحادية اللون

#numbered-header-box(title: [عنوان مرقّم], number: 12, direction: rtl)[
  صندوق RTL: يجب أن يبقى العنوان والرقم على جهتيهما المنطقيتين بعد تطبيق نمط الطباعة.
]

#v(0.35cm)
#garnet-box(direction: rtl)[
  لافتة عنّابية بيضاء في نمط الطباعة
]

#v(0.35cm)
#postit(title: [ملاحظة], direction: rtl)[
  ورقة لاصقة بيضاء ذات حد أسود ونص واضح.
]

#v(0.35cm)
#sketch-box(shape: "round", fill: rgb("#F3C832"), stroke-colour: rgb("#A00000"))[
  إطار مرسوم يظل أسود وأبيض في النمط الطباعي.
]

#v(0.35cm)
#fabox(title: [مربع معياري], colour: rgb("#C2185B"), shadow: "large")[
  الظل يبقى رماديًّا في نسخة الطباعة.
]
