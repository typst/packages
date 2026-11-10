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
    #cjk-latin-style(
      title,
      size: styles.sizes.cover * 1pt,
      styles: styles,
      lang: lang,
      role: "cover",
      weight: "bold",
    )
    #v(1em)
    #cjk-latin-style(
      author,
      size: styles.sizes.author * 1pt,
      styles: styles,
      lang: lang,
      role: "author",
    )
    #if date != none {
      v(1em)
      cjk-latin-style(
        date.display(),
        size: styles.sizes.date * 1pt,
        styles: styles,
        lang: lang,
        role: "date",
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
  align(center + horizon, cjk-latin-style(
    body,
    size: styles.sizes.epigraph * 1pt,
    styles: styles,
    lang: lang,
    role: "epigraph",
  ))
}
