// Table of contents functions for FEUP thesis

// Helper function for table of contents
#let make-toc() = {
  
  outline(
    title: "Table of Contents",
    depth: 3,
    indent: auto,
    target: selector(heading).after(<main-content>),
  )
  
  pagebreak()
  
  outline(
    title: "List of Figures",
    target: selector(figure.where(kind: image)).after(<main-content>),
  )
  
  pagebreak()
  
  outline(
    title: "List of Tables",
    target: selector(figure.where(kind: table)).after(<main-content>),
  )
  
  pagebreak()
}
