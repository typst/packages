// ============================================================
// bibliography.typ — 参考文献渲染
// 封装 GB/T 7714 参考文献的两种渲染路径
// ============================================================

#import "../imports.typ": gb7714-bibliography, init-gb7714

/// 原生 bibliography 的 show 规则（override-bib 时使用）
/// 设置五号字、悬挂缩进 1.66em，并提升方括号编号的垂直位置
#let bibliography-show-rule(it, style) = {
  set text(size: style.参考文献内容.size)
  set par(
    leading: style.参考文献内容.leading,
    spacing: style.参考文献内容.para-spacing,
    hanging-indent: style.参考文献内容.悬挂缩进,
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

/// 渲染参考文献
/// 有两条渲染路径：
///   - override-bib=true                    → 完全自定义样式，此处不做任何处理
///   - override-bib=false 且有 bib-content  → 走 gb7714-bilingual（推荐，符合 GB/T 7714）
///   - override-bib=false 且无 bib-content  → 回落 Typst 原生 bibliography + bibliography-show-rule
/// 示例：改用 author-date 风格
///   config(bib-style: "author-date", bib-file: path("ref.bib"))
#let render-bibliography(
  bib-content: none,
  bib-style: "numeric",
  bib-version: "2015",
  bib-cn-first: true,
  bib-pinyin-override: (:),
  override-bib: false,
  style: none,
  body,
) = {
  let use-gb7714 = not override-bib and bib-content != none
  if use-gb7714 {
    let make-bib = () => gb7714-bibliography(
      title: heading(numbering: none)[参考文献],
      full-control: entries => {
        set text(size: style.参考文献内容.size)
        let extra-spacing = if bib-version == "2015" { 1pt } else { 0pt }
        set par(
          leading: style.参考文献内容.leading + extra-spacing,
          spacing: style.参考文献内容.para-spacing + extra-spacing,
          hanging-indent: style.参考文献内容.悬挂缩进,
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
    show metadata.where(value: "thesis-appendix"): _ => make-bib()
    init-gb7714.with(bib-content, style: bib-style, version: bib-version, cn-first: bib-cn-first, pinyin-override: bib-pinyin-override)(body)
    context {
      if query(metadata.where(value: "thesis-appendix")).len() == 0 {
        make-bib()
      }
    }
  } else {
    show bibliography: it => bibliography-show-rule(it, style)
    body
  }
}
