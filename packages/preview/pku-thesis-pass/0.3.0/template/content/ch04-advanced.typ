#import "@preview/pku-thesis-pass:0.3.0": booktab, code-preview, code-block, eq-block

== 自定义页眉页脚

本模板的页眉页脚通过 `format/layouts/header.typ` 和 `format/layouts/footer.typ` 控制。页眉规则：
- 奇数页显示当前章节标题
- 偶数页显示论文标题（`header-text` 参数）
- 封面区域无页眉

页脚规则：
- 前置部分（摘要、目录等）使用罗马数字
- 正文部分使用阿拉伯数字

== 盲审模式

`config()` 的 `blind` 参数控制盲审模式：

```typ
#let cfg = config(
  blind: true,
  ...
)
```

盲审模式下：
- 封面使用盲审格式，显示盲审编号
- 隐藏作者、导师等个人信息
- 隐藏致谢和原创性声明
- 隐藏成果页
- PDF元数据隐藏作者

也可以通过命令行参数临时切换：

```bash
# 生成盲审版本
typst compile thesis.typ --input blind=true

# 生成正常版本
typst compile thesis.typ --input blind=false
```

== PDF 元数据 <pdf-meta>

模板会自动将论文信息写入 PDF 文档属性（即阅读器中"文件信息 / Document Properties"可查看的元数据）：

- #strong[标题]：取 `title-zh`
- #strong[作者]：取 `author-zh`
- #strong[创建日期]：由 Typst 自动写入编译时间，无需配置

这样导出的 PDF 在系统中按标题、作者归类时更规范，也便于检索：

```typ
#let cfg = config(
  title-zh: "论文中文题目",
  author-zh: "张三",
  ...
)
```

#strong[注意]：盲审模式（`blind: true`）下作者会被隐藏（元数据中不写入作者），仅保留标题，避免在文件属性中泄露个人信息。如需完全匿名，请同时确认封面与正文中不含作者、导师等信息。

== 预览与打印模式

`preview` 参数控制链接文本的显示方式：
- `preview: true`（默认）：链接显示为蓝色，便于电子版阅读
- `preview: false`：链接显示为正常颜色，适合打印

同样支持命令行切换：

```bash
# 生成打印版（链接不着色）
typst compile thesis.typ --input preview=false
```

== 命令行参数汇总

本模板支持以下命令行参数，通过 `--input key=value` 传递：

#booktab(
  columns: (auto, 1fr),
  align: (left, left),
  caption: "支持的命令行参数",
  [*参数*],
  [*说明*],
  [`blind`],
  [盲审模式：`true` 启用，`false` 禁用],
  [`preview`],
  [预览模式：`true` 链接显示蓝色，`false` 正常颜色],
  [`always-start-odd`],
  [章节从奇数页开始：`true` 启用，`false` 禁用],
  [`system`],
  [系统字体方案：`windows`/`macos`/`linux`],
)

```bash
# 组合多个参数示例
typst compile thesis.typ --input blind=true --input preview=false --input system=linux
```

== LaTeX 引用兼容 <latexref>

在 Typst 中，引用使用 `@标签名` 语法，且要求标签与引用完全一致。LaTeX 用户习惯在标签中加类型前缀，例如 `\label{fig:xxx}`、`\ref{fig:xxx}`。本模板的 `use-latexref` 选项可以兼容 LaTeX 这种写法，方便从 LaTeX 迁移的文档直接沿用原有标签，无需逐个改名。

=== 开启方式

在 `config()` 中设置 `use-latexref: true`：

```typ
#let cfg = config(
  ...
  use-latexref: true,
)
```

开启后，带前缀的引用解析失败时会自动剥离前缀重试。下面是一个完整的例子，左边是代码，右边是实际渲染结果：

#code-preview(
  ```typ
  #figure(
    image("../assets/pkulogo.pdf", width: 30%),
    caption: "LaTeX 风格标签示例",
  ) <result>

  如 @fig:result 所示，实验结果...
  ```,
  [
    #figure(
      image("../assets/pkulogo.pdf", width: 30%),
      caption: "LaTeX 风格标签示例",
    ) <result>

    如 @fig:result 所示，LaTeX 风格标签示例...
  ],
)

=== 工作原理

