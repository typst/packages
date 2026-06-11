// =============================================================================
// 数学公式渲染模块 (Math Equation Rendering)
// =============================================================================
// 此模块定义了数学公式在 HTML 输出中的渲染规则（show 规则）。
// Typst 默认将数学公式渲染为 SVG 图片，跨越晨昏 将其包装在语义化 HTML 标签中。
//
// 基于 tufted (https://github.com/vsheg/tufted), MIT License
// =============================================================================

// -----------------------------------------------------------------------------
// template-math：数学公式的 show 规则
// -----------------------------------------------------------------------------
// 作为 show 规则应用于文档中的数学公式元素：
// - 设置公式编号格式为 "(1)", "(2)", "(3)"...
// - 为 HTML 输出添加语义化的 role 属性（role="math"），方便 CSS 选择和样式化
// - 非 HTML 输出（如 PDF）保持 Typst 默认行为不变
//
// HTML 输出策略：
// - 行内公式 (block: false) → <span role="math">
// - 块级公式 (block: true)  → <figure role="math">（独占一行的大公式）
//
// 为什么使用 html.frame()？
//   html.frame() 包裹公式的 SVG/HTML 输出，提供独立的渲染边界。
//   对于 HTML 输出，这确保公式内容被正确地封装在 DOM 中。
//
// 参数：
//   content - 待处理的内容（由 show 规则自动传入）
// 返回：应用了公式渲染规则的内容
#let template-math(content) = {
  // 设置公式编号格式为 (1), (2), (3)...
  // 这是 Typsetting 数学公式的标准编号方式
  set math.equation(numbering: "(1)")

  // --- 行内公式 (Block: false) ---
  // 例如：$x^2 + y^2 = z^2$ 这种嵌入在段落中的公式
  show math.equation.where(block: false): it => {
    if target() == "html" {
      // HTML 输出：包装在 <span role="math"> 中
      // role 属性是 ARIA 标准的一部分，提供语义化信息
      html.span(role: "math", html.frame(it))
    } else {
      // PDF 等非 HTML 输出：保持默认行为
      it
    }
  }

  // --- 块级公式 (Block: true) ---
  // 例如：$ x^2 + y^2 = z^2 $ 这种独占一行的独立公式
  show math.equation.where(block: true): it => {
    if target() == "html" {
      // HTML 输出：包装在 <figure role="math"> 中
      // figure 是语义化标签，适合独立展示的数学公式
      html.figure(role: "math", html.frame(it))
    } else {
      // PDF 等非 HTML 输出：保持默认行为
      it
    }
  }

  content
}
