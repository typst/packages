#let outline-image(lang: "en") = {
  // Restore default formatting for titles
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.inner()),
  )

  outline(
    target: figure.where(kind: image),
    title: if lang == "zh" [插图目录] else if lang == "pt" [Lista de Figuras] else [List of Figures],
  )
}

#let outline-table(lang: "en") = {
  // Restore default formatting for titles
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.inner()),
  )

  outline(
    target: figure.where(kind: table),
    title: if lang == "zh" [表格目录] else if lang == "pt" [Lista de Tabelas] else [List of Tables],
  )
}

#let outline-table-image(lang: "en") = {
  // Restore default formatting for titles
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.inner()),
  )

  outline(
    target: figure.where(kind: image),
    title: if lang == "zh" [插图目录] else if lang == "pt" [Lista de Tabelas e Figuras] else [List of Tables and Figures],
  )
  outline(
    target: figure.where(kind: table),
    title: none,
  )
}
