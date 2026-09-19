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
  let author = info.author
  let lang = info.lang
  let dir = if lang == "zh" { center } else { left }

  show: common-style
  show: front-matter-style.with(styles: styles)

  align(dir, heading(outlined: false, level: 1, cjk-latin-style(
    names.sections.at(lang).preface,
    size: styles.sizes.preface * 1pt,
    styles: styles,
    lang: lang,
    role: "preface",
  )))

  show heading.where(level: 1): it => {
    v(0.1em)
    it
    v(0.5em)
  }

  set text(
    size: styles.sizes.context * 1pt,
    ..font-role-options(styles, lang, "context"),
    lang: lang,
  )
  show: cjk-latin-style.with(styles: styles, lang: lang, role: "context", as-style: true)

  v(2em)
  body
  v(2em)

  align(right, emph(cjk-latin-style(author, styles: styles, lang: lang, role: "author")))
  pagebreak(to: "odd")
}

#let part-page(
  title,
  info: default-info,
  styles: default-styles,
) = {
  show: front-matter-style.with(styles: styles)
  show figure.caption: none

  let lang = info.lang

  align(center + horizon, figure(
    cjk-latin-style(
      title,
      size: styles.sizes.part * 1pt,
      styles: styles,
      lang: lang,
      role: "part",
      weight: "bold",
    ),
    kind: "part",
    supplement: none,
    numbering: _ => none,
    caption: title,
  ))
  pagebreak(to: "odd")
}
