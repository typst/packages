// ============================================================
// abstract-en.typ — 英文摘要页
// 显示英文标题、作者信息、摘要正文及关键词
// 盲审模式下隐藏作者和导师信息
// ============================================================

#import "../layouts/headings.typ": front-heading

/// 英文摘要页
/// style: 由 style.build(font) 构建的样式字典
/// title-en: 英文论文题目（自动 upper 全大写）
/// author-en / major-en / supervisor-en: 作者姓名、专业、导师（盲审时隐藏）
/// keywords-en: 英文关键词数组，以 "KEY WORDS:" 为前缀
/// blind: 盲审模式开关
/// body: 摘要正文
#let abstract-page-en(
  title-en: none,
  author-en: none,
  major-en: none,
  supervisor-en: none,
  keywords-en: (),
  blind: false,
  style: none,
  body,
) = {
  front-heading(
    upper(title-en),
    header: "ABSTRACT",
    spacing-before: style.英文题目.spacing-before,
    spacing-after: style.英文题目.spacing-after,
    linespacing: style.英文题目.linespacing,
    font: (size: style.英文题目.size, font: style.英文题目.font, weight: style.英文题目.weight),
  )

  // 英文摘要内容已有样式调整（leading 12.5pt 较 PKU 标准 20pt 更接近 Word）
  set par(spacing: style.英文摘要内容.leading, leading: style.英文摘要内容.leading, justify: true)
  if not blind {
    [
      #set text(font: style.英文作者信息.font, size: style.英文作者信息.size)
      #set align(center)
      #author-en \(#major-en\) \
      Supervised by #supervisor-en
    ]
  }
  // Word 模板中英文摘要的首行缩进固定为 0.74cm
  set par(first-line-indent: style.英文摘要内容.first-line-indent, justify: true)
  v(style.英文摘要标题.spacing-before)
  align(center)[#text(font: style.英文摘要标题.font, size: style.英文摘要标题.size, weight: style.英文摘要标题.weight)[ABSTRACT]]
  v(style.英文摘要标题.spacing-after)
  body
  v(1fr)
  let keyword-prefix = if keywords-en.len() == 1 {
    "KEY WORD: "
  } else {
    "KEY WORDS: "
  }
  [#keyword-prefix]
  keywords-en.join(", ")
  v(1em)
}
