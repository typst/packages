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
  show: cover-style.with(styles: styles)

  let title = info.title
  let lang = info.lang
  let author = info.author

  align(center + horizon, [
    #text(
      title,
      font: styles.fonts.at(lang).cover,
      size: styles.sizes.cover * 1pt,
      weight: "bold",
    )
    #v(1em)
    #text(
      author,
      font: styles.fonts.at(lang).author,
      size: styles.sizes.author * 1pt,
    )
    #if date != none {
      v(1em)
      text(
        date.display(),
        font: styles.fonts.at(lang).date,
        size: styles.sizes.date * 1pt,
      )
    }
  ])
}

#let epigraph(
  body,
  info: default-info,
  styles: default-styles,
) = {
  show: cover-style.with(styles: styles)

  let lang = info.lang
  align(center + horizon, text(
    body,
    font: styles.fonts.at(lang).epigraph,
    size: styles.sizes.epigraph * 1pt,
  ))
}
