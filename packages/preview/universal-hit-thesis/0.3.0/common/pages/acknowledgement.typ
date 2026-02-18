#import "../components/header.typ": use-hit-header
#import "../components/enheading.typ": addif_enheading
#import "../utils/states.typ": special-chapter-titles-state

#let acknowledgement(
  content,
  use-same-header-text: false,
) = context [

  #let special-chapter-titles = special-chapter-titles-state.get()

  #show: use-hit-header.with(
    header-text: if use-same-header-text {
      special-chapter-titles.致谢
    }
  )

  #heading(special-chapter-titles.致谢, level: 1, numbering: none)
  #addif_enheading(special-chapter-titles.at("致谢-en", default: none))

  #content
]