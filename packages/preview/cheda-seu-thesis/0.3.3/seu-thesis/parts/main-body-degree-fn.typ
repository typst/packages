#import "../utils/states.typ": part-state
#import "../utils/fonts.typ": 字体, 字号
#import "../utils/get-heading-title.typ": get-heading-at-page

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

        // 上一个一级标题会被装入这里，如果是 none 则不渲染本页的页眉
        // 同时，需要确定本页上是否有一级标题
        let (last-level-1-heading, is-level-1-heading-on-this-page) = get-heading-at-page(loc)
        // 如果在本页，那么就要处理“一级标题是否显示页眉”参数
        if is-level-1-heading-on-this-page and first-level-title-page-disable-heading {
          last-level-1-heading = none
        }

        if last-level-1-heading == none {
          []
        } else if calc.even(loc.page()) {
          thesis-name.heading
          v(-1em)
          line(length: 100%, stroke: (thickness: 0.5pt))
        } else {
          if last-level-1-heading.numbering != none {
            (last-level-1-heading.numbering)(
              counter(heading.where(level: 1)).at(
                last-level-1-heading.location(),
              ).first(),
            )
            h(0.5em)
          }
          last-level-1-heading.body
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