#let outline-pages(
    outline-figures: true,
    outline-tables: true,
) = {
    outline(indent: auto)
    pagebreak()
    if outline-figures {
        outline(title: "List of Figures", target: figure.where(kind: image))
        pagebreak()
    }
    if outline-tables {
        outline(title: "List of Tables", target: figure.where(kind: table))
        pagebreak()
    }
}
