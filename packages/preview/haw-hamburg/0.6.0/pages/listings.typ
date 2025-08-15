#import "../translations.typ": translations

#context {
  if query(figure.where(kind: raw)).len() > 0 {
    heading(translations.listings, numbering: none)

    set outline.entry(fill: grid(
      columns: 2,
      gutter: 0pt,
      repeat[~.], h(11pt),
    ))

    outline(
      title: none,
      indent: auto,
      target: figure.where(kind: raw),
    )
  }
}
