#import "common.typ": *

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
      title,
      size: styles.sizes.cover * 1pt,
      font: styles.fonts.at(lang).cover,
      weight: "bold",
    )
    #v(1em)
    #text(
      author,
      size: styles.sizes.author * 1pt,
      font: styles.fonts.at(lang).author,
    )
    #v(1em)
    #text(
      date.display(),
      size: styles.sizes.date * 1pt,
      font: styles.fonts.at(lang).date,
    )
  ])
}

#let epigraph(
  body,
  info: default-info,
  styles: default-styles,
) = {
  show: cover-style

  let lang = info.lang
  align(center + horizon, text(
    body,
    size: styles.sizes.epigraph * 1pt,
    font: styles.fonts.at(lang).epigraph,
  ))
}

