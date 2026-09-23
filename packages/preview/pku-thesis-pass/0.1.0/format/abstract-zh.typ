// ============================================================
// abstract-zh.typ — 中文摘要页
// 使用 front-heading 进入前置部分（part=1, 罗马页码）。
// 显示摘要正文及关键词
// ============================================================

#import "headings.typ": front-heading

/// 中文摘要页
/// keywords-zh: 中文关键词数组，以"关键词："为前缀、顿号分隔
/// first-line-indent: 段落首行缩进
/// body: 摘要正文
#let abstract-page-zh(
  keywords-zh: (),
  first-line-indent: 2em,
  body,
) = {
  set par(leading: 10.5pt, spacing: 10.5pt, justify: true)
  front-heading("摘要", enter-front: true, header: "摘要")
  set par(first-line-indent: first-line-indent)
  body
  v(1fr)
  [关键词：]
  keywords-zh.join("，")
  v(1em)
}
