#import "@preview/zebraw:0.4.3": zebraw

#let config(doc) = {
  set page(width: auto, height: auto, margin: 20pt, fill: none)
  show raw: zebraw

  doc
}
