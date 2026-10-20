#import "../config.typ": default-colors

// Single or nested double border with an optional caller-owned title.
#let border-frame(body, style: "single", title: none) = {
  if style not in ("single", "double") {
    panic("dorost: frame style must be \"single\" or \"double\"")
  }
  let framed = block(width: 100%, inset: 0.8em, stroke: 0.5pt + default-colors.rule)[
    #if title != none { block(above: 0pt, below: 0.4em, strong(title)) }
    #body
  ]
  if style == "double" {
    block(width: 100%, inset: 0.15em, stroke: 0.5pt + default-colors.rule, framed)
  } else { framed }
}

// A visual title, without imposing a native heading level or outline structure.
#let section-title(title, rule: true) = {
  if type(rule) != bool { panic("dorost: rule must be a boolean") }
  block(width: 100%)[
    #strong(title)
    #if rule { line(length: 100%, stroke: 0.5pt + default-colors.rule) }
  ]
}
