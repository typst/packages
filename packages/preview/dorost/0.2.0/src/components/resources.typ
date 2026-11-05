#import "../config.typ": default-colors, default-text

#let resource-link(url, label, detail: none) = block[
  #link(url, label)
  #if detail != none {
    block(above: 0.25em, below: 0pt, text(fill: default-colors.muted, detail))
  }
]

#let resource-links(..items) = {
  if items.named().len() > 0 { panic("dorost: resource-links accepts positional items only") }
  stack(dir: ttb, spacing: default-text.list-spacing, ..items.pos())
}
