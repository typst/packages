// =============================================================================
// 文档：嵌入 Markdown (Embedding Markdown)
// =============================================================================
// 演示如何将外部 Markdown 文件嵌入 Typst 文档中渲染。
// 使用 cmarker 包解析 Markdown，mitex 包渲染数学公式。
// =============================================================================

#import "../index.typ": template, kych
// cmarker: CommonMark (Markdown) 解析器，将 Markdown 转为 Typst 内容
#import "@preview/cmarker:0.1.8"
// mitex: LaTeX 数学公式渲染器，用于处理 Markdown 中的数学公式
#import "@preview/mitex:0.2.6": mitex
#show: template

= 嵌入 Markdown

// 使用 cmarker 和 mitex 的组合来实现完整的 Markdown 嵌入
你可以使用 `cmarker` 将 Markdown 内容嵌入 Typst 文档中。当需要将现有的 Markdown 文件纳入基于 Typst 的网站时，这特别有用。要渲染数学表达式，请使用 `mitex`。

// 完整的代码示例
```typst

#import "../index.typ": template, kych
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.7": mitex
#show: template

// 读取 Markdown 文件内容
#let md-content = read("tufted-titmouse.md")

// 定义 Markdown 语法的自定义处理规则
// 这里重定义了图片语法 ![]() 的处理方式
#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source,
    alt: alt,       // 替代文本（无障碍）
    format: format, // 图片格式
  )),
)

// 渲染 Markdown：
//   math: mitex → 使用 mitex 处理 Markdown 中的数学公式
//   scope: def-dict → 使用自定义的 scope 覆盖默认语法处理
#cmarker.render(md-content, math: mitex, scope: def-dict)
```

// --- 实际渲染示例 ---
// 下方内容由 Markdown 文件 tufted-titmouse.md 渲染生成
以下是来自 Markdown 文件的渲染内容：


// 读取 Markdown 文件
#let md-content = read("tufted-titmouse.md")

// 图片语法的自定义处理
#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source,
    alt: alt,
    format: format,
  )),
)

// 渲染 Markdown 内容
#cmarker.render(md-content, math: mitex, scope: def-dict)
