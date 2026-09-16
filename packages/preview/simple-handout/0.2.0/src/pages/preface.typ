#let preface(
  // from entry
  fonts: (:),
  twoside: false,
  // options
  default-fonts: (:),
  date: datetime.today(),
  date-display: "[year] 年 [month] 月 [day] 日",
  title: [前　　言],
  outlined: false,
  body-font: "FangSong",
  back-font: "KaiTi",
  // self
  it,
) = {
  import "../font.typ": _use-fonts
  import "../imports.typ": tntt
  import tntt: twoside-pagebreak, use-size

  let use-fonts = _use-fonts.with(fonts + default-fonts)

  /// Render the preface page
  twoside-pagebreak(twoside)

  heading(level: 1, outlined: outlined, bookmarked: true, title)

  // body
  set text(font: use-fonts(body-font), size: use-size("小四"))

  it

  // back
  align(right, text(font: use-fonts(body-font), size: use-size("小四"), date.display(date-display)))
}
