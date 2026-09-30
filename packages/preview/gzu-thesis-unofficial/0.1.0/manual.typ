#import "@preview/tidy:0.4.3"

#set page(height: auto)
#set text(font: ("Times New Roman", "SimSun"), size: 13pt, lang: "zh", region: "cn")
#show strong: set text(font: ("Times New Roman", "SimHei"))
#show heading: set text(font: ("Times New Roman", "SimHei"))
#show heading.where(level: 1): set block(above: 2em, below: 1em)
#set par(first-line-indent: (amount: 2em, all: true), justify: true)
#set list(indent: 2em)
#show link: underline
#show link: set text(fill: blue)

#let gzu-thesis = tidy.parse-module(read("/src/main.typ"))
#let tree-line-table = tidy.parse-module(read("/src/styles/table.typ"))

#align(center, title[「贵州大学本科生毕业论文（设计）」Typst 模板手册])
#outline(depth: 3)

= 介绍
此模板参考《贵州大学毕业论文（设计）管理办法（试行）》（2025 年 4 月）（以下简称「规范」）制作，如需查阅此文件，可在
#link(
  "https://github.com/chengwu26/gzu-thesis/blob/master/assets/贵州大学毕业论文（设计）管理办法（试行）.pdf",
)[代码仓库]
中查看。此模板仅对「规范」中要求的样式进行了预定义，不提供过多额外的内容，在需要时可组合其他包来实现。
*唯一例外的是*，此模板对公式编号采用了“(1-1)”的两级编号模式。

此模板提供的用于创建可跨页表格的接口显得不那么人体工学（见后文关于 `continued-header` 函数的介绍）。但此实现并非强制使用，
你完全可以使用你认为更好的实现。

= 常见问题
下面是截止完成此模板时最新的 Typst 版本 (0.15.0) 仍然存在的一些问题及解决方案：
- 列表文字和序号/符号出现错位，可使用 #link("https://typst.app/universe/package/itemize")[itemize] 包解决。
  关于此问题的描述还可查阅 #link("https://guide.typst.dev/FAQ/fix-enum-list")[修复列表的终极方案] 了解。
- 在源码中的中文换行会导致错误分词并自动在换行处插入空白符，可使用
  #link("https://typst.app/universe/package/cjk-spacer")[cjk-spacer]、
  #link("https://typst.app/universe/package/cjk-unbreak")[cjk-unbreak]、
  #link("https://typst.app/universe/package/remove-cjk-break-space")[remove-cjk-break-space]
  包或
  #link("https://guide.typst.dev/FAQ/chinese-remove-space.html")[写中文文档时，如何去掉源码中换行导致的空格？]
  描述的方案（选其一）。


= 此模板提供的 API
#set par(first-line-indent: 0em)

== 模板函数
用法示例可参考你使用此模板创建的项目目录中的 `main.typ` 文件

#tidy.show-module(
  gzu-thesis,
  omit-private-definitions: true,
  show-outline: false,
)

#v(3em)
== 三线表与可跨页表辅助函数
#tidy.show-module(
  tree-line-table,
  omit-private-definitions: true,
  show-outline: false,
  sort-functions: none,
)
