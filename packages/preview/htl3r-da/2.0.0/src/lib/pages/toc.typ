#import "../util.typ": insert-blank-page

#let create-page() = [
  #show outline.entry.where(level: 1): it => context {
    if it.element.level == 1 {
      v(2em, weak: true)
      strong(it)
    } else {
      it
    }
  }
  #outline(
    target: selector(heading).after(<DA_BEGIN>),
    depth: 3,
    indent: 1em,
  )
  #set outline.entry(fill: line(length: 100%, stroke: (dash: ("dot", 1em))))
]
