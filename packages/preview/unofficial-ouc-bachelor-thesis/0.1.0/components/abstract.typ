#import "@preview/pointless-size:0.1.2": zh

#let abstract(
  title: (:),
  abstract: (:),
  keywords: (:),
  fonts: (:),
) = {
  set heading(numbering: none, bookmarked: false, outlined: false)
  page({
    heading(level: 1, title.zh)
    heading(level: 1, "摘要".clusters().join(" " * 3))

    abstract.zh
    parbreak()
    set text(font: fonts.黑体, size: zh("小四"), weight: "bold")
    [关键词：] + keywords.zh.join("；")
  })

  page({
    heading(level: 1, title.en)
    heading(level: 1, "Abstract")

    abstract.en
    parbreak()
    set text(font: fonts.西文, size: zh("小四"), weight: "bold")
    [Key Words: ] + keywords.en.join(", ")
  })
}
