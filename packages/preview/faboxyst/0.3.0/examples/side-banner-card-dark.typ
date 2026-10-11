// One dark-page RTL Side Banner Card.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 10cm, height: 10.5cm, margin: 0.3cm, fill: rgb("#002033"))
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

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
