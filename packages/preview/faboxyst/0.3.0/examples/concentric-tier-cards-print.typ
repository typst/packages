// Concentric Tier Cards — monochrome print, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.34em)
#show: faboxyst.with(theme: themes.print)

#text(size: 14pt, weight: "bold")[Concentric Tier Cards — print, LTR]
#v(0.25cm)
#print-group[
  #concentric-tier-cards(
    levels: (
      (title: [BROAD SCOPE], body: [Describe the wider context and identify the domain for this initiative.], icon: image("assets/concentric-globe.svg", width: 1.02cm), print-icon: image("assets/concentric-globe-print.svg", width: 1.02cm)),
      (title: [FOCUSED SCOPE], body: [Narrow the discussion to the audience or topic that matters most.], icon: image("assets/concentric-target.svg", width: 1.02cm), print-icon: image("assets/concentric-target-print.svg", width: 1.02cm)),
      (title: [CORE PRIORITY], body: [Highlight the decision or action with the greatest potential impact.], icon: image("assets/concentric-diamond.svg", width: 1.35cm), print-icon: image("assets/concentric-diamond-print.svg", width: 1.35cm)),
    ),
    width: 22cm,
    direction: ltr,
  )
]

#v(0.4cm)
#text(size: 14pt, weight: "bold")[Same tiers — print, RTL]
#v(0.25cm)
#print-group[
  #concentric-tier-cards(
    levels: (
      (title: [النطاق العام], body: [اعرض السياق الأوسع وحدّد المجال الذي تنتمي إليه المبادرة.], icon: image("assets/concentric-globe.svg", width: 1.02cm), print-icon: image("assets/concentric-globe-print.svg", width: 1.02cm)),
      (title: [نطاق مركّز], body: [ضيّق مجال النقاش نحو الفئة أو الموضوع الأكثر صلة.], icon: image("assets/concentric-target.svg", width: 1.02cm), print-icon: image("assets/concentric-target-print.svg", width: 1.02cm)),
      (title: [الأولوية الأساسية], body: [ركّز على القرار أو الإجراء الذي سيصنع الأثر الأكبر.], icon: image("assets/concentric-diamond.svg", width: 1.35cm), print-icon: image("assets/concentric-diamond-print.svg", width: 1.35cm)),
    ),
    width: 22cm,
    direction: rtl,
  )
]
