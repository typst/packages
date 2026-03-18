#import "../../../common/theme/type.typ": 字体, 字号
#import "../config/constants.typ": special-chapter-titles

#let abstract-cn(
  content,
  keywords: (),
) = {
  set par(
    first-line-indent: 2em,
    justify: true,
    leading: 1em,
  )

  heading(special-chapter-titles.摘要, level: 1)

  text(
    font: 字体.宋体,
    size: 字号.小四,
  )[#content]

  let abstract-key-words(content) = {
    set par(first-line-indent: 0em)
    text(font: 字体.黑体)[关键词：]
    text(font: 字体.宋体)[#content.join("；")]
  }

  abstract-key-words(keywords)
}

#let abstract-en(
  content,
  keywords: (),
) = {
  set par(
    first-line-indent: 2em,
    justify: true,
    leading: 1em,
  )

  heading(special-chapter-titles.Abstract, level: 1)

  text(
    font: 字体.宋体,
    size: 字号.小四,
  )[#content]

  let abstract-key-words(content) = {
    set par(first-line-indent: 0em)

    text(font: 字体.宋体, weight: "bold", "Keywords:  ")
    text(font: 字体.宋体)[#content.join(", ")]
  }

  abstract-key-words(keywords)
}