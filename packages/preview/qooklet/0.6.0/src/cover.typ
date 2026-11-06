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

  align(
    center + horizon,
    [
      #text(size: 36pt, weight: "bold", font: styles.fonts.at(lang).title, title)
      #v(1em)
      #text(24pt, font: styles.fonts.at(lang).author, author)
      #v(1em)
      #text(18pt, date.display())
    ],
  )
}

#let epigraph(
  body,
) = {
  show: cover-style
  align(center + horizon, text(16pt, body))
}
