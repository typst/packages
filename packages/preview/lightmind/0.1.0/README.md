## 简介

Lightmind 是一个山林森林绿调的中文文档主题，由同名 Typora 主题改写而来。米黄纸面承托文字、深海军蓝代码块、圆角公式卡片，支持亮色 / 暗色双模式，以及 Markdown 风格排版：YAML 前置元信息、GitHub 风格警告块、任务列表、键位样式等。

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="lightmind-dark.png">
  <img alt="Lightmind 亮色 / 暗色预览" src="lightmind-light.png">
</picture>

## 使用

用模板初始化一个新项目：

```bash
typst init @preview/lightmind:0.1.0
```

或在已有文档中引入主题：

```typst
#import "@preview/lightmind:0.1.0": lightmind, frontmatter, mark, kbd, task

#show: doc => lightmind(
  title: "我的文档",
  // dark-mode: true,   // 暗色主题
  doc,
)
```

## 选项

| 参数 | 说明 | 默认值 |
| --- | --- | --- |
| `title` | 文档标题（居中大标题），`none` 则不显示 | `none` |
| `dark-mode` | 是否启用暗色主题 | `false` |
| `font` | 正文字体（回退链） | `("LXGW WenKai", "Source Han Serif SC")` |
| `code-font` | 代码字体（回退链） | `("Cascadia Code", "LXGW WenKai")` |
| `show-code-lang` | 是否显示代码块语言标签 | `true` |
| `allow-page-breaks` | 是否允许分页；`false` 时输出为无限长单页 | `true` |

## 辅助函数

- `#frontmatter(title: ..., author: ..., date: ..., tags: (...))`：YAML 风格元信息块
- `#mark[...]`：高亮文本
- `#kbd[...]`：键位样式
- `#task(checked: true)[...]`：任务列表项
- `#quote(attribution: "note" | "tip" | "important" | "warning" | "caution")[...]`：GitHub 风格警告块

示例：

```typst
#frontmatter(
  title: "Lightmind 主题演示",
  author: "SunMoonTrain",
  date: "2026-05-06",
  tags: ("theme", "markdown", "demo"),
)

#quote(attribution: "tip")[ 主色绿。用于实用建议、最佳实践。 ]

#task(checked: true)[写主题大纲]
#task(checked: false)[跨平台测试]
```

## 完整效果

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="test_lightmind_dark.png">
  <img alt="Lightmind 完整功能演示" src="test_lightmind_light.png">
</picture>

## 许可证

MIT License，Copyright (c) 2026 SunMoonTrain。
