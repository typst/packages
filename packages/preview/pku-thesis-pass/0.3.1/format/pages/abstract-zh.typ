// ============================================================
// abstract-zh.typ — 中文摘要页
// 使用 front-heading 进入前置部分（part=1, 罗马页码）。
// 显示摘要正文及关键词
// ============================================================

#import "../layouts/headings.typ": front-heading

/// 中文摘要页
/// style: 由 style.build(font) 构建的样式字典
/// keywords-zh: 中文关键词数组，以"关键词："为前缀、顿号分隔
/// first-line-indent: 段落首行缩进
/// body: 摘要正文
#let abstract-page-zh(
  keywords-zh: (),
  first-line-indent: 2em,
  style: none,
  body,
) = {
  set par(leading: style.摘要内容.leading, spacing: style.摘要内容.spacing, justify: true)
  front-heading("摘要", enter-front: true, header: "摘要",
    font: (font: style.摘要标题.font, size: style.摘要标题.size, weight: style.摘要标题.weight))
  set par(first-line-indent: first-line-indent)
  body
  v(1fr)
  text(font: style.关键词.font, size: style.关键词.size)[关键词：]
  keywords-zh.join("，")
  v(1em)
}
