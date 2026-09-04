#import "@preview/palimpsest:0.1.0": *

#let my-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  body
}

#let my-letter-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  default-letter-template(body)
}

#let exchanges = reviewer(1)[
  #exchange(<r1-1>)[This claim needs more support.][
    We have expanded this sentence. #pinpoint(<r1-1>, excerpt: true)
  ]
]

#show: revisions.with(
  template: my-template,
  letter-template: my-letter-template,
  exchanges: exchanges,
)

#passage(<r1-1>)[The treatment #rep[has an effect][has a clinically meaningful effect] on survival.]
