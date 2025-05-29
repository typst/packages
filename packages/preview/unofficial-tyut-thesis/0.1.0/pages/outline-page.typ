#import "@preview/pointless-size:0.1.1": zh

#let outline-page(
  twoside: false,
  depth: 3,
  title: "目　　录",
  outlined: false,
  title-vspace: 25pt,
  title-text-args: auto,
  reference-font: auto,
  reference-size: zh(-3),
  bookmarked: true,
  above: (2pt, 14pt),
  below: (14pt, 14pt),
  indent: (0pt, 18pt, 28pt),
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
  ..args,
) = {
  if title-text-args == auto {
    title-text-args = (font: "SimHei", size: zh(-3), weight: "bold")
  }
  if reference-font == auto {
    reference-font = ("Times New Roman", "SimHei")
  }

  pagebreak(weak: true, to: if twoside { "odd" })

  set text(font: reference-font, size: reference-size)

  {
    set align(center)
    text(..title-text-args, title)
    text(size:0em, fill:white)[#heading(
      numbering: none,
      level: 1,
      outlined: false,
      bookmarked: bookmarked,
      title,
    )]
  }

  v(title-vspace)

  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())

  show outline.entry: entry => block(
    above: above.at(
      entry.level - 1,
      default: above.last(),
    ),
    below: below.at(
      entry.level - 1,
      default: below.last(),
    ),
    link(
      entry.element.location(),
      entry.indented(
        none,
        {
          text(
            font: ("Times New Roman", "SimSun"),
            size: zh(-4),
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
            },
          )
          box(width: 1fr, inset: (x: .25em), fill.at(entry.level - 1, default: fill.last()))
          entry.page()
        },
        gap: 0pt,
      ),
    ),
  )

  outline(title: none, depth: depth)
}
