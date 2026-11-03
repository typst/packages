// ============================================================
// lib/hyperref.typ: 超链接、目录样式、交叉引用
// ============================================================

#import "i18n.typ" as i18n
#import "fonts.typ" as fonts

#let apply(body) = {
  // 超链接颜色（中文论文通常要求黑色，打印时无彩色）
  show link: set text(fill: rgb("#000000"))
  // ref 颜色由主题层统一控制，此处不再覆盖
  body
}

// 辅助函数：生成目录页
#let make-outline(title-override: none, depth: 3) = {
  let title = if title-override != none {
    title-override
  } else {
    i18n.t("table-of-contents")
  }

  let upchei = fonts.get-cjk-sans()

  outline(
    title: align(center, text(size: 16pt, font: upchei, title)),
    depth: depth,
  )
}
