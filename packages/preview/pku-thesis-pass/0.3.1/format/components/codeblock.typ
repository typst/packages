// ============================================================
// codeblock.typ — 代码块组件
// 提供带标题、可编号引用的代码块：code-block
// ============================================================

/// 代码块组件
/// raw: 由 ``` 标记的 raw 代码块
/// caption: 代码标题（可选，有标题时可被 @label 引用）
/// 省略 caption 时仅显示代码，不编号、不入列表、不可引用
#let code-block(raw, caption: none) = {
  if caption != none {
    figure(
      {
        set align(left)
        raw
      },
      caption: caption,
      kind: "code",
      supplement: "",
    )
  } else {
    raw
  }
}
