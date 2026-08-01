#import "@preview/lightmind:0.1.0": lightmind, frontmatter, mark, kbd, task

// 应用 Lightmind 主题。
// 常用选项：
//   - dark-mode: true       启用暗色主题
//   - font / code-font      自定义正文字体 / 代码字体
//   - allow-page-breaks     是否允许分页（false 输出无限长单页）
#show: doc => lightmind(
  title: "Lightmind 主题文档",
  allow-page-breaks: false,
  // dark-mode: true,
  doc,
)

// 可选：YAML 风格的前置元信息块
#frontmatter(
  title: "Lightmind 主题文档",
  author: "作者",
  date: "2026-05-06",
  tags: ("示例", "主题"),
)

= 一级标题

这是正文。*加粗*、_斜体_、`行内代码`、#kbd[Ctrl] + #kbd[P]、#mark[高亮文本] 以及[链接](https://typst.app)。

== 二级标题

- 列表项一
- 列表项二
  - 嵌套列表项

#task(checked: true)[已完成任务]
#task(checked: false)[待办任务]

#quote(attribution: "tip")[ 主色绿。用于实用建议、最佳实践。 ]

#quote(attribution: "caution")[ 砖红调。危险操作或破坏性变更。 ]

#quote[ 普通引用块。 ]

```rust
fn main() {
    let vibe = "Mountain Forest";
    println!("Welcome to {}", vibe);
}
```

$ E = m c^2 $
