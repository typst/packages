// ============================================================
// 表注和图注模块 (Table and Figure Note Module)
// ============================================================
//
// 本模块提供表格和图片的注释（脚注式说明文字）功能。
// This module provides note/annotation functionality for tables and figures.
//
// 什么是表注/图注 / What are table/figure notes:
// 表注（表格注释）和图注（图片注释）是位于表格或图片下方的补充说明文字，
// 通常用于以下场景：
// Table/figure notes are supplementary text placed below tables or figures,
// commonly used for:
//
// - 数据来源说明（如"数据来源：国家统计局"）
//   Data source attribution (e.g., "Source: National Bureau of Statistics")
// - 统计显著性标记说明（如"* p < 0.05, ** p < 0.01"）
//   Statistical significance markers (e.g., "* p < 0.05, ** p < 0.01")
// - 缩写或专业术语解释
//   Abbreviation or technical term explanations
// - 补充说明信息
//   Supplementary information
//
// 设计特性 / Design Features:
// - 自动宽度匹配：默认宽度与所属表格/图片一致
//   Auto-width matching: default width matches containing table/figure
// - 灵活宽度控制：支持 auto、百分比（ratio）、绝对长度三种宽度模式
//   Flexible width: supports auto, percentage (ratio), and absolute length
// - 语言感知：检测是否需要首行缩进修复
//   Language-aware: detects if indentation fix is needed
// - 样式继承：从全局配置读取样式
//   Style inheritance: reads style from global config
//
// 导出函数 / Exported Functions:
// - captnote(): 表注 / Table note
// - capfnote(): 图注 / Figure note
//
// 依赖 / Dependencies:
// - src/config.typ: 全局配置和辅助函数 / Global config and utilities
//
// ============================================================

#import "config.typ": *

// 内部：统一的 note 渲染函数，处理 auto / ratio / length 三种宽度模式。
// Internal: unified note renderer handling auto / ratio / length width modes.
//
// - config:       note 样式字段来源（含 note-size、note-leading、note-above、note-below、note-justify、lang、after-indent）
// - width:        用户传入的 width 参数（auto / ratio / length）
// - global-width: 全局表/图宽度状态，width 为 auto 时使用（auto / int / ratio / length）
//                 兼容旧 figure-width-config 的 int 形式（自动转 ratio）
// - justify:      用户传入的 justify 参数（auto 或 bool）
// - content:      注释内容
#let _render-note(config, width, global-width, justify, content) = {
  let (_, should-indent) = resolve-lang-indent(config)
  let final-justify = if justify == auto { config.note-justify } else { justify }

  // 解析有效宽度：用户 width 优先，auto 时 fallback 到全局 state；
  // 同时把旧 int 形式（来自 figure-width-config 默认 100，或 0.0.x set-table-width）转成 ratio。
  // Resolve effective width: user width wins; auto → fall back to global state.
  // Convert legacy int (figure-width-config default 100, or 0.0.x set-table-width) to ratio.
  let effective = if width != auto { width } else { global-width }
  let effective = if type(effective) == int { effective * 1% } else { effective }

  // 内层块构造：按需追加首行缩进修复用的前导空间
  // Inner block: optionally prepend leading space for indent-fix languages
  let inner(add-leading-space) = {
    set text(size: config.note-size)
    if add-leading-space and should-indent { v(0.8em) }
    set par(first-line-indent: 0pt, leading: config.note-leading, justify: final-justify)
    content
  }

  block(
    above: config.note-above,
    below: config.note-below,
  )[
    #if effective == auto {
      // ─ auto：占满文本宽，不缩窄 ─
      // ─ auto: full text width, no narrowing ─
      block(width: 100%, inner(true))
    } else if type(effective) == ratio {
      // ─ ratio：按百分比缩窄并居中（pad 加左右相等留白） ─
      // ─ ratio: narrow + center via equal left/right padding ─
      let margin = (100% - effective) / 2
      pad(left: margin, right: margin, block(width: 100%, inner(true)))
    } else {
      // ─ length：绝对宽度，居中显示，无额外前导空间 ─
      // ─ length: absolute width, centered, no leading space ─
      align(center, block(width: effective, inner(false)))
    }
  ]

  // 首行缩进敏感语言需要假段落修复 / Indent-sensitive langs need fake-para fix
  if should-indent { _fakepar }
}

/// 创建表格注释（表注），默认宽度自动匹配 `captab` 表格宽度。
/// Create a table note; default width auto-matches `captab` width.
///
/// - width (auto | ratio | length): 表注宽度 / Note width
/// - justify (auto | bool): 是否两端对齐（auto=使用全局配置）/ Text justification
/// - content (content): 表注内容 / Note content
#let captnote(
  width: auto,
  justify: auto,
  content
) = {
  context {
    let config = table-style-config.get()
    let percent = table-width-config.get()
    _render-note(config, width, percent, justify, content)
  }
}

/// 创建图片注释（图注），从 `figure-style-config` 读取样式，默认宽度自动匹配。
/// Create a figure note; reads style from `figure-style-config`, auto-matches figure width.
///
/// - width (auto | ratio | length): 图注宽度 / Note width
/// - justify (auto | bool): 是否两端对齐 / Text justification
/// - content (content): 图注内容 / Note content
#let capfnote(
  width: auto,
  justify: auto,
  content
) = {
  context {
    let config = figure-style-config.get()
    let percent = figure-width-config.get()
    _render-note(config, width, percent, justify, content)
  }
}
