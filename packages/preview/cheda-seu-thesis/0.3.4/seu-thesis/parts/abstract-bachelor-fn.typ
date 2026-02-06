#import "../utils/fonts.typ": 字体, 字号

#let abstract-conf(
  cn-abstract: none,
  cn-keywords: none,
  en-abstract: none,
  en-keywords: none,
) = {
  // 摘要使用罗马字符的页码
  set page(numbering: "I", number-align: center)
  counter(page).update(1)

  set text(font: 字体.宋体, size: 字号.小四)

  if not cn-abstract in (none, [], "") or not cn-keywords in (none, ()) {
    {
      set par(first-line-indent: (amount: 2em, all: true), leading: 14pt, justify: true, spacing: 14pt)
      // 我不理解为什么两个摘要需要不同的间距

      heading(outlined: true, bookmarked: true, level: 1, numbering: none)[摘要]

      v(3pt)

      cn-abstract

      v(18pt)

      // 英文
      set par(first-line-indent: 0em)

      if not cn-keywords in (none, ()) {
        assert(type(cn-keywords) == array)
        "关键词：" + cn-keywords.join("，")
      }
    }
  }

  if not en-abstract in (none, [], "") or not en-keywords in (none, ()) {
    {
      pagebreak(weak: true)

      set par(first-line-indent: (amount: 2em, all: true), leading: 15pt, justify: true, spacing: 15pt)
      // 我不理解为什么两个摘要需要不同的间距

      heading(
        outlined: true,
        bookmarked: true,
        level: 1,
        numbering: none,
      )[ABSTRACT]

      v(3pt)

      en-abstract

      v(20pt)

      if not en-keywords in (none, ()) {
        assert(type(en-keywords) == array)
        "KEY WORDS: " + en-keywords.join(", ")
      }
    }
  }
}

#abstract-conf(
  cn-abstract: [示例摘要],
  cn-keywords: ("关键词1", "关键词2"),
  en-abstract: none,
  en-keywords: ("Keywords1", "Keywords2"),
)
