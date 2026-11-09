#import "@preview/touying:0.8.0": *
#import "@preview/sdu-smpl-slides:0.1.0": *

#show: sdu-theme.with(config-info(
  title: [sdu-smpl-slides],
  subtitle: [template example based on touying],
  author: [山东大学计算机学院 刁程明],
  institution: [#link("mailto:xmdjy703@gmail.com")[xmdjy703\@gmail.com]],
  date: datetime.today(),
))

#title-slide()

#outline-slide()

= Typst 简介

== 用文本编写演示文稿

*Typst* 将标记语法、数学排版和可编程样式结合在一起。

- 用标题、列表和公式描述内容，编译得到 PDF。
- 用函数和样式规则统一字体、颜色与页面布局。
- 源文件是纯文本，便于版本管理和复用。

本模板基于 *Touying* 组织幻灯片，提供山东大学主题样式。

== 常用标记语法

#grid(
  columns: (1fr, 1fr),
  gutter: 1.2cm,
  [
    *源代码*
    ```typst
    *重点内容*
    _强调文字_
    - 无序列表
    + 有序列表
    $x^2 + y^2$
    ```
  ],
  [
    *排版效果*

    *重点内容*，_强调文字_

    - 无序列表
    + 有序列表

    行内公式：$x^2 + y^2$
  ],
)

= 模板使用教程

== 从示例开始

+ 从模板创建项目，修改生成的 `main.typ`。
+ 在 `config-info` 中填写标题、副标题、作者、单位和日期。
+ 用一级标题组织章节，用二级标题创建内容页。
+ 在生成的项目目录编译，打开 PDF 检查版面。

```sh
typst compile main.typ example.pdf
```

== 配置封面

文件开头导入主题，再通过 `config-info` 填写报告信息。

```typst
#import "@preview/touying:0.8.0": *
#import "@preview/sdu-smpl-slides:0.1.0": *
#show: sdu-theme.with(config-info(
  title: [报告标题],
  subtitle: [报告副标题],
  author: [作者姓名],
  institution: [学院或单位],
  date: datetime.today(),
))
#title-slide()
```

== 组织章节与页面

目录自动收集一级标题；每个二级标题开始一张内容页。

```typst
#outline-slide()
= 第一章
== 第一张内容页
这里填写正文。
== 第二张内容页
这里继续介绍。
== 致谢 <touying:unoutlined>
#end-slide()
```

= 功能展示

== 文字与列表

正文支持 *重点强调*、_斜体_ 和 #highlight(fill: rgb("#FFF0A8"))[背景高亮]。

#grid(
  columns: (1fr, 1fr),
  gutter: 1.2cm,
  [
    *无序列表：梳理要点*
    - 红色圆点作为标记
    - 支持中文与英文内容
    - 用缩进组织下级内容
  ],
  [
    *有序列表：描述步骤*
    + 定义问题
    + 设计方法
    + 分析结果
  ],
)

== 表格：对比实验结果

#figure(
  table(
    columns: (2fr, 1fr, 1fr),
    align: (left, center, center),
    inset: (x: 18pt, y: 10pt),
    table.header([*方法*], [*准确率*], [*耗时 / s*]),
    [基线方法], [82.1%], [12.4],
    [改进方法], [*87.6%*], [*9.8*],
  ),
  caption: [方法对比（演示数据）],
)

```typst
#figure(table(columns: 3,
  table.header([方法], [准确率], [耗时]),
  [基线方法], [82.1%], [12.4 s],
), caption: [方法对比])
```

== 数学公式：行内与独立公式

行内公式与正文一起排版，例如 $a^2 + b^2 = c^2$。

```typst
行内公式：$a^2 + b^2 = c^2$
独立公式：$ L = 1/n sum_(i=1)^n (y_i - hat(y)_i)^2 $
```

$ L = 1/n sum_(i=1)^n (y_i - hat(y)_i)^2 $

== 数学公式：矩阵与多行对齐

```typst
$ A = mat(1, 2; 3, 4) $
$ f(x) &= (x + 1)^2 \
       &= x^2 + 2x + 1 $
```

$ A = mat(1, 2; 3, 4) $

$ f(x) &= (x + 1)^2 \
       &= x^2 + 2x + 1 $


链接使用蓝灰色等宽字体；邮箱地址使用 `mailto:` 前缀。

== 文献引用：作者与年份

括号引用：机器学习可以从经验中改进模型表现。@mitchell1997

句内引用：#cite(<mitchell1997>, form: "prose") 系统介绍了机器学习方法。

多作者引用：深度学习使用多层表示学习。@goodfellow2016

```typst
@mitchell1997
#cite(<mitchell1997>, form: "prose")
@goodfellow2016
```

== 管理文献数据

将 BibTeX 条目保存在同目录的 `references.bib` 中，使用条目键引用。

```bib
@book{mitchell1997,
  author = {Mitchell, Tom M.},
  title = {Machine Learning},
  year = {1997},
  publisher = {McGraw-Hill}
}
```

在参考文献页插入以下代码，自动生成已引用文献列表：

```typst
#bibliography("references.bib", title: none)
```

== 代码插入

```python
def mean(values):
    return sum(values) / len(values)

print(mean([1, 2, 3]))
```


== 参考文献

#bibliography("references.bib", title: none)

== 致谢 <touying:unoutlined>

#end-slide()
