
#import "renderer.typ": *
#import "show-rules.typ": *

/// 核心排版流水线
///
/// 该函数负责控制整个文档的生命周期，按顺序渲染封面、摘要、目录、
/// 正文以及参考文献，并接管全局的字体、缩进、图表公式编号等样式。
///
/// - body (content): 传入的论文正文内容。
/// - cfg (dictionary): 从 `template.typ` 传递过来的完整配置字典，包含 `document`, `meta`, `fonts` 三大板块。
#let pipeline(
  body,
  cfg,
) = {
  // === 1. 封面生命周期 ===
  if cfg.document.cover {
    render-cover-page(cfg)
  }

  // === 2. 摘要/前言生命周期 ===
  if cfg.document.zh-abstract or cfg.document.en-abstract {
    render-abstract-page(cfg, zh-content: cfg.meta.zh-abstract-content, en-content: cfg.meta.en-abstract-content)
  }

  // === 3. 目录页生命周期 ===
  if cfg.document.outline {
    render-outline-page(cfg)
  }

  // === 4. 正文生命周期 ===
  let default-body-font = cfg.fonts.body
  set text(
    font: default-body-font.font,
    size: default-body-font.size,
  )
  set page(
    numbering: "1",
    number-align: center,
  )
  set par(first-line-indent: (amount: 2em, all: true), justify: true)
  set heading(numbering: "1.1")
  set math.equation(numbering: equation-numbering)

  show heading: show-heading.with(cfg)
  show: show-figure
  show math.equation: show-equation
  show ref: show-ref

  // 重置计数
  counter(page).update(1)

  body

  // === 5. 参考文献生命周期 ===
  render-bibliography-page(cfg, bib-path: cfg.meta.bib-path)
}
