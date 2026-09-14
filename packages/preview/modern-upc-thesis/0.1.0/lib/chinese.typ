// ============================================================
// lib/chinese.typ: 中文排版核心
// Word 标准 1.5 倍行距、段落缩进、章节格式、按章编号
// ============================================================

#import "utils.typ" as utils

#let apply(line-spacing: auto, body) = {
  let leading = if line-spacing == auto {
    utils.line-spacing-15
  } else {
    line-spacing
  }

  // ---- 段落设置 ----
  // all: true 确保 heading 后的首段也缩进（中文排版要求）
  set par(
    first-line-indent: (amount: 2em, all: true),
    leading: leading,
    justify: true,
    spacing: leading,
  )

  // ---- 列表缩进 ----
  set list(indent: 2em)
  set enum(indent: 2em)

  // ---- 强制列表、枚举和图表后的段落恢复首行缩进 ----
  // 参考 JLU 模板实现
  show list: it => {
    it
    par[#box()]
  }
  show enum: it => {
    it
    par[#box()]
  }
  show figure: it => {
    it
    par[#box()]
  }

  // ---- 章节编号 ----
  // 一级标题格式由主题覆盖，这里只设置 numbering
  set heading(numbering: utils.ch-numbering)

  body
}
