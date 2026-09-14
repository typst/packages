#import "slide-text.typ": *

#let latin-text-pattern = regex("[A-Za-z0-9][A-Za-z0-9+\\-_/.:,%&()]*")

#let apply-slide-fonts(body) = {
  set text(font: zh-font)
  show latin-text-pattern: set text(font: en-font)
  body
}

#let outline-item(index, title, subtitle) = block(
  fill: rgb("#fcf7f8"),
  stroke: 0.8pt + outline-rule,
  radius: 8pt,
  inset: (x: 0.95em, y: 0.75em),
)[
  #grid(
    columns: (outline-item-height, 1fr),
    column-gutter: 0.85em,
    [
      #box(
        width: outline-item-height,
        height: outline-item-height,
        fill: cover-bg,
        radius: 999pt,
      )[
        #align(center + horizon)[
          #text(size: outline-number-size, weight: "bold", fill: white)[#index]
        ]
      ]
    ],
    [
      #box(width: 100%, height: outline-item-height)[
        #align(left + horizon)[
          #text(size: outline-item-title-size, weight: "bold", fill: cover-accent)[#title]
          #h(0.75em)
          #{
            show strong: it => text(fill: strong-text-fill, weight: "bold", it.body)
            text(size: outline-item-body-size, fill: rgb("#5f5a57"), subtitle)
          }
        ]
      ]
    ],
  )
]

#let card(title, body, fill: card-fill, width: auto) = block(
  fill: fill,
  width: width,
  inset: 10pt,
  radius: 10pt,
  stroke: card-stroke,
)[
  #text(weight: "bold", size: card-title-size, fill: cover-accent)[#title]
  #set text(size: card-text-size)
  #body
]

#let conclusion-card(title, body, fill: conclusion-fill, width: 100%) = card(
  title,
  [
    #set text(size: conclusion-text-size)
    #body
  ],
  fill: fill,
  width: width,
)

#let result-conclusion(body, fill: conclusion-fill, width: 100%, label: [结论：]) = block(
  fill: fill,
  width: width,
  inset: 10pt,
  radius: 10pt,
  stroke: card-stroke,
)[
  #text(weight: "bold", size: conclusion-label-size, fill: cover-accent)[#label]
  #v(0pt)
  #set text(size: conclusion-text-size)
  #body
]

#let metric(label, value, note) = block(
  fill: rgb("#fcf8f6"),
  inset: 10pt,
  radius: 10pt,
  stroke: rgb("#d6c3bc"),
)[
  #text(size: metric-label-size, fill: rgb("#7c5d57"))[#label]
  #v(4pt)
  #text(weight: "bold", size: metric-value-size, fill: cover-accent)[#value]
  #v(2pt)
  #text(size: metric-note-size, fill: rgb("#5b4742"))[#note]
]

#let soft-note(body) = block(
  fill: note-fill,
  inset: 8pt,
  radius: 10pt,
  stroke: rgb("#e1d5d0"),
)[
  #text(size: 10.8pt, fill: note-text-fill)[#body]
]

#let small-title(it, centered: false, size: small-title-size) = {
  let title = text(
    size: size,
    fill: cover-bg,
    weight: "bold",
  )[#it]

  if centered {
    align(center)[#title]
  } else {
    title
  }
}

#let no-break(it) = box(inset: 0pt)[#it]

#let issue-row(tag, desc) = grid(
  columns: (80pt, 1fr),
  gutter: 8pt,
  align: (left, left),
  [
    #block(
      fill: white,
      radius: 999pt,
      inset: (x: 8pt, y: 3pt),
      stroke: rgb("#e3d5cf"),
    )[
      #text(size: issue-tag-size, weight: "bold", fill: cover-accent)[#tag]
    ]
  ],
  [
    #text(size: issue-desc-size)[#desc]
  ],
)

#let slide-table(..args) = block[
  #set text(size: table-text-size)
  #table(..args)
]

#let figure-caption(label, body, size: figure-caption-size) = text(size: size)[
  #label#h(0.5em)#body
]

#let table-caption(label, body, size: table-caption-size) = text(size: size)[
  #label#h(0.5em)#body
]

// Convenience: centered image with caption (manual numbering).
// For auto-numbering, see the Typst `figure` element or bring your own counter.
#let img(path, caption, width: 100%, size: large-figure-caption-size, card-wrap: false) = {
  let inner = align(center)[
    #image(path, width: width)
    #text(size: size)[#caption]
  ]
  if card-wrap { align(center, card([], inner, fill: rgb("#fcf6f3"))) } else { inner }
}
