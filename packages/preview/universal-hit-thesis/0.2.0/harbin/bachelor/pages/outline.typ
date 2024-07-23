#import "../config/constants.typ": special-chapter-titles

#let outline-page() = [
  #set par(first-line-indent: 0em)

  #[
    #show heading: none
    #heading(special-chapter-titles.目录, level: 1, outlined: false)
  ]

  #outline(title: align(center)[#special-chapter-titles.目录], indent: auto)
]