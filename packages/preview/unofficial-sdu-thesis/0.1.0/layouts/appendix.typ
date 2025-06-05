#import "../styles/fonts.typ": fonts, fontsize
#import "../styles/heading.typ": appendix-first-heading
#import "../styles/figures.typ": figures, tablex

#let appendix(
  body,
) = {
  show: appendix-first-heading
  
  show: figures.with(appendix: true)
  // show: tablex.with(supplement: "附表")

  show heading: it => {
    set text(font: fonts.黑体)
    set par(first-line-indent: 0em)
    if it.level == 1 {
      set align(center)
      set text(weight: "bold", size: fontsize.三号)
      // pagebreak(weak: true)
      v(15pt)
      counter(heading).display() + h(0.5em) + it.body
      v(15pt)
    } else if it.level == 2 {
      set text(weight: "bold", size: fontsize.三号, fill: rgb("c00000"))
      counter(heading).display()
      h(0.5em)
      set text(fill: black)
      it.body
      v(1.5em)
    } else {
      set text(weight: "bold", size: fontsize.小四)
      counter(heading).display() + h(0.5em) + it.body
    }
  }

  show heading: set heading(outlined: false)
  // show heading.where(level: 2): set heading(outlined: false)
  // show heading.where(level: 3): set heading(outlined: false)
  show figure.caption: c => [
    #text(fill: rgb("c00000"), weight: "bold")[
      #c.supplement #context c.counter.display(c.numbering)
    ]
    #c.separator#c.body
  ]
  
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: 20pt - 1em,
    spacing: 20pt - 1em,
    justify: true,
  )
  body
}
