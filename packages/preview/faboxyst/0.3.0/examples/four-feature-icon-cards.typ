// Four Feature Icon Cards — light slide, LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.38em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[Four Feature Icon Cards — Slide Template]
#v(0.55cm)
#four-feature-icon-cards(
  steps: (
    (title: [Analytics], body: [Track performance across key measures, uncover useful patterns, and turn information into clearer decisions.], icon: image("assets/four-feature-chart.svg", width: 1.10cm), dark-icon: image("assets/four-feature-chart-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-chart-print.svg", width: 1.10cm)),
    (title: [Organization], body: [Keep work visible, prioritize tasks across the team, and coordinate upcoming actions without losing momentum.], icon: image("assets/four-feature-checklist.svg", width: 1.10cm), dark-icon: image("assets/four-feature-checklist-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-checklist-print.svg", width: 1.10cm)),
    (title: [Innovation], body: [Encourage fresh thinking, explore promising possibilities, and transform the best ideas into meaningful action.], icon: image("assets/four-feature-bulb.svg", width: 1.10cm), dark-icon: image("assets/four-feature-bulb-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-bulb-print.svg", width: 1.10cm)),
    (title: [Information], body: [Store essential knowledge safely, organize important records, and make information easy to retrieve.], icon: image("assets/four-feature-database.svg", width: 1.10cm), dark-icon: image("assets/four-feature-database-dark.svg", width: 1.10cm), print-icon: image("assets/four-feature-database-print.svg", width: 1.10cm)),
  ),
  width: 22cm,
  direction: ltr,
)
