#import "../utils/font.typ": _use-cjk-fonts, _use-fonts, use-size
#import "../utils/text.typ": distr-text, space-text

/// Cover Page
///
/// - anonymous (bool): Whether to use anonymous mode
/// - fonts (dictionary): The font family to use.
/// - info (dictionary): The information to be displayed on the cover page.
/// - title (str): The title of the cover page
/// - margin (margin): The margin settings for the cover page
/// - grid-columns (array): The widths of the grid columns
/// - grid-align (array): The alignment of each column in the grid
/// - column-gutter (length): The gutter between columns in the grid
/// - row-gutter (length): The gutter between rows in the grid
/// - info-keys (array): The keys to be displayed in the info section, in the order they should appear
/// - info-items (dictionary): The items to be displayed in the info section, mapping keys to their display names
/// - info-sperator (str): The separator between the info keys and items
/// - supervisor-sperator (str): The separator between the supervisor name and position
/// - title-font ("SongTi" | "HeiTi" | "KaiTi" | "FangSong" | "Mono" | "Math"): The font for the title
/// - body-font ("SongTi" | "HeiTi" | "KaiTi" | "FangSong" | "Mono" | "Math"): The font for the body text
/// - back-font ("SongTi" | "HeiTi" | "KaiTi" | "FangSong" | "Mono" | "Math"): The font for the back text
/// - author-width (length): The distribution width of the author name
/// - supervisor-width (length): The distribution width of the supervisor name and position
/// -> content
#let cover(
  // from entry
  anonymous: false,
  fonts: (:),
  info: (:),
  // options
  title: "综合论文训练",
  margin: (top: 3.8cm, bottom: 3.2cm, x: 3cm),
  grid-columns: (3.00cm, 0.82cm, 5.62cm),
  grid-align: (center, left, left),
  column-gutter: -3pt,
  row-gutter: 20.2pt,
  info-keys: ("department", "major", "author", "supervisor"), // The order of listed keys
  info-items: (department: "系别", major: "专业", author: "姓名", supervisor: "指导教师"),
  info-sperator: "：",
  supervisor-sperator: " ",
  title-font: "HeiTi",
  body-font: "FangSong",
  back-font: "SongTi",
  author-width: 4em,
  supervisor-width: 8em,
) = {
  /// Prepare info
  let use-fonts = name => _use-fonts(fonts, name)
  let use-cjk-fonts = name => _use-cjk-fonts(fonts, name)

  let use-anonymous(s, w) = if anonymous {
    // use outset to fix the base line of the font
    rect(fill: black, width: w, height: 1em, outset: (top: 2pt, bottom: -2pt))
  } else {
    distr-text(s, width: w)
  }

  info.author = use-anonymous(info.author, author-width)

  info.supervisor = use-anonymous(info.supervisor.join(supervisor-sperator), supervisor-width)

  let _max-info-item-width = calc.max(..info-items.values().map(v => v.clusters().len()))

  /// Render cover page
  set page(margin: margin)

  set align(center)

  v(1.8em)

  image("../assets/logo.png", width: 7.81cm)

  v(-1.35em)

  text(size: use-size("小初"), font: use-fonts(title-font), weight: "bold", space-text(title))

  v(1.22em)

  text(size: use-size("一号"), font: use-fonts(title-font), info.title)

  v(8.7em)

  text(size: use-size("三号"), font: use-cjk-fonts(body-font), block(width: grid-columns.sum(), grid(
    align: grid-align,
    columns: grid-columns,
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    ..info-keys
      .map(k => (
        distr-text(info-items.at(k), width: _max-info-item-width * 1em),
        info-sperator,
        info.at(k, default: ""),
      ))
      .flatten()
  )))

  v(9.4em)

  text(size: use-size("三号"), font: use-cjk-fonts(back-font), info.submit-date)
}
