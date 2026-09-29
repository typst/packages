// ============================================================
// abstract-en.typ — 英文摘要页
// 显示英文标题、作者信息、摘要正文及关键词
// 盲审模式下隐藏作者和导师信息
// ============================================================

#import "const.typ": size

/// 英文摘要页
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
  body,
) = {
  heading(
    numbering: none,
    outlined: false,
    supplement: [#metadata((
      pagebreak: true,
      show-header: true,
      header: "ABSTRACT",
      spacing-before: 24pt,
      spacing-after: 18pt,
      linespacing: 2em,
      font: (size: size.英文摘要标题, font: "Arial", weight: "regular"),
    ))],
  )[#upper(title-en)]

  // Word 模板中正文仍然是 20pt 行距
  // 对于纯英文字体，测试下来 12.5pt 的匹配效果较好
  set par(spacing: 12.5pt, leading: 12.5pt, justify: true)
  if not blind {
    [
      #set align(center)
      #author-en \(#major-en\) \
      Supervised by #supervisor-en
    ]
  }
  // Word 模板中英文摘要的首行缩进固定为 0.74cm
  set par(first-line-indent: 0.74cm, justify: true)
  v(8pt)
  align(center)[#text(font: "Arial", weight: "bold")[ABSTRACT]]
  v(6pt)
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
