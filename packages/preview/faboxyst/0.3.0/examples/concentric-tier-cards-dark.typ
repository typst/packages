// Concentric Tier Cards — dark slide, RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#032A3B"))
#set text(font: "DejaVu Sans", size: 8pt, fill: white)
#set par(leading: 0.34em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[بطاقات متداخلة — من النطاق العام إلى الأولوية]
#v(0.35cm)
#concentric-tier-cards(
  levels: (
    (title: [النطاق العام], body: [اعرض السياق الأوسع وحدّد المجال الذي تنتمي إليه المبادرة.], icon: image("assets/concentric-globe.svg", width: 1.02cm), print-icon: image("assets/concentric-globe-print.svg", width: 1.02cm)),
    (title: [نطاق مركّز], body: [ضيّق مجال النقاش نحو الفئة أو الموضوع الأكثر صلة.], icon: image("assets/concentric-target.svg", width: 1.02cm), print-icon: image("assets/concentric-target-print.svg", width: 1.02cm)),
    (title: [الأولوية الأساسية], body: [ركّز على القرار أو الإجراء الذي سيصنع الأثر الأكبر.], icon: image("assets/concentric-diamond.svg", width: 1.35cm), print-icon: image("assets/concentric-diamond-print.svg", width: 1.35cm)),
  ),
  width: 22cm,
  direction: rtl,
  dark: true,
)
