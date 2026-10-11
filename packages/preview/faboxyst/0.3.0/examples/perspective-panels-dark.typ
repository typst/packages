// Genuine Arabic RTL example: reading order, text direction, and copy are RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.8cm, height: 9.0cm, margin: 0.35cm, fill: rgb("#172833"))
#set text(font: "DejaVu Sans", size: 9pt, lang: "ar", dir: rtl)
#show: faboxyst.with(theme: themes.notebook + (dir: rtl, lang: "ar"))

#align(center + horizon)[
  #perspective-panels(
    (
      (title: [الفكرة], number: [٠١], body: [حدّد الهدف بوضوح، وركّز على الأولوية الأهم.], colour: rgb("#3CB9D5")),
      (title: [الخطة], number: [٠٢], body: [قسّم العمل إلى خطوات عملية، ووزّع المسؤوليات.], colour: rgb("#F4C52E")),
      (title: [التنفيذ], number: [٠٣], body: [تابع التقدّم، وراجع النتائج بانتظام.], colour: rgb("#EE654D"), text-colour: white),
      (title: [المراجعة], number: [٠٤], body: [استخلص الدروس وحدّد الخطوة التالية.], colour: rgb("#77A96F")),
    ),
    panel-widths: (2.55cm, 2.95cm, 2.95cm, 2.55cm),
    gaps: (-0.10cm, -0.18cm, -0.10cm),
    height: 6.2cm,
    direction: rtl,
  )
]
