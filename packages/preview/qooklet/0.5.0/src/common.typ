#import "dependencies.typ": default-styles, default-names

#let book-state = state("book-state", false)
#let content-prefix = state("content-prefix")

#let label-chapter = <chapter>
#let label-appendix = <appendix>
#let label-part = <part>
#let label-chapimg = <chapimg>

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
