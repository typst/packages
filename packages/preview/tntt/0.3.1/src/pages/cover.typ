#import "../utils/font.typ": use-size, _use-cjk-fonts, _use-fonts
#import "../utils/text.typ": space-text, distr-text

/// Cover Page
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
  info-items: (department: "系　　别", major: "专　　业", author: "姓　　名", supervisor: "指导教师"),
  info-sperator: "：",
  supervisor-sperator: " ",
  title-font: "HeiTi",
  body-font: "FangSong",
  back-font: "SongTi",
  author-width: 4,
  supervisor-width: 8,
) = {
  /// Prepare info
  let use-fonts(name) = _use-fonts(fonts, name)
  let use-cjk-fonts(name) = _use-cjk-fonts(fonts, name)

  let use-anonymous(s, w, m: "█") = if anonymous { m * w } else { distr-text(s, width: w * 1em) }

  info.author = use-anonymous(info.author, author-width)

  info.supervisor = use-anonymous(info.supervisor.join(supervisor-sperator), supervisor-width)

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

  text(
    size: use-size("三号"),
    font: use-cjk-fonts(body-font),
    block(
      width: grid-columns.sum(),
      grid(
        align: grid-align,
        columns: grid-columns,
        column-gutter: column-gutter,
        row-gutter: row-gutter,
        ..info-keys.map(k => (info-items.at(k), info-sperator, info.at(k, default: ""))).flatten()
      ),
    ),
  )

  v(9.4em)

  text(size: use-size("三号"), font: use-cjk-fonts(back-font), info.submit-date)
}
