#import "design.typ": *
#import "options.typ": present
#let frontmatter(o) = {
  if present(o.abstract) or o.keywords.len() > 0 {
    pad(x: abstract-inset)[
      #if present(o.abstract) {
        if present(o.labels.abstract) {
          align(center, text(
            font: o.heading-font, size: scaled(o, label-size), weight: "bold", fill: o.accent,
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
        top-edge: body-top-edge, bottom-edge: body-bottom-edge, hyphenate: false,
        weight: if major { "bold" } else { "regular" },
      )
      set par(justify: false)
      // Number, title and page number in columns: a wrapped title hangs after the
      // number, and an unnumbered title starts at the margin.
      let prefix = it.prefix()
      let numbered = prefix not in (none, [], "")
      let leader = if major { [] } else { box(width: 1fr, text(fill: monash-grey, repeat[.])) }
      let cells = (
        if numbered { (if major { text(fill: o.accent, prefix) } else { prefix },) } else { () }
      ) + ([#it.element.body #leader], align(bottom, it.page()))
      block(
        above: if major { contents-chapter-gap + contents-entry-gap } else { contents-entry-gap },
        below: zero,
        layout(size => {
          // Columns are a word space plus the furniture gap apart.
          let space = measure[x x].width - measure[xx].width
          let row = pad(left: if major { zero } else { contents-indent })[
            #link(it.element.location())[
              #set text(fill: monash-black)
              #grid(
                columns: if numbered { (auto, 1fr, auto) } else { (1fr, auto) },
                column-gutter: furniture-gap + space, ..cells,
              )
            ]
          ]
          let height = calc.max(contents-row-height, measure(block(width: size.width, row)).height)
          block(width: full, height: height, row)
        }),
      )
    }
    outline(title: if present(o.labels.contents) { o.labels.contents }, depth: 2, indent: zero)
  }
}
