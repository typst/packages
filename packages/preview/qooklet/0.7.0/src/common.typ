#import "deps.typ": cjk-latin-style, default-info, default-names, default-styles, font-role-options

#let book-state = state("book-state", false)
#let book-page-count-started = state("book-page-count-started", false)

#let fig-chapter = figure.where(kind: "chapter")
#let fig-appendix = figure.where(kind: "appendix")
#let fig-part = figure.where(kind: "part")
#let fig-chapter-img = figure.where(kind: "chapter-img")

#let counter-chapter = counter(fig-chapter)
#let counter-appendix = counter(fig-appendix)

#let appendix-number(index) = str(numbering("A", index))

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
  set list(indent: styles.spaces.list-indent * 1em)
  set enum(indent: styles.spaces.list-indent * 1em)
  set block(
    above: styles.spaces.block-above * 1em,
    below: styles.spaces.block-below * 1em,
    radius: 20%,
  )

  show link: set text(blue.lighten(10%))
  show link: underline
  body
}
