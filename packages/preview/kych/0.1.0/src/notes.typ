// =============================================================================
// 脚注渲染模块 (Footnote Rendering — Sidenotes)
// =============================================================================
// 此模块将 Typst 的标准脚注转换为 Tufte 风格的侧注 (sidenotes)。
// Tufte 风格的核心特征之一是将注释放在页面边距中而非页面底部。
//
// 基于 tufted (https://github.com/vsheg/tufted), MIT License
// =============================================================================

// -----------------------------------------------------------------------------
// template-notes：脚注的 show 规则
// -----------------------------------------------------------------------------
// 将标准脚注渲染为 Tufte 风格的侧注系统：
//
// Tufte 侧注工作原理：
//   1. 正文中出现上标数字（脚注引用标记）
//   2. 对应的完整注释内容显示在页面右侧边距中
//   3. 引用标记和注释内容通过 HTML 锚点链接 (id + href) 双向关联
//   4. 点击数字引用可以跳转到注释，点击注释中的数字可以返回引用处
//
// HTML 结构示意：
//   正文中: <sup class="footnote-ref">
//             <a id="fnref-1" href="#fn-1">1</a>
//           </sup>
//   边距中: <span class="marginnote" id="fn-1">
//             <sup><a href="#fnref-1">1</a></sup> 注释内容...
//           </span>
//
// 悬停交互（由 CSS 控制）：
//   - 悬停脚注引用 → 对应侧注高亮
//   - 悬停侧注     → 对应脚注引用高亮
//
// 参数：
//   content - 待处理的内容（由 show 规则自动传入）
// 返回：应用了脚注渲染规则的内容
#let template-notes(content) = {
  show footnote: it => {
    // 仅在 HTML 输出时转换脚注为侧注
    if target() == "html" {
      // 获取脚注编号：通过 footnote 计数器获取当前脚注的序列号
      // it.numbering 是编号格式（如 "1"），counter(footnote).display() 将其渲染为字符串
      let number = counter(footnote).display(it.numbering)
      // 构建唯一的 HTML ID：
      //   fn-id    = 侧注容器的 ID（用于从引用跳转到侧注）
      //   ref-id   = 引用标记的 ID（用于从侧注跳回引用处）
      let fn-id = "fn-" + number
      let ref-id = "fnref-" + number

      // --- 正文中的数字引用标记 ---
      // <sup class="footnote-ref"> 上标数字链接
      html.sup(class: "footnote-ref", html.a(
        class: "footnote-ref-link",
        href: "#" + fn-id,   // 点击后跳转到侧注
        id: ref-id,          // 接收来自侧注的反向跳转
        number,              // 显示的编号文字
      ))

      // --- 边距中的完整注释内容 ---
      // <span class="marginnote"> 利用 Tufte CSS 的侧注布局
      // 包含一个返回链接（带编号的上标）+ 空格 + 注释正文
      html.span(
        class: "marginnote",
        id: fn-id,           // 接收来自引用的跳转
        html.sup(html.a(class: "footnote-ref-link", href: "#" + ref-id, number)) + [ ] + it.body,
      )
    }
  }
  content
}

