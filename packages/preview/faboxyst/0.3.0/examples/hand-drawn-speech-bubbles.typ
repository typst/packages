// Hand-drawn speech bubbles — light slide, LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[Hand-Drawn Speech Bubbles — Slide Template]
#v(1.70cm)
#hand-drawn-speech-bubbles(
  steps: (
    (kind: "quote", title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales.]),
    (kind: "speech", title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales.]),
    (kind: "thought", title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales.]),
  ),
  width: 22cm,
  direction: ltr,
)
