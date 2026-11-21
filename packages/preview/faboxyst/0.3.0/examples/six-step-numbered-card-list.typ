// Six-Step Numbered Card List — light slide, LTR.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#F1F1F1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.34em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[6-Step Numbered Card List — Slide Template]
#v(0.48cm)
#six-step-numbered-card-list(
  steps: (
    (title: [Set the direction], body: [Define the goal and agree on what a successful outcome means.]),
    (title: [Gather the facts], body: [Collect useful information, perspectives, and available resources.]),
    (title: [Explore options], body: [Compare possible approaches and identify the strongest opportunities.]),
    (title: [Make a plan], body: [Choose clear actions, owners, and realistic checkpoints.]),
    (title: [Take action], body: [Move the work forward and keep communication open across the team.]),
    (title: [Review progress], body: [Measure the results, capture lessons, and decide what comes next.]),
  ),
  width: 22cm,
  direction: ltr,
)
