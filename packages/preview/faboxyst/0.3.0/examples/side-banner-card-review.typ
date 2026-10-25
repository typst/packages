// Review: one Side Banner Card in LTR and dark RTL variants.
// Print versions are compiled separately in side-banner-card-print.typ.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 10.5cm, margin: 0.3cm, fill: rgb("#F2F2F2"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #side-banner-card-box(
    title: [Project Overview],
    label: [STEP 01],
    body: [Clear priorities help a team turn a shared goal into concrete actions. Review progress regularly and adjust the next step when needed.],
    icon: image("assets/side-banner-rocket.svg", width: 0.88cm),
    print-icon: image("assets/side-banner-rocket-black.svg", width: 0.88cm),
    width: 6.2cm,
    height: 8.8cm,
    direction: ltr,
    colour: rgb("#F15F47"),
  )
]

#pagebreak()
#set page(fill: rgb("#002033"))
#align(center + horizon)[
  #side-banner-card-box(
    title: [فكرة واضحة],
    label: [مرحلة ٠١],
    body: [تساعد الأولويات الواضحة الفريق على تحويل الهدف المشترك إلى خطوات عملية. راجعوا التقدم بانتظام، وعدّلوا الخطوة التالية عند الحاجة.],
    icon: image("assets/side-banner-rocket-cyan.svg", width: 0.88cm),
    print-icon: image("assets/side-banner-rocket-black.svg", width: 0.88cm),
    width: 6.2cm,
    height: 8.8cm,
    direction: rtl,
    colour: rgb("#35C3DC"),
    label-colour: rgb("#101820"),
    shadow-colour: rgb("#385462"),
  )
]