- 引用 `@fig:result` 时，模板先尝试精确查找标签 `fig:result`；
- 若不存在，再尝试剥离前缀 `fig:`，查找标签 `result`；
- 若剥离后仍找不到，则照常报错（与不开启时的原生行为一致）。

因此开启该选项不会影响已存在的引用：标签本来就叫 `<fig:result>` 时，`@fig:result` 会精确匹配，不做剥离。

=== 默认前缀与自定义

默认剥离的前缀为：

```typ
("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:")
```

分别对应图、表、公式、代码、图片、算法。如需增删，用 `latexref-prefixes` 参数覆盖，例如支持中文前缀：

```typ
#let cfg = config(
  use-latexref: true,
  latexref-prefixes: ("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:", "图:", "表:"),
)
```

#strong[注意]：该选项只影响引用（`@`）的解析，不影响图、表、公式的编号样式；编号仍遵循模板规则（如"图 1.1"、"式 (1.1)"）。

== 自定义章节样式

如果需要创建不出现在目录中的章节（如致谢），可以使用：

```typ
#heading(numbering: none, outlined: false)[致谢]
```

如果需要章节出现在目录但无编号（如参考文献），可以使用：

```typ
#heading(numbering: none, outlined: true)[参考文献]
```

== 使用 `include` 拆分文件

对于较长的论文，可以将各部分内容拆分到单独的文件中，使用 `include` 引入：

```typ
= 快速开始 <quickstart>

#include "content/ch01-quickstart.typ"
```

== 页面调用顺序

本模板采用 DI（依赖注入）模式，`config()` 返回一组页面函数与工具值，用户在 `thesis.typ` 中自行编排调用顺序。推荐顺序如下：

#booktab(
  columns: (auto, 1fr),
  align: (left, left),
  caption: "推荐页面调用顺序",
  [*顺序*],
  [*调用*],
  [1],
  [`#show: cfg.setup` 页面设置（字号、行距、页眉页脚、show 规则）],
  [2],
  [`#(cfg.cover)()` 封面（按 `blind` 自动选择正常/盲审版）],
  [3],
  [`#(cfg.copyright)()` 版权声明页],
  [4],
  [`#(cfg.abstract-zh)(...)` / `#(cfg.abstract-en)(...)` 中英文摘要],
  [5],
  [`#(cfg.outline)()` 中文目录],
  [6],
  [`#(cfg.list-of-figures)()` / `#(cfg.list-of-tables)()` / `#(cfg.list-of-equations)()` / `#(cfg.list-of-code)()` 各列表（按需）],
  [7],
  [`#(cfg.notation)[...]` 主要符号对照表（按需）],
  [8],
  [`#show: cfg.body-wrap` + 正文章节内容],
  [9],
  [`#show: cfg.bibliography` 参考文献（也可在正文中按需引用）],
  [10],
  [`#(cfg.appendix)()` 开始附录，之后章节编号切换为字母格式],
  [11],
  [`#(cfg.achievement)[...]` 攻读学位期间发表的论文（按需）],
  [12],
  [`#(cfg.acknowledgements)[...]` 致谢],
  [13],
  [`#(cfg.declaration)()` 原创性声明],
)

上述顺序与示例 `thesis.typ` 完全一致，可直接参照其编排。

== 组件与辅助函数参考

`config()` 返回若干页面函数、工具值，同时模板还导出一组可直接导入的组件。

=== config() 返回的页面函数

- `setup(body)`：页面设置（字号、行距、页眉页脚、show 规则），作为 `#show: cfg.setup` 调用
- `cover()`：生成封面（根据 `blind` 自动选择正常/盲审版）
- `copyright()`：版权声明页
- `abstract-zh` / `abstract-en`：中英文摘要
- `outline()`：中文目录
- `list-of-figures()` / `list-of-tables()` / `list-of-code()` / `list-of-equations()`：插图/表格/代码/公式列表
- `notation(body)`：主要符号对照表（`/ 符号: 说明` 语法，空行分组）
- `achievement(body)`：攻读学位期间发表的论文（`+` 条目自动编号，作者姓名加粗）
- `body-wrap(body)`：正文段落样式，作为 `#show: cfg.body-wrap` 调用
- `bibliography(body)`：参考文献渲染，作为 `#show: cfg.bibliography` 调用
- `acknowledgements(body)`：致谢
- `declaration()`：原创性声明
- `appendix()`：开始附录部分，后续章节编号切换为字母格式

