#import "@preview/numbly:0.1.0": numbly
#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ"


#let heading-style(body) = {
  set heading(numbering: numbly("第{1:一}章", "{1}.{2}", "{1}.{2}.{3}", default: none))
  show heading: it => block(
    spacing: auto,
    sticky: true,
    {
      if it.numbering != none {
        if it.level != 1 { h(2 * zh(-4)) }
        counter(heading).display(it.numbering)
        h(0.25em, weak: true)
      }
      it.body
    },
  )
  show heading: set text(font: fonts.sans)
  show heading.where(level: 1): align.with(center)
  show heading.where(level: 1): set text(size: zh(-3))
  show heading.where(level: 2): set text(size: zh(4))
  show heading.where(level: 3): set text(size: zh(-4))
  body
}
