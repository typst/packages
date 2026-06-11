// =============================================================================
// 布局辅助模块 (Layout Helpers)
// =============================================================================
// 提供 Tufte 风格布局所需的核心布局元素：
// 1. margin-note — 侧注（显示在页面边距中的注释内容）
// 2. full-width  — 全宽内容（跨越正文区和边距区的宽幅元素）
//
// 基于 tufted (https://github.com/vsheg/tufted), MIT License
// =============================================================================

// TODO: 支持在侧注中放置带标题的图表 (figures with captions inside margin notes)

// -----------------------------------------------------------------------------
// margin-note：创建侧注（边距注释）
// -----------------------------------------------------------------------------
// 侧注是 Tufte 风格的核心特征之一：
// - 在宽屏幕上显示在页面右侧边距中
// - 在窄屏幕（移动端）上则以内联方式显示于正文中
//
// Tufte CSS 通过 CSS 的 float 和负 margin 技术实现此效果
//
// 参数：
//   content - 侧注内容（可以是文本、图片、公式等任意 Typst 内容）
// 返回：<span class="marginnote"> HTML 元素
#let margin-note(content) = context {
  if target() == "html" {
    html.span(class: "marginnote", content)
  } else {
    // PDF 中降级为普通脚注
    footnote(content)
  }
}

// TODO: 实现 <figure class="fullwidth"> 支持
// 可能需要 introspection 机制或等待 Typst 支持 `set html.figure(class: "fullwidth")`

// -----------------------------------------------------------------------------
// full-width：创建全宽内容
// -----------------------------------------------------------------------------
// 全宽内容跨越正文区域和边距区域，适合展示大图、宽表格等
// Tufte CSS 通过 CSS 类 "fullwidth" 控制其宽度
//
// 参数：
//   content - 要全宽显示的内容
// 返回：<div class="fullwidth"> HTML 元素
#let full-width(content) = context {
  if target() == "html" {
    html.div(class: "fullwidth", content)
  } else {
    // PDF 中不做特殊处理，直接原样输出
    content
  }
}
