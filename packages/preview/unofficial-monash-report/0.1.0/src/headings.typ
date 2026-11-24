#import "design.typ": *
#let heading-style(o, body) = {
  set heading(numbering: "1.1")
  show heading: it => {
    let major = it.level == 1
    if major and o.mode == "report" {
      for kind in (image, table, raw, "theorem") {
        counter(figure.where(kind: kind)).update(0)
      }
      counter(math.equation).update(0)
    }
    block(
      inset: (top: if major { chapter-title-inset } else { zero }),
      above: if major { heading-above } else { section-above },
      below: if major {
        heading-below + if not it.outlined { contents-heading-extra } else { zero }
      } else { section-below },
      sticky: true,
    )[
      #set text(
        font: o.heading-font, top-edge: title-top-edge,
        bottom-edge: if major { title-bottom-edge } else { section-bottom-edge },
        size: if major { chapter-size } else if it.level == 2 {
          section-size
        } else { subsection-size },
        hyphenate: false,
        weight: if major { light-weight } else { "bold" },
        fill: if major { o.accent } else { monash-black },
      )
      #set par(justify: false, leading: if major { chapter-leading } else { section-leading })
      #context {
        if it.numbering != none {
          text(fill: o.accent, counter(heading).display(it.numbering))
          h(number-gap)
        }
        it.body
      }
    ]
  }
  body
}
