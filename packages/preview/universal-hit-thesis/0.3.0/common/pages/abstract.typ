#import "../theme/type.typ": 字体, 字号
#import "../components/header.typ": use-hit-header
#import "../components/enheading.typ": enheading
#import "../utils/states.typ": special-chapter-titles-state

#let abstract-cn(
  content,
  keywords: (),
  use-same-header-text: false,
  par-leading: 0.65em,
  par-spacing: 1.2em,
  text-tracking: 0pt,
) = context {

  let special-chapter-titles = special-chapter-titles-state.get()

  show: use-hit-header.with(
    header-text: if use-same-header-text {
      special-chapter-titles.摘要
    }
  )

  heading(special-chapter-titles.摘要, level: 1)
  enheading(special-chapter-titles.摘要-en)

  set par(leading: par-leading, spacing: par-spacing)

  text(
    font: 字体.宋体,
    size: 字号.小四,
    tracking: text-tracking,
  )[#content]

  let abstract-key-words(content) = {
    par(first-line-indent: 0em)[
      #text(font: 字体.黑体)[关键词：]
      #text(font: 字体.宋体)[#content.join("；")]
    ]
  }

  abstract-key-words(keywords)
}

#let abstract-en(
  content,
  keywords: (),
  use-same-header-text: false,
  par-leading: 0.65em,
  par-spacing: 1.2em,
  text-tracking: 0pt,
  text-spacing: 100% + 0pt,
) = context {

  let special-chapter-titles = special-chapter-titles-state.get()

  show: use-hit-header.with(
    header-text: if use-same-header-text {
      special-chapter-titles.Abstract
    }
  )

  heading(special-chapter-titles.Abstract, level: 1)
  enheading(special-chapter-titles.Abstract-en)

  set par(leading: par-leading, spacing: par-spacing)

  let abstract-key-words(content) = {
    par(first-line-indent: 0em)[
      #text(font: 字体.宋体, weight: "bold", "Keywords: ")
      #text(font: 字体.宋体)[#content.join(", ")]
    ]
  }

  text(
    font: 字体.宋体,
    size: 字号.小四,
    tracking: text-tracking,
    spacing: text-spacing,
  )[
    #content
    #abstract-key-words(keywords)
  ]
}