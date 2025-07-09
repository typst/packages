#import "dependencies.typ": default-info, default-names, default-styles

#let book-state = state("book-state", false)

#let fig-chapter = figure.where(kind: "chapter")
#let fig-appendix = figure.where(kind: "appendix")
#let fig-part = figure.where(kind: "part")
#let fig-chapimg = figure.where(kind: "chapimg")

#let counter-chapter = counter(fig-chapter)
#let counter-appendix = counter(fig-appendix)

#let book-style(body, styles: default-styles) = {
  show: it => context {
    set page(
      paper: styles.paper.booklet,
      margin: 10%,
    ) if book-state.get()
    it
  }

  show: it => context {
    set page(
      paper: styles.paper.note,
      margin: 10%,
    ) if not book-state.get()
    it
  }
  body
}

#let common-style(
  body,
  info: default-info,
  styles: default-styles,
) = {
  let lang = info.lang

  set list(indent: styles.spaces.at(lang).list-indent * 1em)
  set enum(indent: styles.spaces.at(lang).list-indent * 1em)
  set block(
    above: styles.spaces.at(lang).block-above * 1em,
    below: styles.spaces.at(lang).block-below * 1em,
    radius: 20%,
  )

  show link: set text(blue.lighten(10%))
  show link: underline
  body
}
