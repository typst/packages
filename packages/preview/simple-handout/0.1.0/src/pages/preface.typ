#import "../utils/font.typ": use-size, _use-font

#let preface(
  // from entry
  font: (:),
  twoside: false,
  // options
  date: datetime.today(),
  date-display: "[year] 年 [month] 月 [day] 日",
  title: [前　　言],
  outlined: false,
  body-font: "FangSong",
  back-font: "KaiTi",
  // self
  it,
) = {
  /// Render the preface page
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    outlined: outlined,
    title,
  )

  // body
  set text(font: _use-font(font, body-font), size: use-size("小四"))

  it

  // back
  align(right, text(font: _use-font(font, body-font), size: use-size("小四"), date.display(date-display)))
}
