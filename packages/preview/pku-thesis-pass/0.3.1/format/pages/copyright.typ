// ============================================================
// copyright.typ — 版权声明页
// 使用 front-heading 创建无分页的"版权声明"标题，
// 紧跟封面页之后、摘要之前
// ============================================================

#import "../layouts/headings.typ": front-heading

/// 版权声明页
/// 内容为固定的法律声明文字，无参数
#let copyright-page(style: none) = {
  set align(left + top)
  set text(size: style.正文.size)
  front-heading(
    "版权声明",
    pagebreak: false,
    linespacing: style.章标题.size * style.版权声明.基准倍数 * style.版权声明.linespacing-multiplier,
    spacing-before: 0pt,
    spacing-after: 0pt,
  )
  linebreak()
  set par(
    first-line-indent: 2em,
    leading: style.版权声明.段落行距,
    spacing: style.版权声明.段落行距,
  )
  [
    任何收存和保管本论文各种版本的单位和个人，未经本论文作者同意，不得将本论文转借他人，亦不得随意复制、抄录、拍照或以任何方式传播。否则，引起有碍作者著作权之问题，将可能承担法律责任。
  ]
}
