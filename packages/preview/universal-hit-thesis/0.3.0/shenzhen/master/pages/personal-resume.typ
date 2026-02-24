#import "../../../common/components/header.typ": use-hit-header
#import "../../../common/utils/states.typ": special-chapter-titles-state

#let personal-resume-page(
  content,
  use-same-header-text: true,
) = context [
  #let special-chapter-titles = special-chapter-titles-state.get()

  #show: use-hit-header.with(
    header-text: if use-same-header-text {
      special-chapter-titles.个人简历
    }
  )

  #show: use-hit-header.with(header-text: special-chapter-titles.个人简历)
  #heading(special-chapter-titles.个人简历, level: 1, numbering: none)

  #content
]