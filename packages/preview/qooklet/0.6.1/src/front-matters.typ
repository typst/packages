#import "dependencies.typ": default-info, default-names, default-styles
#import "common.typ": *

#let front-matter-style(body, styles: default-styles) = {
  show: book-style.with(styles: styles)

  set page(header: none, footer: none)
  set par(justify: true)
  body
}

#let preface(
  body,
  info: default-info,
  styles: default-styles,
  names: default-names,
) = {
  show: common-style.with(info: info)
  show: front-matter-style

  let author = info.author
  let lang = info.lang
  let dir = if lang == "zh" { center } else { left }

  align(dir, heading(level: 1, text(
    names.sections.at(lang).preface,
    size: styles.sizes.at(lang).preface * 1pt,
    font: styles.fonts.at(lang).preface,
  )))

  show heading.where(level: 1): it => {
    v(0.1em)
    it
    v(0.5em)
  }

  set text(
    size: styles.sizes.at(lang).context * 1pt,
    font: styles.fonts.at(lang).context,
    lang: lang,
  )

  v(2em)
  body
  v(2em)

  align(right, emph(author))
  pagebreak(to: "odd")
}

#let part-page(title, lang: "en", styles: default-styles) = {
  show: front-matter-style
  show: book-style.with(styles: styles)

  show figure.caption: none

  align(center + horizon, figure(
    text(size: styles.sizes.at(lang).part, font: styles.fonts.at(lang).part, strong(title)),
    kind: "part",
    supplement: none,
    numbering: _ => none,
    caption: title,
  ))
  pagebreak(to: "odd")
}
