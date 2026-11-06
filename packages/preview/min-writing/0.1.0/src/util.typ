#import "@preview/nexus-tools:0.3.0": default

#let defaults = (
  heading: (numbering: none),
  text: (
    font: "libertinus serif"),
  page: (
    margin: auto,
    width: "595.28pt",
    height: "841.89pt",
  ),
  table: (
    stroke: "1pt + black",
    fill: none,
    cell: (inset: auto),
  ),
  rect: (stroke: none),
  raw: (text: (font: "dejavu sans mono")),
  outline: (indent: auto),
)


#let custom-divider(self, color: white) = {
 if self.func() != divider {self} else {
    set align(center)
    set line(stroke: 1pt + color)
    set circle(fill: color)
    
    let self = (
      line(length: 20%),
      circle(radius: 1pt),
      circle(radius: 2pt),
      circle(radius: 1pt),
      line(length: 20%),
    )
    
    v(1em)
    
    self.map(box.with(inset: (x: 2pt))).join()
    
    v(1em)
  }
}


#let syntax-init(body) = {
  import "syntax.typ"
  
  show: syntax.unnumbered-headings
  show: syntax.quotes
  show: syntax.breaks
  show: syntax.inline
  show: syntax.check-lists
  show: syntax.dividers
  show: syntax.toc
  show: syntax.tables
  show: syntax.mermaid
  
  body
}