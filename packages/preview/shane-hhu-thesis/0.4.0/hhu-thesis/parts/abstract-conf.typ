#import "../utils/utils.typ": ziti, zihao

#let abstract-conf(
  cn-abstract: none,
  cn-keywords: none,
  en-abstract: none,
  en-keywords: none,
  // page-break: none,
) = {
  // 摘要使用罗马字符的页码
  set page(numbering: "I", number-align: center, margin: (top: 4cm, bottom: 3cm, left: 3.2cm, right: 3.2cm))
  counter(page).update(1)
  // 一级标题
  set text(font: ziti.宋体, size: zihao.小四)
  // show heading.where(level: 1): set text(font: ziti.黑体, size: zihao.小二, weight: "bold")

  show heading.where(
    level: 1
  ): it => {
    set align(center)
    set text(font: ziti.黑体, size: zihao.小二, weight: "bold")
    it.body
  }

  set par(first-line-indent: 2em, leading: 1.2em, justify: true)

  if not cn-abstract in (none, [], "") or not cn-keywords in (none, ()) {
    {

      v(1.5cm)

      heading(numbering: none, level: 1, outlined: true, bookmarked: true, [摘#h(1em)要])

      v(0.5cm)

      cn-abstract

      v(1em)

      parbreak()

      if not cn-keywords in (none, ()) {
        assert(type(cn-keywords) == array)
        text(font: ziti.黑体, size: zihao.小四, weight: "bold")[关键词：] + cn-keywords.join("；")
      }
    }
  }

  if not en-abstract in (none, [], "") or not en-keywords in (none, ()) {
    {
      pagebreak(weak: true)

      // 计入目录
      heading(numbering: none, level: 1, outlined: true, bookmarked: true, [ABSTRACT])

      v(1cm)

      en-abstract

      parbreak()

      if not en-keywords in (none, ()) {
        assert(type(en-keywords) == array)
        text(weight: "bold")[Key words: ] + en-keywords.join("；")
      }
    }
  }
}
