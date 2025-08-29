#import "../utils/states.typ": part-state
#import "../utils/fonts.typ": 字体, 字号

#let main-body-bachelor-conf(
  thesis-name: [],
  first-level-title-page-disable-heading: false, //  一级标题页不显示页眉
  // 启用此选项后，“第X章 XXXXX” 一级标题所在页面将不显示页眉
  doc
) = {
  set page(
    header: {
      set align(center)
      set text(font: 字体.宋体, size: 字号.小五, lang: "zh")
      set par(first-line-indent: 0pt, leading: 16pt, justify: true, spacing: 16pt)

      context {
        let loc = here()
        // 真正的一级标题会被装入这里，如果是 none 则不渲染本页的页眉
        let true-level-1-heading = none

        // 先确定下一个一级标题
        let next-level-1-heading = query(
          selector(heading.where(level: 1)).after(loc),
        ).filter(
          it => it.location().page() == loc.page()
        ).at(0, default: none)

        if next-level-1-heading == none {
          // 如本页不存在下一个一级标题
          // 1. 本页不是一级标题所在页面（不需要考虑是否显示的问题）
          // 2. 本页所在章节由上一个一级标题所定义
          true-level-1-heading = query(
            selector(heading.where(level: 1)).before(loc),
          ).at(-1, default: none)
        } else {
          // 如果在本页，那么就要处理“一级标题是否显示页眉”参数
          true-level-1-heading = if first-level-title-page-disable-heading {none} else {next-level-1-heading} 
        }
        // 取所在章节的逻辑结束

        if true-level-1-heading == none {
          []
        } else if calc.even(loc.page()) {
          thesis-name.heading
          v(-1em)
          line(length: 100%, stroke: (thickness: 0.5pt))
        } else {
          if true-level-1-heading.numbering != none {
            (true-level-1-heading.numbering)(
              counter(heading.where(level: 1)).at(
                true-level-1-heading.location(),
              ).first(),
            )
            h(0.5em)
          }
          true-level-1-heading.body
          v(-1em)
          line(length: 100%, stroke: (thickness: 0.5pt))
        }
      }
      // locate 结束
      counter(footnote).update(0)
    },
    numbering: "1",
    header-ascent: 10%,
    footer-descent: 10%,
  )

  pagebreak(weak: false)

  counter(page).update(1)
  counter(heading.where(level: 1)).update(0)
  part-state.update("正文")

  doc
}