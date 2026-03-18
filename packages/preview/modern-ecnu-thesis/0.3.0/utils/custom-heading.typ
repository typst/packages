#import "style.typ": 字号
#import "@preview/hydra:0.5.2": hydra

// 展示一个标题
#let heading-display(it) = {
  if it != none {
    if it.has("numbering") and it.numbering != none {
      numbering(it.numbering, ..counter(heading).at(it.location()))
      h(0.8em)
    }
    it.body
  } else {
    ""
  }
}

// 页眉内容
#let heading-content(
    twoside: false,
    doctype: "master",
    extra: "华东师范大学本科毕业论文",
    reset-footnote: true,
    fonts: (:),
    stroke-width: 0.5pt
  ) = {
  if doctype == "bachelor" {
    set text(font: fonts.宋体, size: 字号.小五)
    set align(center)
    let title = state("title")
    stack(extra + h(1fr) + context title.get(),
    v(0.65em),
    line(length: 100%, stroke: stroke-width + black))
  } else {
    context {
      let page = counter(page).get().at(0)
      // 获取当前页面的一级标题
      let first-level-heading = hydra(1, skip-starting: false)
      let docinfo = "华东师范大学" + if doctype == "master" { "硕士" } else { "博士" } + "学位论文"
      set text(font: fonts.宋体, size: 字号.五号)
      if reset-footnote {
        counter(footnote).update(0)
      }
      if twoside {
        page = here().position().page
      }
      stack(
        if calc.rem(page, 2) == 1 {
          first-level-heading + h(1fr) + docinfo
        } else {
          docinfo + h(1fr) + first-level-heading
        },
        v(0.5em),
        line(length: 100%, stroke: stroke-width + black),
        v(0.15em),
        line(length: 100%, stroke: stroke-width + black),
      )
    }
  }
}