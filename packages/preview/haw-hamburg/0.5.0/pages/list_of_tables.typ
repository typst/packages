#import "../translations.typ": translations

#context {
  if query(figure.where(kind: table)).len() > 0 {
    // TODO Needed, because context creates empty pages with wrong numbering
    set page(
      numbering: "i",
    )
    heading(translations.list-of-tables, numbering: none)
    outline(
      title: none,
      indent: true,
      fill: repeat(text(". ")),
      target: figure.where(kind: table),
    )
  }
}