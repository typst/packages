#import "../utils/states.typ": *
#import "../utils/fonts.typ": 字体, 字号

#let main-body-bachelor-conf(
  thesisname: [], 
  first-level-title-page-disable-heading: false, //  一级标题页不显示页眉
  // 启用此选项后，“第X章 XXXXX” 一级标题所在页面将不显示页眉
  doc
) = {
  /* 
  这里有一个巨大的自造轮子用于实现奇数页显示章节号与章节名、偶数页显示固定文字。

  原有计划迁移到 chic-hdr ，但是由于 heading 跨页问题，以及需要显示章节号（第XX章），故仍是自造轮子。
  
  请查阅 `utils/show-heading.typ` 以查看 heading 跨页的其他影响 。如有更好的解决方案，欢迎给出建议或提交 PR。
  */
  set page(
    header: {
        set align(center)
        set text(font: 字体.宋体, size: 字号.小五, lang: "zh")
        set par(first-line-indent: 0pt, leading: 16pt, justify: true)
        show par: set block(spacing: 16pt)

        locate(loc => {
          let next-heading = query(selector(<__heading__>).after(loc), loc)

          // 判断条件较为麻烦，所以单独拆出来写
          // 请注意：`show-heading` 的逻辑中写入了换页操作，因此 heading 有跨页问题。而 label `<__heading__>` 一定在 heading 的尾部。因此，涉及位置的操作，建议使用 `<__heading__>` 定位。 

          /*
          判断当前页是否是一级标题页面
            条件：（满足全部）
              1. 该页页眉后还有 <__heading__>
              2. 下一个 <__heading__> 和 loc 在同一页上，且
              3. 下一个 <__heading__> 是一级标题
            备注：
              `chapter-level-state` 来自 `utils/states.typ`，由 `show-heading` 写入信息
          */
          let cond-loc-page-is-first-level-title-page = {
            next-heading != () and next-heading.first().location().page() == loc.page() and chapter-level-state.at(loc) == 1
          }

          if cond-loc-page-is-first-level-title-page {
            if not first-level-title-page-disable-heading {
              // 注：考虑到“总是在奇数页开启新章节”选项关闭的情况
              //     且本模板是在正文的首个 header 之后才清理页码
              //     故取 <__heading__> 所在位置的页码而不是 loc.page() 
              //     之前的判断条件已经保证 next-heading 不为空了。
              let loc = next-heading.first().location()
              if calc.even(loc.page()) {
                thesisname.heading
              } else {
                let cl1nss = chapter-l1-numbering-show-state.at(loc)
                if not cl1nss in (none, "", [], [ ]){
                  cl1nss
                  h(0.3em)
                }
                chapter-l1-name-str-state.at(loc)
              }
              v(-1em)
              line(length: 100%, stroke: (thickness: 0.5pt))
            }
          } else {
            if calc.even(loc.page()) {
              thesisname.heading
            } else {
              let cl1nss = chapter-l1-numbering-show-state.at(loc)
              if not cl1nss in (none, "", [], [ ]){
                cl1nss
                h(0.3em)
              }
              chapter-l1-name-str-state.at(loc)
            }
            v(-1em)
            line(length: 100%, stroke: (thickness: 0.5pt))
          }
        })
        counter(footnote).update(0)
      },
    numbering: "1",
    header-ascent: 10%,
    footer-descent: 10%
  )

  pagebreak(weak: false)
  

  counter(page).update(1)
  counter(heading.where(level: 1)).update(0)
  part-state.update("正文")

  doc
}