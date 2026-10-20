#import "@preview/pointless-size:0.1.2": zh

#let appendix(body) = {
  if body == [] {
    return
  }
  pagebreak(weak: true)
  heading([#text(size: zh("小三"), "附录".clusters().join(h(.5em * 3)))<heading:appendix>], numbering: none)
  set heading(bookmarked: false, outlined: false, numbering: "A.1")
  counter(heading).update(0)
  body
}

