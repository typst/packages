#import "dependencies.typ": default-names, default-styles

#let book-state = state("book-state", false)

#let fig-chapter = figure.where(kind: "chapter")
#let fig-appendix = figure.where(kind: "appendix")
#let fig-part = figure.where(kind: "part")
#let fig-chapimg = figure.where(kind: "chapimg")

#let counter-chapter = counter(fig-chapter)
#let counter-appendix = counter(fig-appendix)

#let book-style(body, styles: default-styles) = {
  show: it => context {
    set page(paper: styles.paper.booklet) if book-state.get()
    it
  }

  show: it => context {
    set page(paper: styles.paper.note) if not book-state.get()
    it
  }
  body
}

#let indent-base = 1.2em
#let common-style(body, list-indent: indent-base) = {
  set list(indent: list-indent)
  set enum(indent: list-indent)
  set block(above: 1em, below: 1em, radius: 20%)

  show link: set text(blue.lighten(10%))
  show link: underline
  body
}
