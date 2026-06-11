// =============================================================================
// 交叉引用渲染模块 (Cross-Reference Rendering)
// =============================================================================
// 此模块自定义了 Typst 中 @reference 交叉引用的 HTML 输出格式。
// 使得引用公式和标题时产生更干净、更适合网页的链接格式。
//
// 基于 tufted (https://github.com/vsheg/tufted), MIT License
// =============================================================================

// -----------------------------------------------------------------------------
// template-refs：交叉引用的 show 规则
// -----------------------------------------------------------------------------
// 覆盖默认的引用渲染方式：
//
// 1. 公式引用（如 @eq-label）
//    → 渲染为可点击的编号链接，如 "(1)", "(2)"
//    使用 numbering() 函数还原公式编号格式
//
// 2. 标题引用（如 @section-label）
//    → 渲染为带智能引号的标题文字，如 "引言"
//    使用 smartquote() 添加适合当前语言的引号
//
// 3. 其他引用（如图表引用 @fig-label）
//    → 保持 Typst 默认行为不变
//
// 参数：
//   content - 待处理的内容（由 show 规则自动传入）
// 返回：应用了引用渲染规则的内容
#let template-refs(content) = {
  show ref: it => {
    // 创建别名，简化代码
    let eq = math.equation   // 公式元素类型
    let el = it.element      // 引用目标元素

    // --- 公式引用 ---
    // 如果引用目标是一个数学公式 (math.equation)
    if el != none and el.func() == eq {
      // 覆盖公式引用的默认渲染：
      //   el.location()  — 公式在文档中的位置
      //   el.numbering   — 公式的编号格式（如 "(1)"）
      //   counter(eq).at(el.location()) — 该公式的计数值
      //   numbering() 将编号格式和计数值合并，生成 "(1)" 这样的字符串
      //   link() 将编号变成可点击的超链接，指向公式位置
      return link(el.location(), numbering(
        el.numbering,
        ..counter(eq).at(el.location()),
      ))
    }

    // --- 标题引用 ---
    // 如果引用目标是标题 (heading)
    if el != none and el.func() == heading {
      // 渲染为：智能引号 + 标题文字 + 智能引号
      // 例如：@intro 变成 "引言"
      // smartquote() 会根据文档语言 (lang) 自动选择合适的引号样式
      return smartquote() + it.element.body + smartquote()
    }

    // --- 其他引用 ---
    // 图表引用、表格引用等保持默认行为
    it
  }

  content
}
