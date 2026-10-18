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
  let h-counter = counter(heading)

  show: x => config.fold(
    x,
    (it, cfg) => {
      let (k, f, n) = cfg

      show k: set f(
        numbering: _ => {
          let numberin = numbering(
            n,
            ..(h-counter.get().first(), counter(k).get()).flatten(),
          )
          if f == math.equation {
            [#numberin<numbering:eq>]
          } else {
            numberin
          }
        },
      )

      show selector(k).and(selector(label(unnumbered-label))): set f(numbering: _ => counter(k).update(x => x - 1))
      it
    },
  )
  body
}
