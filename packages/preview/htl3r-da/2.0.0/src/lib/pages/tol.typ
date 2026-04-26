#import "../util.typ": insert-blank-page

#let create-page() = [
  #show outline.entry: it => {
    if (
      counter(figure.where(kind: "code")).at(it.element.location()).first() == 1
    ) {
      v(2em, weak: true)
    }
    it
  }

  #outline(
    title: [Quellcodeverzeichnis],
    target: figure.where(kind: "code"),
  )
  #set outline.entry(fill: line(length: 100%, stroke: (dash: ("dot", 1em))))
]
