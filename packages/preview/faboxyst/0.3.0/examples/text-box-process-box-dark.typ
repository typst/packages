// One RTL Text Box Process card with mirrored folds and the source's cyan palette.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 11.5cm, height: 14cm, margin: 0.35cm, fill: rgb("#002033"))
#set text(font: "DejaVu Sans", size: 10pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center + horizon)[
  #text-box-process-box(
    title: [خطة العمل],
    number: [٠٢],
    body: [حددوا الهدف بوضوح، ثم رتّبوا الخطوات الرئيسية وحدّدوا موعداً مناسباً لكل خطوة. #parbreak() وزّعوا المسؤوليات، وشاركوا المستجدات، وأزيلوا العوائق التي تؤخر التنفيذ. #parbreak() راجعوا النتائج بعد المرحلة الأولى، ثم اتفقوا على الإجراء التالي.],
    colour: rgb("#43BDE0"),
    direction: rtl,
  )
]
