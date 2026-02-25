#import "../core/state.typ": metadata-state

#let title-page = () => context {
  set page(margin: (x: 20mm, y: 45mm))
  align(center)[
    #text(size: 26pt, font: "Cormorant SC", weight: "bold")[#metadata-state.final().at("title", default: none)]\
    #text(size: 16pt, font: "Cormorant SC")[#metadata-state.final().at("subtitle", default: none)]

    #text(size: 16pt, font: "Cormorant SC", weight: "bold")[#metadata-state.final().at("author", default: none)]
  ]
}
