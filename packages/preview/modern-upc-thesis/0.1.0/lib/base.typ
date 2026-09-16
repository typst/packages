// ============================================================
// lib/base.typ: 基础页面设置（兜底层）
// 主题层通过 set page 覆盖具体边距
// ============================================================

#let apply(
  page-margin: auto,
  fontsize: 12pt,
  font: none,
  body,
) = {
  let margin = if page-margin == auto {
    (x: 2.5cm, y: 2.5cm)
  } else {
    page-margin
  }

  set page(margin: margin)

  // 字体和字号统一在此设置，避免 theme 通过参数传递后
  // 在 show: 规则内 set text(font: ...) 被 Typst 忽略的问题。
  // 注意：不可放在 if 分支内，否则与 set page 共存时会导致 set text 失效。
  set text(font: font, size: fontsize)

  body
}
