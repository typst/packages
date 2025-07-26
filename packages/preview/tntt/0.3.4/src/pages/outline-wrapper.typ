#import "../utils/font.typ": _use-fonts, use-size
#import "../utils/util.typ": array-at

/// Outline Wrapper Page
///
/// - twoside (bool): Whether to use two-sided printing
/// - fonts (dictionary): The font family to use.
/// - depth (int): The maximum depth of the outline.
/// - font (array): The font family for each heading level.
/// - size (array): The font size for each heading level.
/// - outlined (bool): Whether to outline the page.
/// - title (content): The title of the outline page.
/// - above (array): The vertical space above each heading based on its level.
/// - below (array): The vertical space below each heading based on its level.
/// - indent (array): The indentation for each heading level.
/// - gap (length): The gap between the heading and the numbering.
/// - fill (array): The fill content for the outline entries.
/// -> content
#let outline-wrapper(
  // from entry
  twoside: false,
  fonts: (:),
  // options
  depth: 3,
  font: ("HeiTi", "SongTi"),
  size: ("小四",),
  outlined: false,
  title: [目　录],
  above: (10.5pt, 11.8pt),
  below: (11.4pt, 11.8pt),
  indent: (0pt, 12pt, 12pt),
  gap: .3em,
  fill: (repeat([.], gap: .1pt),),
) = {
  /// Parse the outline configuration
  font = font.map(name => _use-fonts(fonts, name))

  size = size.map(use-size)

  /// Render the outline
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(level: 1, outlined: outlined, bookmarked: true, title)

  // set outline style
  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())

  show outline.entry: entry => block(above: array-at(above, entry.level), below: array-at(below, entry.level), link(
    entry.element.location(),
    entry.indented(
      none,
      {
        text(font: array-at(font, entry.level), size: array-at(size, entry.level), {
          if entry.prefix() not in (none, []) {
            entry.prefix()
            h(gap)
          }
          entry.body()
        })
        box(width: 1fr, inset: (x: .25em), fill.at(entry.level - 1, default: fill.last()))
        entry.page()
      },
      gap: 0pt,
    ),
  ))

  // display the outline
  outline(title: none, depth: depth)
}
