#import "../utils/font.typ": use-size, trim-en
#import "../utils/text.typ": space-text, mask-text

/// Cover Page
#let cover(
  // from entry
  anonymous: false,
  fonts: (:),
  info: (:),
  // options
  title: "综合论文训练",
  margin: (top: 3.8cm, bottom: 3.2cm, x: 3cm),
  grid-columns: (2.80cm, 0.82cm, 5.62cm),
  grid-align: (center, left, left),
  column-gutter: -3pt,
  row-gutter: 16pt,
  info-keys: ("department", "major", "author", "supervisor"), // The order of listed keys
  info-items: (department: "院　　系", major: "专　　业", author: "姓　　名", supervisor: "指导教师"),
  info-sperator: "：",
  supervisor-sperator: "　",
) = {
  /// Prepare info
  let use-anonymous = if anonymous { mask-text } else { space-text }

  info.author = use-anonymous(info.author)

  info.supervisor = info.supervisor.map(use-anonymous).join(if anonymous { "█" } else { supervisor-sperator })

  /// Render cover page
  set page(margin: margin)

  set align(center)

  set text(font: trim-en(fonts.at("HeiTi")))

  image("../assets/logo.png", width: 7.81cm)

  v(-1em)

  text(size: use-size("小初"), weight: "bold", space-text(title, spacing: " "))

  v(1em)

  text(size: use-size("一号"), info.title)

  set text(size: use-size("三号"), font: trim-en(fonts.at("FangSong")))

  v(6em)

  block(
    width: grid-columns.sum(),
    grid(
      align: grid-align,
      columns: grid-columns,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      ..info-keys.map(k => (info-items.at(k), info-sperator, info.at(k, default: ""))).flatten()
    ),
  )

  v(6em)

  text(font: trim-en(fonts.at("SongTi")), info.submit-date)
}
