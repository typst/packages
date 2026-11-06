// #import "../style/header.typ": page-header
#import "../style/heading.typ": none-heading

#let acknowledgement-page(
  info: (:),
  date: none,
  location: "上海大学",
  body,
) = {
  pagebreak(weak: true)
  show: none-heading
  v(2em)
  heading(level: 1)[致#h(1em)谢]
  v(2em)
  body
  {
    set align(right)
    [
      #info.name

      #location

      #if date == none {
        datetime.today().display("[year]年[month]月[day]日")
      } else {
        date
      }
    ]
  }
  pagebreak(weak: true)
}
