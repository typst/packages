
== Typst 是什么

Typst 是一个现代化的文档排版系统，旨在提供一种更简单、更强大、更灵活的方式来创建高质量的文档。它结合了编程语言的表达能力和传统排版系统的美学，允许用户通过代码来定义文档的结构、样式和内容。

简而言之，它允许你像 Markdown 一样简单地编写文档，同时又能像 LaTeX 一样精细地控制排版效果，并赋予了你编程的能力来实现更复杂的功能。

== 基础语法 <basic-syntax>

以下内容部分改写自 #link("https://github.com/pku-typst/pkuthss-typst/blob/main/doc/ch03-basics.typ")。

Typst 中的标题使用 `=` 表示，其后跟着标题的内容。`=` 的数量对应于标题的级别。例如#[@heading-syntax]中展示了一级、二级和三级标题的写法。

#figure(
  ```typst
  = 一级标题
  == 二级标题
  === 三级标题
  ```,
  caption: "Typst 中的标题语法",
) <heading-syntax>

与 Markdown 类似，在 Typst 中使用成对的 `*` 和 `_` 包裹文本来表示粗体、斜体。 例如，`*粗体*` 会被渲染为*粗体*，而 `_斜体_` 会被渲染为_斜体_。


=== 脚注

Typst 原生支持脚注功能。例如#[@footnote-syntax]所示，效果如#footnote[这是一个脚注。]。

#figure(
  ```typ
  Typst 支持添加脚注#footnote[这是一个脚注。]。
  ```,
  caption: "Typst 中的脚注语法",
) <footnote-syntax>


=== 列表

Typst 支持无序列表和有序列表。无序列表使用 `-` 或 `*` 作为项目符号，而有序列表使用 `+` 作为项目符号。例如#[@list-syntax]所示。

#figure(
  ```typ
  无序列表：
  - 第一项
  - 第二项
    - 嵌套项

  有序列表：
  + 第一步
  + 第二步
  + 第三步
  ```,
  caption: "Typst 中的列表语法",
)<list-syntax>

无序列表：
- 第一项
- 第二项
  - 嵌套项

有序列表：
+ 第一步
+ 第二步
+ 第三步

== 图片

在 Typst 中插入图片使用 `image` 函数。如果需要给图片增加标题或在文章中引用，需要将其放置在 `figure` 中：

#figure(
  ```typ
  #figure(
    image("assets/logo.svg", width: 30%),
    caption: "中国海洋大学校徽",
  ) <logo>
  ```,
  caption: "Typst 中的图片语法",
) <image-syntax>


#figure(
  image("../assets/logo.svg", width: 30%),
  caption: "中国海洋大学校徽",
) <logo>

@logo 展示了中国海洋大学校徽。代码中的 `<logo>` 是图片的标签，可以在文中通过 `@logo` 来引用。


== 表格

Typst 中定义表格使用 `table` 函数。如需标题和引用功能，同样需要将其放置在 `figure` 中。本模板默认使用三线表样式。

*注意*：本模板默认允许表格跨页显示（`show figure: set block(breakable: true)`）。如果不希望某个表格被分割，可以在表格前手动插入 `#pagebreak()` 进行调整。

@table-example 展示了 `table` 的示例效果：

#figure(
  ```typ
  #figure(
    table(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      [左对齐], [居中], [右对齐],
      [4], [5], [6],
      [7], [8], [9],
    ),
  ) <table-example>
  ```,
)

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    [左对齐], [居中], [右对齐],
    [4], [5], [6],
    [7], [8], [9],
  ),
) <table-example>

== 公式

Typst 使用 `$` 包裹数学公式。行间公式前后需要有空格，行间公式会自动编号，并且可以通过标签进行引用。例如#[@math-syntax]所示。

#figure(
  ```typ
  行内公式：$E = m c^2$

  行间公式：
  $ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $ <integral>
  ```,
  caption: "Typst 中的数学公式语法",
) <math-syntax>


行内公式：$E = m c^2$

行间公式：
$ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $ <integral>


@integral 展示了一个积分公式。更多数学公式语法可以参考 #link("https://typst.app/docs/reference/math/", text(blue)[Typst 数学公式文档])。


=== 多行公式

多行公式使用 `\` 换行，使用 `&` 对齐。例如#[@math-multiline-syntax]所示。

#figure(
  ```typ
  $ sum_(k=0)^n k
      &= 1 + 2 + ... + n \
      &= (n(n+1)) / 2 $ <sum>
  ```,
  caption: "Typst 中的多行数学公式语法",
) <math-multiline-syntax>


$
  sum_(k=0)^n k & = 1 + 2 + ... + n \
                & = (n(n+1)) / 2
$ <sum>


=== 常用数学符号

#figure(
  ```typ
  $ frac(a^2, 2) $
  $ vec(1, 2, delim: "[") $
  $ mat(1, 2; 3, 4) $
  $ lim_(x -> 0) sin(x) / x = 1 $
  ```,
)


$ frac(a^2, 2) $
$ vec(1, 2, delim: "[") $
$ mat(1, 2; 3, 4) $
$ lim_(x -> 0) sin(x) / x = 1 $


== 代码块

像 Markdown 一样，可以使用三个反引号插入代码块，并且可以指定语言以启用语法高亮。例如#[@code-block-syntax]所示。

#figure(
  ````typ
  ```python
  def hello():
      print("Hello, world!")
  ```
  ````,
  caption: "Typst 中的代码块语法",
) <code-block-syntax>

```python
def hello():
    print("Hello, world!")
```

而行内代码，如无指定语言的代码片段，则使用单个反引号包裹。例如 `print("Hello, world!")` 会被渲染为等宽字体。如果需要指定行内代码的语言以启用语法高亮，可以使用三个反引号包裹，并在开头指定语言。例如 ```python print("Hello, world!") ``` 会被渲染为带有 Python 语法高亮的行内代码块。

当需要在代码块里使用反引号时，可以通过增加反引号的数量来避免冲突。例如使用四个反引号包裹代码块：

`````typ
````typ
```python
def hello():
    print("Hello, world!")
```
````
`````

如需标题和引用功能，同样需要将其放置在 `figure` 中。

== 参考文献

=== 基本用法

Typst 支持 BibLaTeX 格式的 `.bib` 文件。在文档中引用文献使用 `@` 符号：

#figure(
  ```typ
  可以像这样引用参考文献 @fu2020 @fukushima1982。
  ```,
  caption: "Typst 中的参考文献语法",
) <bibliography-syntax>

可以像这样引用参考文献 @fu2020 @fukushima1982。

使用本模板时，只需在 `project` 函数中配置 `bibliography` 等参数即可。例如：

#figure(
  ```typ
  #show: project.with(
    // ...
    bibliography: read("references.bib"),
    // ...
  )
  ```,
)

*注意：*本模板会将 BibLaTeX 文件中的所有条目都渲染到参考文献列表中，而不管它们是否被文中引用。
