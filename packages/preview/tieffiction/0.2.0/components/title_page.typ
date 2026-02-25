#import "../core/state.typ": meta-value

#let title-page = () => context {
  let authors = meta-value("author")
  set page(margin: (x: 20mm, y: 45mm))
  align(center)[
    #text(size: 26pt, font: "Cormorant SC", weight: "bold")[#meta-value("title")]\
    #text(size: 16pt, font: "Cormorant SC")[#meta-value("subtitle")]

    #text(size: 16pt, font: "Cormorant SC", weight: "bold")[#if type(authors) == array {
      authors.join(", ")
    } else {
      authors
    }]
  ]
}
