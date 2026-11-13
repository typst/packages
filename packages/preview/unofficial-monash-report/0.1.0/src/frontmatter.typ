#import "design.typ": *
#import "options.typ": present
#let frontmatter(o) = {
  if present(o.abstract) or o.keywords.len() > 0 {
    pad(x: abstract-inset)[
      #if present(o.abstract) {
        if present(o.labels.abstract) {
          align(center, text(
            font: o.heading-font, size: label-size, weight: "bold", fill: o.accent,
            o.labels.abstract,
          ))
          v(abstract-gap)
        }
        o.abstract
      }
      #if o.keywords.len() > 0 {
        if present(o.abstract) { parbreak() }
        if present(o.labels.keywords) {
          strong[#o.labels.keywords:]
          [ ]
          o.keywords.join(", ")
        } else { o.keywords.join(", ") }
      }
    ]
  }
  if o.outline {
    if present(o.abstract) or o.keywords.len() > 0 { v(contents-gap) }
    show outline.entry: it => {
      let major = it.level == 1
      set text(
        top-edge: body-top-edge, bottom-edge: body-bottom-edge,
        weight: if major { "bold" } else { "regular" },
      )
      let row = pad(left: if major { zero } else { contents-indent })[
        #link(it.element.location())[
          #set text(fill: monash-black)
          #box(if major { text(fill: o.accent, it.prefix()) } else { it.prefix() })
          #h(furniture-gap)#it.element.body
          #if major { h(1fr) } else { box(width: 1fr, text(fill: monash-grey, repeat[.])) }
          #h(furniture-gap)#it.page()
        ]
      ]
      block(
        above: if major { contents-chapter-gap + contents-entry-gap } else { contents-entry-gap },
        below: zero,
        layout(size => {
          let height = calc.max(contents-row-height, measure(block(width: size.width, row)).height)
          block(width: full, height: height, row)
        }),
      )
    }
    outline(title: if present(o.labels.contents) { o.labels.contents }, depth: 2, indent: zero)
  }
}
