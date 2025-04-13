#import "../helpers.typ": *


#let table-of-contents(abstract) = {
  let page-numbering-label = if abstract == [] { <turn-on-page-numbering> }
  align(center)[
    #heading(
      outlined: false,
      "Table of Contents",
    ) #page-numbering-label
  ]
  [#h(1fr) Page]
  show outline: set par(leading: 1em)
  show outline.entry.where(level: 1): it => {
    strong(it)
  }
  outline(title: none, indent: 1.5em, fill: none)
  pagebreak(weak: true)
}

#let list-of-tables() = {
  align(center)[#heading(upper("List of Tables"))]
  [Number #h(1fr) Title #h(1fr) Page]
  show outline.entry.where(level: 1): it => {
    let table-num = to-string[#it].slice(7, 8)
    table-num = [ #text("   ") #table-num #text("   ") ]
    if to-string[#it].slice(8, 9) != ":" {
      table-num = to-string[#it].slice(7, 9)
      table-num = [ #text("  ") #figure-num #text("   ") ]
    }
    let table-name = to-string[#it].slice(10)
    table(
      columns: (auto, 1fr, auto),
      stroke: none,
      align: (center, center, center),
      table-num, [#text(weight: "bold", table-name)], [ #text(" ") #it.page ],
    )
    v(-4em)
  }
  outline(title: none, fill: none, target: figure.where(kind: table))
  pagebreak(weak: true)
}

#let list-of-figures() = {
  align(center)[#heading(upper("List of Figures"))]
  [Number #h(1fr) Title #h(1fr) Page]
  show outline.entry.where(level: 1): it => {
    let figure-num = to-string[#it].slice(8, 9)
    figure-num = [ #text("   ") #figure-num #text("   ") ]
    if to-string[#it].slice(9, 10) != ":" {
      figure-num = to-string[#it].slice(8, 10)
      figure-num = [ #text("  ") #figure-num #text("   ") ]
    }
    let figure-name = to-string[#it].slice(11)
    table(
      columns: (auto, 1fr, auto),
      stroke: none,
      align: (center, center, center),
      figure-num,
      [#text(weight: "bold", figure-name)],
      [ #text("  ") #it.page ],
    )
    v(-4em)
  }
  outline(title: none, fill: none, target: figure.where(kind: image))
  pagebreak(weak: true)
}
