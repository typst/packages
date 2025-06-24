#import "font.typ": ziti, zihao
#import "@preview/numbly:0.1.0": numbly

#let none-heading(body) = {
  show heading.where(level: 1): set align(center)
  set heading(
    numbering: none,
    supplement: none,
  )
  show heading.where(level: 1): it => {
    set text(
      font: ziti.heiti,
      weight: "regular",
      size: zihao.xiaoer,
    )
    v(15pt)
    it.body
    v(15pt)
  }
  pagebreak(weak: true)
  body
}

#let main-heading(
  body,
) = {
  set heading(
    numbering: numbly(
      "{1}",
      "{1}.{2}",
      "{1}.{2}.{3}",
      "{1}.{2}.{3}.{4}",
    ),
    supplement: "main",
  )
  show heading: it => {
    set text(font: ziti.heiti)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      set align(center)
      set text(weight: "bold", size: zihao.xiaoer)
      pagebreak(weak: true)
      v(15pt)
      counter(heading).display() + h(0.5em) + it.body
      v(15pt)
    } else if it.level == 2 {
      set text(weight: "regular", size: zihao.sihao)
      counter(heading).display() + h(0.5em) + it.body
    } else {
      set text(weight: "regular", size: zihao.xiaosi)
      counter(heading).display() + h(0.5em) + it.body
    }
  }
  body
}

#let appendix-first-heading(
  body,
) = {
  set heading(
    numbering: numbly(
      "附录{1:A} ",
      "附{1:A}{2} ",
      "附{1:A}{2}.{3} ",
      "附{1:A}{2}.{3}.{4} ",
    ),
    supplement: "appendix",
  )
  counter(heading).update(0)
  show heading: it => {
    set text(font: ziti.heiti)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      set text(weight: "bold", size: zihao.xiaoer)
      pagebreak(weak: true)
      v(15pt)
      counter(heading).display() + h(0.5em) + it.body
      v(15pt)
    } else if it.level == 2 {
      set text(weight: "regular", size: zihao.sihao)
      counter(heading).display() + h(0.5em) + it.body
    } else {
      set text(weight: "regular", size: zihao.xiaosi)
      counter(heading).display() + h(0.5em) + it.body
    }
  }
  body
}
