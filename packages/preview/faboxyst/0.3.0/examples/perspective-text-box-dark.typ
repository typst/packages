// One reusable perspective text box — dark RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 12cm, height: 6.2cm, margin: 0.45cm, fill: rgb("#20242A"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #perspective-text-box(
    title: [أهمية الفكرة],
    body: [اعرض حقيقة مهمة بوضوح. يمنح السطح المائل والحافة المظللة المحتوى عمقاً بسيطاً دون تشتيت الرسالة.],
    icon: image("assets/perspective-target-white.svg", width: 0.76cm),
    print-icon: image("assets/perspective-target-black.svg", width: 0.76cm),
    width: 6.8cm,
    height: 3.85cm,
    direction: rtl,
    dark: true,
    colour: rgb("#2A648D"),
  )
]
