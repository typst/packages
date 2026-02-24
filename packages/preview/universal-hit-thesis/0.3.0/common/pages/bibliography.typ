#import "../utils/states.typ": bibliography-state
#import "../components/bilingual-bibliography.typ": bilingual-bibliography
#import "../utils/states.typ": special-chapter-titles-state
#import "../components/header.typ": use-hit-header
#import "../components/enheading.typ": addif_enheading

#let bibliography-page(
    use-same-header-text: false,
) = context [

  #let special-chapter-titles = special-chapter-titles-state.get()

  #show: use-hit-header.with(
    header-text: if use-same-header-text {
      special-chapter-titles.参考文献
    }
  )

  #let bibliography = bibliography-state.get()
  #assert(bibliography != none, message: "请在 doc.with 调用处传入合法的 bibliography 函数。")

  #heading(special-chapter-titles.参考文献, level: 1, numbering: none)
  #addif_enheading(special-chapter-titles.at("参考文献-en", default: none))

  #bilingual-bibliography(bibliography: bibliography, title: none)
  // #bibliography(title: none)
]