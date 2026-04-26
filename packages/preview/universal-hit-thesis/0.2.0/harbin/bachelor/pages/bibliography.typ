#import "../config/constants.typ": special-chapter-titles

#let bibliography-page(
  bibliography,
) = [

  #heading(special-chapter-titles.参考文献, level: 1, numbering: none)

  #bibliography(title: none)
]