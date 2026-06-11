// =============================================================================
// 图表渲染模块 (Figure Rendering)
// =============================================================================
// 此模块自定义图表（figure）在 HTML 输出中的渲染方式。
// 核心特性：将图表标题移到页面边距中（侧注位置），而不是放在正文底部。
//
// 基于 tufted (https://github.com/vsheg/tufted), MIT License
// =============================================================================

// 导入 margin-note 辅助函数（虽然此模块未直接使用，但保留以供将来扩展）
#import "layout.typ": margin-note

// -----------------------------------------------------------------------------
// template-figures：图表的 show 规则
// -----------------------------------------------------------------------------
// 对图表元素应用两个 show 规则：
//
// 1. figure.caption（图表标题）→ 包装在 <span class="marginnote"> 中
//    将标题从图表下方移到页面边距中，符合 Tufte 风格
//
// 2. figure（图表整体）→ 重新排列子元素顺序
//    在 HTML 输出中，将标题放在图片之前（而不是之后）
//    这样标题可以先出现在 DOM 中，实现侧注效果
//
// 参数：
//   content - 待处理的内容（由 show 规则自动传入）
// 返回：应用了图表渲染规则的内容
#let template-figures(content) = {
  // --- 图表标题渲染 ---
  // 将 figure.caption 的内容渲染为侧注格式
  // it.supplement  = 图表类型前缀，如 "图" (Fig.)
  // it.counter.display() = 编号，如 "1"
  // it.separator   = 分隔符，如 ": " 或 ". "
  // it.body        = 标题文字
  // 例如最终输出："图 1: 凤头潜鸭的插图"
  show figure.caption: it => html.span(
    class: "marginnote",
    it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body,
  )

  // --- 图表整体重排 ---
  // 重新定义 figure 元素的渲染顺序
  // 仅在 HTML 输出中生效，PDF 输出保持默认
  show figure: it => if target() == "html" {
    html.figure({
      // 先输出标题（让其出现在侧注位置）
      it.caption
      // 再输出图片本身（作为正文内容）
      it.body
    })
  }

  content
}
