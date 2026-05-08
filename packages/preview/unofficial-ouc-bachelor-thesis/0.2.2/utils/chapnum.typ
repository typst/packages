#import "@preview/pointless-size:0.1.2": zh
// https://github.com/ParaN3xus/typst-snippets/blob/main/chapnum/chapnum.typ

#let chap-num(
  config: (
    (figure.where(kind: image), figure, "1-1"),
    (figure.where(kind: table), figure, "1-1"),
    (figure.where(kind: raw), figure, "1-1"),
    (math.equation, math.equation, "(1-1)"),
  ),
  unnumbered-label: "-",
  fonts: (:),
  body,
) = {
  show heading.where(level: 1): it => {
    config.map(x => counter(x.first())).map(x => x.update(0)).join()
    it
  }
  let h1-counter = counter(heading.where(level: 1))

  show: x => config.fold(
    x,
    (it, cfg) => {
      let (k, f, n) = cfg

      show k: set f(
        numbering: _ => {
          if f == math.equation {
            [#numbering(n, ..(h1-counter.get(), counter(k).get()).flatten())<numbering:eq>]
          } else {
            numbering(n, ..(h1-counter.get(), counter(k).get()).flatten())
          }
        },
      )

      show selector(k).and(selector(label(unnumbered-label))): set f(numbering: _ => counter(k).update(x => x - 1))
      it
    },
  )
  body
}
