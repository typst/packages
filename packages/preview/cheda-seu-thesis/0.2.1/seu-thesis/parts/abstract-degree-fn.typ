#import "../utils/fonts.typ": 字体, 字号
#import "../utils/packages.typ": fakebold

#let abstract-conf(
  cnabstract: none,
  cnkeywords: none,
  enabstract: none,
  enkeywords: none,
  page-break: none
) = {
  // 摘要使用罗马字符的页码
  set page(numbering: "I", number-align: center)
  counter(page).update(1)
  
  set text(font: 字体.宋体, size: 字号.小四)
  set par(first-line-indent: 2em, leading: 9.6pt, justify: true)
  show par: set block(spacing: 9.6pt)

  if not cnabstract in (none, [], "") or not cnkeywords in (none, ()) {
    {
      heading(numbering: none, level: 1, outlined: true, bookmarked: true)[摘要]

      cnabstract

      v(1em)

      parbreak()

      if not cnkeywords in (none, ()) {
        assert(type(cnkeywords) == array)
        fakebold[关键词：] + cnkeywords.join("，")
      }
    }
  }

  if not enabstract in (none, [], "") or not enkeywords in (none, ()) {
    {
      if type(page-break) == function {
        page-break()
      }  else {
        pagebreak(weak: true)
      }
      
      heading(numbering: none, level: 1, outlined: true, bookmarked: true)[ABSTRACT]

      enabstract

      v(1em)
       parbreak()

      if not enkeywords in (none, ()) {
        assert(type(enkeywords) == array)
        text(weight: "bold")[Keywords: ] + enkeywords.join("，")
      }
    }
  }
}

#abstract-conf(
  cnabstract: [示例摘要],
  cnkeywords: ("关键词1", "关键词2"),
  enabstract: none,
  enkeywords: ("Keywords1", "Keywords2"),
) 