=== config() 返回的工具值

- `font`：解析后的字体方案字典，可直接用于自定义页面（如 `#set text(font: font.仿宋)`）
- `smartpagebreak`：智能分页函数（支持 `always-start-odd`）
- `first-line-indent`：首行缩进值（供自定义页面使用）
- `blind` / `preview` / `always-start-odd`：当前配置值，可由 `--input` CLI 参数覆盖

=== 可直接导入的组件

模板导出了 `booktab`、`as-booktab`、`eq-block`、`code-block` 等组件，用法示例见 @basics，以下为各组件说明与 API：

```typ
#import "@preview/pku-thesis-pass:0.3.0": booktab, as-booktab, eq-block, code-block
```

- `#booktab(...)`：生成三线表，第一行自动加粗为表头，支持 `outlined: false` 生成纯表格
- `#as-booktab(table)`：将原生 `table` 装饰为三线表样式，便于和 `figure` 组合使用
- `#eq-block(...)`：生成带标题和编号的可引用公式
- `#code-block(...)`：生成带标题和编号的可引用代码块

==== booktab — 三线表

`booktab` 从零创建学术三线表，第一行位置参数自动作为表头（加粗），支持 `figure` 包装和 `@label` 引用：

```typ
#booktab(
  columns: (1fr, 1fr, 1fr),
  caption: [实验数据],
  [组别], [数值], [备注],
  [A], [1.0], [对照组],
  [B], [2.5], [实验组],
)
```

- `caption`：表格标题，省略时不编号
- `outlined: false`：不包装为 `figure`，生成纯表格
- 其他命名参数（`columns`、`align` 等）透传给 `table`

==== as-booktab — 表格装饰器

`as-booktab` 将现有原生 `table` 装饰为三线表，自动识别 `table.header` 或前 N 个单元格作为表头。更适合与 `figure` 组合，易被格式化工具整理：

```typ
#figure(
  as-booktab(table(
    columns: (1fr, 1fr, 1fr),
    table.header([左对齐], [居中], [右对齐]),
    [4], [5], [6],
    [7], [8], [9],
  )),
  caption: [三线表示例],
  kind: table,
) <my-table>
```

若 table 已包含 `table.hline`，则仅包裹不修改，保留手动样式。

==== eq-block — 公式自动编号

`eq-block` 将行间公式包装为带标题的可引用 `figure(kind: "equation")`，支持公式目录。下面左边是代码，右边是实际渲染结果：

#code-preview(
  ```typ
  #eq-block(caption: [勾股定理])[
    $ a^2 + b^2 = c^2 $
  ] <eq-pythagoras>

  如 @eq-pythagoras 所示，两条直角边的平方和等于斜边平方。
  ```,
  [
    #eq-block(caption: [勾股定理])[
      $ a^2 + b^2 = c^2 $
    ] <eq-pythagoras>

    如 @eq-pythagoras 所示，两条直角边的平方和等于斜边平方。
  ],
)

使用要点：

- 省略 `caption` 时原样返回公式，不编号、不入公式目录
- 使用公式目录时，所有需要编号的公式应统一用 `eq-block`，避免与普通 `$ ... $` 的计数器冲突
- 不需要编号的公式可用 `#math.equation($...$, numbering: none, block: true)`

==== code-block — 代码块

`code-block` 包装 raw 为带标题的可自动引用 `figure(kind: "code")`。同理，左边是代码，右边是实际渲染结果：

#code-preview(
  ````typ
  #code-block(
    ```python
    def fibonacci(n):
        if n <= 1:
            return n
        return fibonacci(n-1) + fibonacci(n-2)
    ```,
    caption: [斐波那契数列],
  ) <fib2>

  如 @fib2 所示，斐波那契数列可用递归实现。
  ````,
  [
    #code-block(
      ```python
      def fibonacci(n):
          if n <= 1:
              return n
          return fibonacci(n-1) + fibonacci(n-2)
      ```,
      caption: [斐波那契数列],
    ) <fib2>

    如 @fib2 所示，斐波那契数列可用递归实现。
  ],
)

省略 `caption` 则只显示代码，无标题无编号、不入图列表、不可被 `@` 引用。
