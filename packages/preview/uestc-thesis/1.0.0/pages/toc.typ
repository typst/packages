// #pagebreak()
#import "../utils/header.typ": header-content

#let toc() = {
  set page(
    header: header-content("目录"),
  )

  align(center, heading("目录", numbering: none, outlined: false))

  outline(
    indent: 20pt,
    title: none
  )
}
