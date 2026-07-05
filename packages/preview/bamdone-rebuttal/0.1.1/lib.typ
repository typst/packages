// heavily inspired by Friedemann Zenke, https://zenkelab.org/resources/latex-rebuttal-response-to-reviewers-template/

#let rc = counter("reviewer")
#let pc = counter("point")

#let reviewer() = {
  rc.step()
  pc.update(0)
  line(length: 100%)
  [= Reviewer #context rc.display()]
}

#let configure(
  point-color: blue.darken(30%),
  response-color: black,
  new-color: green.darken(30%),
) = {
  let point(color: point-color, body) = figure(
    {
      pc.step()
      let pc_ = context pc.get().at(0)
      let rc_ = context rc.get().at(0)
      set text(color)
      set align(left)
      [*Point #rc_.#pc_* --- #body]
    },
    kind: "point-outer",
    supplement: [Point],
  )

  let response(color: response-color, body) = text(color)[*Response* --- #body]
  let new(color: new-color, body) = text(color, body)

  (
    point: point,
    response: response,
    new: new,
  )
}

#let rebuttal(
  // The document's title.
  title: [Response Letter],

  // Content containing list of authors
  authors: [],

  date: datetime.today().display(),

  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",

  // The paper's content.
  body,
) = {
  set page(
    numbering: "1",
    number-align: center,
    paper: "us-letter",
  )
  set text(11pt)
  set par(justify: true)

  // Quotation Formatting
  set quote(block: true)
  show quote: set pad(left: 2em)
  show quote: it => block(
    fill: black.transparentize(90%),
    width: 100%,
    inset: 5pt,
    radius: 1pt,
    it
  )

  show figure.where(kind: "point"): set block(breakable: true)
  show figure.where(kind: "point"): it => align(left,block(it))

  // inspired by i-figured
  show figure.where(kind: "point-outer"): it => {
    let rc_ = rc.at(it.location()).at(0)
    let pc_ = pc.at(it.location()).at(0) + 1
    let figure = figure(
      it.body,
      kind: "point",
      supplement: it.supplement,
      numbering: nums => numbering("1.1", rc_, pc_),
    )
    if it.has("label") {
      let new-label = label("pt-" + str(it.label))
      [#figure #new-label]
    } else [
      #figure
    ]
  }

  align(center)[
    = #title
    #authors\
    #date
  ]

  body
}
