#let notation(
  // from entry
  twoside: false,
  // options
  outlined: true,
  title: [符号对照表],
  width: 100%,
  columns: (96pt, 1fr),
  row-gutter: 12pt,
  ..args,
  // self
  it,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title,
  )

  align(
    center,
    block(
      width: width,
      align(
        start,
        grid(
          columns: columns,
          row-gutter: row-gutter,
          ..args,
          ..it.children.filter(it => it.func() == terms.item).map(it => (it.term, it.description)).flatten()
        ),
      ),
    ),
  )
}
