#import "dependencies.typ": default-info, default-styles
#import "common.typ": book-state, book-style

#let cover-style(body, styles: default-styles) = {
  book-state.update(true)
  show: book-style.with(styles: styles)
  body
}

#let cover(
  info,
  date: datetime.today(),
  styles: default-styles,
) = {
  show: cover-style

  let title = info.title
  let lang = info.lang
  let author = info.author

  align(center + horizon, [
    #text(
      size: styles.sizes.at(lang).cover * 1pt,
      font: styles.fonts.at(lang).cover,
      weight: "bold",
      title,
    )
    #v(1em)
    #text(
      size: styles.sizes.at(lang).author * 1pt,
      font: styles.fonts.at(lang).author,
      author,
    )
    #v(1em)
    #text(size: styles.sizes.at(lang).date * 1pt, font: styles.fonts.at(lang).date, date.display())
  ])
}

#let epigraph(
  info,
  body,
) = {
  show: cover-style

  let lang = info.lang
  align(center + horizon, text(
    size: styles.sizes.at(lang).epigraph * 1pt,
    font: styles.fonts.at(lang).epigraph,
    body,
  ))
}
