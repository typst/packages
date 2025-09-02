# AbyssBook

一个黑色Typst模板

# 安装

## macOS

`git clone https://github.com/CrossDark/AbyssBook.git "$HOME/Library/Application Support/typst/packages/local/abyss-book/0.2.8"`

# 使用

```typst
#import "@local/abyss-book:0.2.8": *

#show: abyss-book.with(
  // 您作品的标题。
  title: [Your Title],
  // 作者姓名。
  author: "Author",
  // 使用的纸张尺寸。
  paper-size: "a4",
  // 将在封面页显示的日期。
  // 该值需要是 'datetime' 类型。
  // 更多信息: https://typst.app/docs/reference/foundations/datetime/
  // 示例: datetime(year: 2024, month: 03, day: 17)
  date: none,
  // 日期在封面页上显示的格式。
  // 更多信息: https://typst.app/docs/reference/foundations/datetime/#format
  // 默认格式将日期显示为: MMMM DD, YYYY
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  // 您作品的摘要。如果没有，可以省略。
  abstract: none,
  // 前言页的内容。这将显示在封面页之后。如果没有，可以省略。
  preface: none,
  // 调用 `outline` 函数的结果或 `none`。
  // 如果要禁用目录，请将其设置为 `none`。
  // 更多信息: https://typst.app/docs/reference/model/outline/
  table-of-contents: outline(),
  // 在正文之后、参考文献之前显示附录。
  appendix: (
    enabled: false,
    title: "",
    heading-numbering-format: "",
    body: none,
  ),
  // 调用 `bibliography` 函数的结果或 `none`。
  // 示例: bibliography("refs.bib")
  // 更多信息: https://typst.app/docs/reference/model/bibliography/
  bibliography: none,
  // 是否在新页开始章节。
  chapter-pagebreak: true,
  // 是否在外部链接旁边显示一个绛红色圆圈。
  external-link-circle: true,
  // 显示图（图像）的索引。
  figure-index: (
    enabled: false,
    title: "",
  ),
  // 显示表的索引
  table-index: (
    enabled: false,
    title: "",
  ),
  // 显示代码清单（代码块）的索引。
  listing-index: (
    enabled: false,
    title: "",
  ),
)
```

# 更新计划

- [x] 边框花纹: 在页面边缘环绕诡异花纹
- [x] 使用`zh-kit`管理字体
- [x] 排版优化-块缩进: 标题下面对应的文本块相对于标题缩进一格
