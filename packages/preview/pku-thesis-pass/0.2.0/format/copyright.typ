// ============================================================
// copyright.typ — 版权声明页
// 使用 front-heading 创建无分页的"版权声明"标题，
// 紧跟封面页之后、摘要之前
// ============================================================

#import "headings.typ": front-heading
#import "const.typ": size

/// 版权声明页
/// 内容为固定的法律声明文字，无参数
#let copyright-page() = {
  set align(left + top)
  set text(size: size.正文)
  front-heading(
    "版权声明",
    pagebreak: false,
    linespacing: size.一级标题 * 1.3 * 2,
    spacing-before: 0pt,
    spacing-after: 0pt,
  )
  linebreak()
  set par(
    first-line-indent: 2em,
    leading: size.正文 * 1.3,
    spacing: size.正文 * 1.3,
  )
  [
    任何收存和保管本论文各种版本的单位和个人，未经本论文作者同意，不得将本论文转借他人，亦不得随意复制、抄录、拍照或以任何方式传播。否则，引起有碍作者著作权之问题，将可能承担法律责任。
  ]
}
