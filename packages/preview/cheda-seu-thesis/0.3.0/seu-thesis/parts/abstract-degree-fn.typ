#import "../utils/fonts.typ": 字体, 字号
#import "../utils/packages.typ": fakebold

#let abstract-conf(
  cn-abstract: none,
  cn-keywords: none,
  en-abstract: none,
  en-keywords: none,
  page-break: none,
) = {
  // 摘要使用罗马字符的页码
  set page(numbering: "I", number-align: center)
  counter(page).update(1)

  set text(font: 字体.宋体, size: 字号.小四)
  set par(first-line-indent: 2em, leading: 9.6pt, justify: true)
  show par: set block(spacing: 9.6pt)

  if not cn-abstract in (none, [], "") or not cn-keywords in (none, ()) {
    {
      heading(numbering: none, level: 1, outlined: true, bookmarked: true)[摘要]

      cn-abstract

      v(1em)

      parbreak()

      if not cn-keywords in (none, ()) {
        assert(type(cn-keywords) == array)
        fakebold[关键词：] + cn-keywords.join("，")
      }
    }
  }

  if not en-abstract in (none, [], "") or not en-keywords in (none, ()) {
    {
      if type(page-break) == function {
        page-break()
      } else {
        pagebreak(weak: true)
      }

      heading(
        numbering: none,
        level: 1,
        outlined: true,
        bookmarked: true,
      )[ABSTRACT]

      en-abstract

      v(1em)
      parbreak()

      if not en-keywords in (none, ()) {
        assert(type(en-keywords) == array)
        text(weight: "bold")[Keywords: ] + en-keywords.join("，")
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
