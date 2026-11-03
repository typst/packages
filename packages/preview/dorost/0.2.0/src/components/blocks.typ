#import "../config.typ": default-colors, default-text
#import "inline.typ": tone-color

#let note(body, title: none, tone: "neutral") = {
  let color = tone-color(tone)
  block(width: 100%, inset: 0.8em, radius: 0.25em, stroke: 0.5pt + color)[
    #if title != none { block(above: 0pt, below: 0.4em, text(fill: color, weight: "bold", title)) }
    #body
  ]
}

#let quote-frame(body, attribution: none) = block(
  width: 100%, inset: 0.8em, stroke: 0.5pt + default-colors.rule,
)[
  #body
  #if attribution != none {
    block(above: 0.4em, below: 0pt, text(fill: default-colors.muted, attribution))
  }
]

#let prompt-example(label, body) = block(
  width: 100%, inset: 0.8em, stroke: 0.5pt + default-colors.rule,
)[
  #block(above: 0pt, below: 0.4em, text(weight: "bold", label))
  #body
]

#let checklist(items) = {
  if type(items) != array { panic("dorost: checklist items must be an array") }
  list(marker: [☐], indent: default-text.list-indent, spacing: default-text.list-spacing, ..items)
}
