// ============================================================
// bibliography.typ — 参考文献渲染
// 封装 GB/T 7714 参考文献的两种渲染路径
// ============================================================

#import "const.typ": size
#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography, init-gb7714

/// 原生 bibliography 的 show 规则（override-bib 时使用）。
/// 设置五号字、悬挂缩进 1.66em，并提升方括号编号的垂直位置。
#let bibliography-show-rule(it) = {
  set text(size: size.参考文献正文)
  set par(
    leading: 6.5pt,
    spacing: 6.5pt + 3pt,
    hanging-indent: 1.66em,
    first-line-indent: 0em,
  )
  show regex("\\[\\d+\\]"): it => {
    box[
      #it
      #v(-8.5pt)
    ]
  }
  it
}

/// 渲染参考文献。
/// 非 override-bib 且有 bib-content 时：通过 gb7714-bilingual 处理 doc 全文。
/// 否则回落为 Typst 原生 bibliography 加 show 规则。
#let render-bibliography(
  bib-content: none,
  bib-style: "numeric",
  bib-version: "2015",
  bib-cn-first: true,
  bib-pinyin-override: (:),
  override-bib: false,
  body,
) = {
  let use-gb7714 = not override-bib and bib-content != none
  if use-gb7714 {
    let make-bib = () => gb7714-bibliography(
      title: heading(numbering: none)[参考文献],
      full-control: entries => {
        set text(size: size.参考文献正文)
        let extra-spacing = if bib-version == "2015" { 1pt } else { 0pt }
        set par(
          leading: 6.5pt + extra-spacing,
          spacing: 6.5pt + 3pt + extra-spacing,
          hanging-indent: 1.66em,
          first-line-indent: 0em,
          justify: true,
        )
        if bib-style == "author-date" {
          for e in entries [#e.labeled-rendered #parbreak()]
        } else {
          for e in entries [
            [#e.order]
            #e.labeled-rendered
            #parbreak()
          ]
        }
      },
    )
    show metadata.where(value: "pkuthss-appendix"): _ => make-bib()
    init-gb7714.with(bib-content, style: bib-style, version: bib-version, cn-first: bib-cn-first, pinyin-override: bib-pinyin-override)(body)
    context {
      if query(metadata.where(value: "pkuthss-appendix")).len() == 0 {
        make-bib()
      }
    }
  } else {
    show bibliography: it => bibliography-show-rule(it)
    body
  }
}
