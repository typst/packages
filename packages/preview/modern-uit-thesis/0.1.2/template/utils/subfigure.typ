#import "../chapters/global.typ": subpar, in-appendix

#let subfigure = {
  subpar.grid.with(
    numbering: n => if in-appendix.get() {
      numbering("A.1", counter(heading).get().first(), n)
    } else {
      numbering("1.1", counter(heading).get().first(), n)
    },
    numbering-sub-ref: (m, n) => if in-appendix.get() {
      numbering("A.1a", counter(heading).get().first(), m, n)
    } else {
      numbering("1.1a", counter(heading).get().first(), m, n)
    },
  )
}
