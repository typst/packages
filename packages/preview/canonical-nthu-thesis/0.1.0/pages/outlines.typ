#let outline-pages = {
    outline(indent: auto)
    pagebreak()
    outline(title: "List of Figures", target: figure.where(kind: image))
    pagebreak()
    outline(title: "List of Tables", target: figure.where(kind: table))
    pagebreak()
}
