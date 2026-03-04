#let print-declaration(strings) = {
  heading(level: 1, numbering: none, outlined: false)[#strings.declaration_title]
  v(1em)
  par[#strings.declaration_text]
  v(1.3cm)
  line(length: 100%)
  v(0.2em)
  text(size: 10pt)[#strings.declaration_signature]
  pagebreak()
}

#let print-table-of-contents(strings) = {
  outline(
    title: [#strings.toc_title],
    depth: 4,
    indent: auto,
  )
}

#let print-list-of-figures(strings, force-print: false) = {
  context {
    if force-print or query(figure.where(kind: image)).len() >= 3 {
      pagebreak()
      outline(
        title: [#strings.lof_title],
        target: figure.where(kind: image),
      )
    }
  }
}
