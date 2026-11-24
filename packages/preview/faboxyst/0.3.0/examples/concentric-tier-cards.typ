// Concentric Tier Cards — light slide, LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.34em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[Concentric Tier Cards — Slide Template]
#v(0.35cm)
#concentric-tier-cards(
  levels: (
    (title: [BROAD SCOPE], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris.], icon: image("assets/concentric-globe.svg", width: 1.02cm), print-icon: image("assets/concentric-globe-print.svg", width: 1.02cm)),
    (title: [FOCUSED SCOPE], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.], icon: image("assets/concentric-target.svg", width: 1.02cm), print-icon: image("assets/concentric-target-print.svg", width: 1.02cm)),
    (title: [CORE PRIORITY], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra.], icon: image("assets/concentric-diamond.svg", width: 1.35cm), print-icon: image("assets/concentric-diamond-print.svg", width: 1.35cm)),
  ),
  width: 22cm,
  direction: ltr,
)
