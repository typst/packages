#import "../util.typ": insert-blank-page

#let create-page() = [
  #show outline.entry: it => {
    if (
      counter(figure.where(kind: image)).at(it.element.location()).first() == 1
    ) {
      v(2em, weak: true)
    }
    it
  }

  #outline(
    title: [Abbildungsverzeichnis],
    target: figure.where(kind: image),
  )
  #set outline.entry(fill: line(length: 100%, stroke: (dash: ("dot", 1em))))
]
