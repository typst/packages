#let outline_page() = {
  // TODO Needed, because context creates empty pages with wrong numbering
  set page(
    numbering: "i",
  )

  show outline.entry.where(
    level: 1
  ): it => {
    v(1fr, weak: true)
    strong(it.body)
    h(1fr)
    strong(it.page)
  }
  
  outline(
    depth: 3,
    indent: auto,
    fill: grid(
      columns: 2,
      gutter: 0pt,
      repeat[~.],
      h(11pt),
    )
  )
}
