#import "@preview/pointless-size:0.1.2": zh
#import "/utils/chapnum.typ": chap-num

#let appendix(body, chap-num-config: ()) = {
  if body == [] {
    return
  }
  pagebreak(weak: true)
  heading([#text(size: zh("小三"), "附录".clusters().join(h(.5em * 3)))<heading:appendix>], numbering: none)
  set heading(bookmarked: false, outlined: false, numbering: "A.1")
  counter(heading).update(0)

  show: chap-num.with(config: {
    (
      chap-num-config
        + (
          (figure.where(kind: image), figure, "1-1"),
          (figure.where(kind: table), figure, "1-1"),
          (figure.where(kind: raw), figure, "1-1"),
          (math.equation, math.equation, "(1-1)"),
        )
    ).map(x => (x.at(0), x.at(1), x.at(2).replace("1", "A", count: 1)))
  })
  body
}

