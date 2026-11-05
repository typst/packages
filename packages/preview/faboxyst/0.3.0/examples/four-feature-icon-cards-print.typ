// Four Feature Icon Cards — monochrome print gallery, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.38em)
#show: faboxyst.with(theme: themes.print)

#let feature-steps = (
  (title: [Analytics], body: [Track performance across key measures, uncover useful patterns, and turn information into clearer decisions.], icon: image("assets/four-feature-chart.svg", width: 1.10cm), dark-icon: image("assets/four-feature-chart-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-chart-print.svg", width: 1.10cm)),
  (title: [Organization], body: [Keep work visible, prioritize tasks across the team, and coordinate upcoming actions without losing momentum.], icon: image("assets/four-feature-checklist.svg", width: 1.10cm), dark-icon: image("assets/four-feature-checklist-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-checklist-print.svg", width: 1.10cm)),
  (title: [Innovation], body: [Encourage fresh thinking, explore promising possibilities, and transform the best ideas into meaningful action.], icon: image("assets/four-feature-bulb.svg", width: 1.10cm), dark-icon: image("assets/four-feature-bulb-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-bulb-print.svg", width: 1.10cm)),
  (title: [Information], body: [Store essential knowledge safely, organize important records, and make information easy to retrieve.], icon: image("assets/four-feature-database.svg", width: 1.10cm), dark-icon: image("assets/four-feature-database-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-database-print.svg", width: 1.10cm)),
)

#text(size: 14pt, weight: "bold")[Four Feature Icon Cards — print, LTR]
#v(0.25cm)
#print-group[
  #four-feature-icon-cards(steps: feature-steps, width: 22cm, direction: ltr)
]

#v(0.50cm)
#text(size: 14pt, weight: "bold")[Same cards — print, RTL]
#v(0.25cm)
#print-group[
  #four-feature-icon-cards(
    steps: (
      (title: [التحليلات], body: [تابع الأداء وحوّل المعلومات المفيدة إلى قرارات واضحة.], icon: image("assets/four-feature-chart.svg", width: 1.10cm), dark-icon: image("assets/four-feature-chart-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-chart-print.svg", width: 1.10cm)),
      (title: [التنظيم], body: [رتّب الأولويات ونسّق المهام والخطوات القادمة.], icon: image("assets/four-feature-checklist.svg", width: 1.10cm), dark-icon: image("assets/four-feature-checklist-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-checklist-print.svg", width: 1.10cm)),
      (title: [الابتكار], body: [شجّع الأفكار الجديدة وحوّل المقترحات الواعدة إلى عمل.], icon: image("assets/four-feature-bulb.svg", width: 1.10cm), dark-icon: image("assets/four-feature-bulb-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-bulb-print.svg", width: 1.10cm)),
      (title: [المعلومات], body: [احفظ المعارف الأساسية واجعل الوصول إليها سهلاً وآمناً.], icon: image("assets/four-feature-database.svg", width: 1.10cm), dark-icon: image("assets/four-feature-database-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-database-print.svg", width: 1.10cm)),
    ),
    width: 22cm,
    direction: rtl,
  )
]
