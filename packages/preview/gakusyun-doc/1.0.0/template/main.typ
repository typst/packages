#import "@preview/gakusyun-doc:1.0.0": *

// 设置模板参数
#show: docu.with(
  title: "伽库噚文字模板",
  author: "Gakusyun",
  show-title: true,
  title-page: false,
  blank-page: true,
  show-index: true,
  index-page: false,
  column-of-index: 1,
  cjk-font: "Source Han Serif",
  emph-cjk-font: "FandolKai",
  latin-font: "New Computer Modern",
  mono-font: "Maple Mono NF",
  default-size: "小四",
  lang: "zh",
  region: "cn",
  paper: "a4",
  date: datetime.today().display("[year]年[month]月[day]日"),
  numbering: "第1页 共1页",
  column: 2,
)

= 伽库噚文字模板

这是一个基于Typst的文档模板，支持高度自定义的排版样式。

= 主要特点

- 可自定义字体
- 自动生成目录
- 响应式布局
- 支持超链接

= 使用方法

== 中文排版

直接输入中文即可，模板会自动处理中文排版格式，包括首行缩进等。

== 英文排版

对于大段英文文字，建议使用 `#en()` 函数来确保正确的排版：

```typst
#en("This is an example of English text with proper formatting.")
```

效果为：
#en("This is an example of English text with proper formatting.")

== 字体自定义

您可以在文档开头修改以下参数来自定义字体：

```typst
#let cjk-font = "你的中文字体"
#let emph-cjk-font = "你的强调中文字体"
#let latin-font = "你的西文字体"
#let mono-font = "你的等宽字体"
```

== 超链接

模板支持超链接，使用斜体加下划线样式：

#link("https://bilibili.com")[BiliBili]
#link("https://ys.mihoyo.com")[原神]

== 代码显示

使用反引号显示 `inline code`，或者使用代码块：

```typst
// 这是一个代码块示例
#let example = "Hello, Typst!"
```

= 自定义选项

模板支持多种自定义选项，您可以在 `show: docu.with()` 中修改：

- `title-page`: 是否创建独立标题页
- `blank-page`: 标题页后是否添加空白页
- `show-index`: 是否显示目录
- `column`: 正文列数（1或2）
- `paper`: 纸张大小（a4, a5, letter等）
- `default-size`: 默认字号
