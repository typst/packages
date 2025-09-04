# AbyssBook

一个黑色Typst模板

A dark-themed typst template

基于lib模板<https://github.com/talal/ilm> 使用DeepSeek修改而成

Based on the lib template <https://github.com/talal/ilm> and modified using DeepSeek.

# 安装 Install

本地安装模板,如果在线加载的话可以跳过

Install the template locally. if loading online, you can skip this step.

## macOS

`git clone https://github.com/CrossDark/AbyssBook.git "$HOME/Library/Application Support/typst/packages/local/abyss-book/0.3.0"`

# 使用

```typst
#import "@preview/abyss-book:0.3.0": * // 在线加载 

#import "@local/abyss-book:0.3.0": * // 或从本地加载

#show: abyss-book.with(
  // 您作品的标题。 The title of your work.
  title: [Your Title],
  // 作者姓名。 Author's name.
  author: "Author",
  // 使用的纸张尺寸。 Paper size.
  paper-size: "a4",
  // 将在封面页显示的日期。
  // 该值需要是 'datetime' 类型。
  // 更多信息: https://typst.app/docs/reference/foundations/datetime/
  // 示例: datetime(year: 2024, month: 03, day: 17)
  // The datetime to be displayed on the cover page.
  // This value must be of type 'datetime'.
  // For more information: https://typst.app/docs/reference/foundations/datetime/
  // Example: datetime(year: 2024, month: 03, day: 17)
  date: none,
  // 日期在封面页上显示的格式。
  // 更多信息: https://typst.app/docs/reference/foundations/datetime/#format
  // 默认格式将日期显示为: MMMM DD, YYYY
  // The format in which dates appear on the cover page.
  // More information: https://typst.app/docs/reference/foundations/datetime/#format
  // The default format displays dates as: MMMM DD, YYYY
  date-format: "[month repr:long] [day padding:zero], [year repr:full]",
  // 您作品的摘要。如果没有，可以省略。
  // A summary of your work. If none exists, it may be omitted.
  abstract: none,
  // 前言页的内容。这将显示在封面页之后。如果没有，可以省略。
  // Foreword page content. This will appear after the cover page. If none exists, it may be omitted.
  preface: none,
  // 调用 `outline` 函数的结果或 `none`。
  // 如果要禁用目录，请将其设置为 `none`。
  // 更多信息: https://typst.app/docs/reference/model/outline/
  // The result of calling the `outline` function or `none`.
  // Set to `none` to disable the outline.
  // For more information: https://typst.app/docs/reference/model/outline/
  table-of-contents: outline(),
  // 在正文之后、参考文献之前显示附录。
  // Display appendices after the main text and before the references.
  appendix: (
    enabled: false,
    title: "",
    heading-numbering-format: "",
    body: none,
  ),
  // 调用 `bibliography` 函数的结果或 `none`。
  // 示例: bibliography("refs.bib")
  // 更多信息: https://typst.app/docs/reference/model/bibliography/
  // The result of calling the `bibliography` function or `none`.
  // Example: bibliography("refs.bib")
  // More information: https://typst.app/docs/reference/model/bibliography/
  bibliography: none,
  // 是否在新页开始章节。
  // Whether to start the chapter on a new page.
  chapter-pagebreak: true,
  // 是否在外部链接旁边显示一个绛红色圆圈。
  // Whether to display a crimson circle next to external links.
  external-link-circle: true,
  // 显示图（图像）的索引。
  // Display the index of the image.
  figure-index: (
    enabled: false,
    title: "",
  ),
  // 显示表的索引
  // Display table indexes
  table-index: (
    enabled: false,
    title: "",
  ),
  // 显示代码清单（代码块）的索引。
  // Display the index of the code listing (code block).
  listing-index: (
    enabled: false,
    title: "",
  ),
)
```

# 更新计划 Update Plan

- [x] 边框花纹: 在页面边缘环绕诡异花纹 Border Pattern: An eerie pattern encircles the page's edges.
- [x] 排版优化-块缩进: 标题下面对应的文本块相对于标题缩进一格 Typography Optimization - Block Indentation: Text blocks corresponding to headings are indented one space relative to the heading.
- [x] 修复中文粗体无法显示的问题
