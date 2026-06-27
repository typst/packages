// ============================================================================
// 内容块 —— beamer 的 definition / theorem / example / alert 等价物
// 莫兰迪配色，标题栏（深）+ 正文区（浅）。
// ============================================================================

#import "theme.typ": color, font, size, layout

// ---------------------------------------------------------------------------
// 外观参数（置顶）
// ---------------------------------------------------------------------------
#let title-inset = (x: 0.8em, y: 0.4em)
#let body-inset = (x: 0.8em, top: 0.55em, bottom: 0.7em)
#let body-tint = 88% // 正文区底色 = 主色 lighten 此值
#let block-below = 0.9em // 块与下文间距

// ---------------------------------------------------------------------------
// 通用块工厂
// ---------------------------------------------------------------------------
#let _admonition(fill-color, title, body) = block(
  width: 100%,
  below: block-below,
  radius: layout.block-radius,
  clip: true,
  stroke: 0.6pt + fill-color,
  {
    block(
      width: 100%,
      below: 0pt, // 紧贴正文，消除标题栏与正文间的白缝
      fill: fill-color,
      inset: title-inset,
      text(fill: white, font: font.sans, weight: "bold", size: size.small, title),
    )
    block(
      width: 100%,
      fill: fill-color.lighten(body-tint),
      inset: body-inset,
      body,
    )
  },
)

// ---------------------------------------------------------------------------
// 五种语义块（标题可自定义）
// ---------------------------------------------------------------------------
#let note-block(title: "说明", body) = _admonition(color.block-note, title, body)
#let definition-block(title: "定义", body) = _admonition(color.block-definition, title, body)
#let alert-block(title: "注意", body) = _admonition(color.block-alert, title, body)
#let example-block(title: "示例", body) = _admonition(color.block-example, title, body)
#let theorem-block(title: "定理", body) = _admonition(color.block-theorem, title, body)
#let highlight-block(title: "重点", body) = _admonition(color.block-highlight, title, body)
