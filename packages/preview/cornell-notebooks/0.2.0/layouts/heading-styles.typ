// heading-styles.typ
// 标题样式

#let heading-styles = (
  main: (it) => [
    #set text(font: ("libertinus serif", "kaiti"))
    #if it.numbering != none {
      text(rgb("#2196F3"), weight: 500)[#sym.section]
      h(0.5em)
      text(rgb("#2196F3"))[#counter(heading).display()]
    }
    #it.body
    #v(0.1em)
    #if it.level == 1 and it.numbering != none {
      counter("chapter").step()
      counter(math.equation).update(0)
    }
  ],
  
  level1: (it) => box(width: 100%)[
    #set align(left)
    #set text(size: 18pt)
    #set heading(numbering: "1.1.1.1.")
    #it
  ],
  
  other: (it) => box(width: 100%)[
    #set align(left)
    #set text(size: 15pt)
    #set heading(numbering: "1.1.1.1.")
    #it
  ]
)
