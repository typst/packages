#import "dependencies.typ": default-info, default-styles, default-names
#import "common.typ": *

#let front-matter-style(body, styles: default-styles) = {
  show: book-style.with(styles: styles)

  set page(styles.paper.booklet, margin: 10%, header: none, footer: none)
  set par(justify: true)

  show heading.where(level: 1): it => {
    v(0.1em)
    set text(22pt)
    it
    v(0.5em)
  }
  text(body, size: 14pt)
}

#let preface(body, info: default-info, styles: default-styles, names: default-names) = {
  show: common-style
  show: front-matter-style

  let lang = info.lang
  let author = info.author

  let dir = if lang == "zh" { center } else { left }

  align(
    dir,
    heading(
      level: 1,
      text(
        names.sections.at(lang).preface,
        font: styles.fonts.at(lang).preface,
      ),
    ),
  )

  set text(
    font: styles.fonts.at(lang).context,
    size: 10.5pt,
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

  align(
    center + horizon,
    [
      #figure(
        text(36pt, strong(title), font: styles.fonts.at(lang).part),
        kind: "part",
        supplement: none,
        numbering: _ => none,
        caption: title,
      ) #label-part
    ],
  )
  pagebreak(to: "odd")
}
