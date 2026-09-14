/// Outline Wrapper Page
///
/// - twoside (bool, str): Whether to use two-sided printing
/// - fonts (dictionary): The font family to use.
/// - default-fonts (dictionary): The default font family to use if not specified in fonts.
/// - depth (int): The maximum depth of the outline.
/// - font (array): The font family for each heading level.
/// - size (array): The font size for each heading level.
/// - title (content): The title of the outline page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add bookmarks for the page.
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
  default-fonts: (:),
  depth: 3,
  font: ("HeiTi", "SongTi"),
  size: ("小四",),
  title: [目　录],
  outlined: true,
  bookmarked: true,
  above: (10.5pt, 11.8pt),
  below: (11.4pt, 11.8pt),
  indent: (0pt, 12pt, 12pt),
  gap: .3em,
  fill: (repeat([.], gap: .1pt),),
) = {
  import "../utils/font.typ": _use-fonts, use-size
  import "../utils/util.typ": array-at, is-not-empty, twoside-pagebreak

  fonts = fonts + default-fonts

  /// Parse the outline configuration
  font = font.map(name => _use-fonts(fonts, name))

  size = size.map(use-size)

  /// Render the outline
  twoside-pagebreak(twoside)

  heading(level: 1, outlined: outlined, bookmarked: bookmarked, title)

  // set outline style
  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())

  show outline.entry: it => link(
    it.element.location(),
    it.indented(
      none,
      par(
        {
          text(font: array-at(font, it.level), size: array-at(size, it.level), {
            if is-not-empty(it.prefix()) {
              it.prefix()
              h(gap)
            }
            it.body()
          })
          box(width: 1fr, inset: (x: .25em), array-at(fill, it.level))
          it.page()
        },
        first-line-indent: 0pt,
        hanging-indent: 1.5em,
      ),
      gap: 0pt,
    ),
  )

  // display the outline
  outline(title: none, depth: depth)
}
