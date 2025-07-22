#import "../utils/font.typ": use-size, _use-font
#import "../utils/util.typ": array-at

#let outline-wrapper(
  // from entry
  font: (:),
  twoside: false,
  // self
  gap: 0pt,
  fill: (repeat([.], gap: 0.15em),),
  font-list: ("HeiTi", "SongTi", "FangSong"),
  size: ("小三", "四号", "小四"),
  outlined: false,
  depth: 4,
  title: [目　　录],
  indent: (0pt, 28pt, 22pt, 28pt),
  above: (30pt, 18pt, 12pt, 12pt),
  below: (0pt,),
) = {
  /// Parse the outline configuration
  font-list = font-list.map(name => _use-font(font, name))

  size = size.map(use-size)

  /// Render the outline page
  pagebreak(weak: true, to: if twoside { "odd" })

  // title
  heading(level: 1, outlined: outlined, title)

  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())

  show outline.entry: entry => block(
    above: array-at(above, entry.level),
    below: array-at(below, entry.level),
    link(
      entry.element.location(),
      entry.indented(
        none,
        {
          text(
            font: array-at(font-list, entry.level),
            size: array-at(size, entry.level),
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
            },
          )
          box(width: 1fr, inset: (x: .25em), array-at(fill, entry.level))
          entry.page()
        },
        gap: gap,
      ),
    ),
  )

  outline(title: none, depth: depth)
}
