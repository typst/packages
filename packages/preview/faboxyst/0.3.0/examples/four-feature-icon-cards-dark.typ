// Four Feature Icon Cards — dark slide, RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#032A3B"))
#set text(font: "DejaVu Sans", size: 8pt, fill: white)
#set par(leading: 0.38em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[أربع بطاقات للميزات والأيقونات]
#v(0.55cm)
#four-feature-icon-cards(
  steps: (
    (title: [التحليلات], body: [تابع الأداء وحوّل المعلومات المفيدة إلى قرارات واضحة.], icon: image("assets/four-feature-chart.svg", width: 1.10cm), dark-icon: image("assets/four-feature-chart-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-chart-print.svg", width: 1.10cm)),
    (title: [التنظيم], body: [رتّب الأولويات ونسّق المهام والخطوات القادمة.], icon: image("assets/four-feature-checklist.svg", width: 1.10cm), dark-icon: image("assets/four-feature-checklist-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-checklist-print.svg", width: 1.10cm)),
    (title: [الابتكار], body: [شجّع الأفكار الجديدة وحوّل المقترحات الواعدة إلى عمل.], icon: image("assets/four-feature-bulb.svg", width: 1.10cm), dark-icon: image("assets/four-feature-bulb-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-bulb-print.svg", width: 1.10cm)),
    (title: [المعلومات], body: [احفظ المعارف الأساسية واجعل الوصول إليها سهلاً وآمناً.], icon: image("assets/four-feature-database.svg", width: 1.10cm), dark-icon: image("assets/four-feature-database-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-database-print.svg", width: 1.10cm), colour: rgb("#72A576")),
  ),
  width: 22cm,
  direction: rtl,
  dark: true,
  colours: (rgb("#F25E4B"), rgb("#10B4CE"), rgb("#FF9500"), rgb("#72A576")),
)
