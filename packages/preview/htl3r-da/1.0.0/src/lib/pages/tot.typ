#import "../util.typ": insert-blank-page

#let create-page() = [
  #show outline.entry: it => {
    if (
      counter(figure.where(kind: table)).at(it.element.location()).first() == 1
    ) {
      v(2em, weak: true)
    }
    it
  }

  #outline(
    title: [Tabellenverzeichnis],
    target: figure.where(kind: table),
    fill: line(length: 100%, stroke: (dash: ("dot", 1em))),
  )
]
