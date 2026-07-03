// ============================================================================
// Modern ZUEL Beamer —— 主入口
// 中南财经政法大学风格 · Typst 演示文稿模板（开题答辩）
// 用户只需： #import "../lib.typ": *
// ============================================================================

// 装配（documentclass 等价物）
#import "src/setup.typ": zuel-beamer

// 页面组件
#import "src/slide.typ": title-slide, outline-slide, section, slide, end-slide

// 内容块
#import "src/block.typ": (
  note-block, definition-block, alert-block,
  example-block, theorem-block, highlight-block,
)

// 补充组件：多栏 / 题注 / 金句 / 编号定理
#import "src/component.typ": (
  cols, fig, quote-block,
  theorem, lemma, corollary, definition-thm,
)

// 分步显示（Polylux 0.4.0 引擎）
#import "src/overlay.typ": uncover, only, one-by-one, item-by-item, later, alternatives

// 设计 token（需要微调外观时可直接取用）
#import "src/theme.typ": color, font, size, layout
