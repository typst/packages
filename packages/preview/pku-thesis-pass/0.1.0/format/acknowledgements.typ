// ============================================================
// acknowledgements.typ — 致谢页
// 使用 back-heading 生成无编号标题，在参考文献之后出现
// ============================================================

#import "headings.typ": back-heading

/// 致谢页。
/// first-line-indent: 段落首行缩进。
/// acknowledgements: 致谢正文（body 参数）。
#let acknowledgements-page(first-line-indent: 2em, acknowledgements) = {
  back-heading("致谢")
  set par(
    first-line-indent: first-line-indent,
    leading: 10.5pt,
    spacing: 10.5pt,
  )
  acknowledgements
}
