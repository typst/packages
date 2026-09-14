#import "fonts.typ": fonts, fontsize
#import "@preview/numbly:0.1.0": numbly
#import "@preview/i-figured:0.2.4"

#let none-heading(body) = {
  show heading.where(level: 1): set align(center)
  set heading(
    numbering: none,
    supplement: none,
  )
  show heading.where(level: 1): it => {
    set text(
      font: fonts.黑体,
      weight: "regular",
      size: fontsize.小二,
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
    set text(font: fonts.黑体)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      set align(center)
      set text(weight: "bold", size: fontsize.三号)
      pagebreak(weak: true)
      v(15pt)
      counter(heading).display() + h(0.5em) + it.body
      v(15pt)
    } else if it.level == 2 {
      set text(weight: "bold", size: fontsize.四号)
      counter(heading).display() + h(0.5em) + it.body
    } else {
      set text(weight: "bold", size: fontsize.小四)
      counter(heading).display() + h(0.5em) + it.body
    }
  }
  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "table"))
  body
}

#let appendix-first-heading(
  body,
) = {
  set heading(
    numbering: numbly(
      none,
      "附录{2}",
      "附{2:1}-{3:A}",
    ),
    supplement: "appendix",
  )
  counter(heading).update(0)
  show heading: it => {
    set text(font: fonts.黑体)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      set text(
        font: fonts.黑体,
        weight: "bold",
        size: fontsize.小二,
      )
      v(15pt)
      it.body
      v(15pt)
    } else if it.level == 2 {
      set text(weight: "bold", size: fontsize.三号, fill: rgb("c00000"))
      counter(heading).display()
      h(0.5em)
      set text(fill: black)
      it.body
      v(1.5em)
    } else if it.level >= 3 {
      set text(weight: "bold", size: fontsize.小四)
      counter(heading).display() + h(0.5em) + it.body
    }
  }
  body
}
