#import "../style/heading.typ": none-heading
#import "../style/font.typ": ziti, zihao

#let acknowledgement-page(
  info: (:),
  date: none,
  location: "上海大学",
  body,
) = {
  pagebreak(weak: true)
  show: none-heading
  heading(level: 1)[致#h(1em)谢]
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 23pt - 1em, spacing: 23pt - 1em, justify: true)
  body
  set align(right)
  info.name
  linebreak()
  location
  linebreak()
  if date == none {
    datetime.today().display("[year]年[month]月[day]日")
  } else {
    date
  }
  pagebreak(weak: true)
}
