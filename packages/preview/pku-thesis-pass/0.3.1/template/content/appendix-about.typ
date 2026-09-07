#import "@preview/pku-thesis-pass:0.3.1": as-booktab, code-block, eq-block

撰写学位论文是每个研究生必须完成的功课。在 LaTeX 还是 Typst 的选择上，过去几年我们几乎没有悬念——LaTeX 是唯一的专业排版工具。然而，Typst 的出现正在改变这个局面。

Typst 是一个现代化的排版系统，相比 LaTeX 有诸多优势：

- _编译速度极快_：毫秒级增量编译，实时预览丝滑流畅
- _语法更直观_：不像 LaTeX 那样有大量反斜杠和宏包，Typst 的语法接近现代编程语言
- _包管理器内置_：`@preview/xxx` 可以直接在文档中引用，无需手动安装宏包
- _Unicode 优先_：原生支持中文等非拉丁文字，无需额外配置

北京大学学位论文 Typst 模板（pku-thesis-pass）致力于让排版变得简单。本模板基于 pkuthss-typst 重构而来，采用 DI（依赖注入）模式，用户可以通过 `config()` 函数获取各个页面组件的闭包，自行编排论文结构，而不是被固定的模板流程所限制。

本文档是模板的使用指南，涵盖从安装配置到进阶技巧的所有内容。

== 主要特点

+ *语法简洁*：Typst 的语法受到 Markdown 的启发，学习曲线平缓
+ *编译速度快*：增量编译技术使得大型文档也能快速预览
+ *实时预览*：官方编辑器支持实时渲染预览
+ *脚本能力*：内置图灵完备的脚本语言，支持复杂的排版逻辑
+ *现代设计*：原生支持 Unicode、OpenType 字体等现代排版技术

== 综合示例

前面的章节分别介绍了各组件与页面函数的用法，这里以一个综合示例串联起来，展示如何将它们组合成一个完整的附录页面。各组件 API 的详细用法见 @basics 与 @advanced 的「组件与辅助函数参考」。

=== 插图

最简单的插图方式直接放入图片即可。写论文时有必要给图片一个 `figure` 类、标题和标签，方便自动编号和交叉引用：

#figure(
  image("../assets/pkuword.pdf", width: 60%),
  caption: [北京大学字标],
) <fig-wordmark>

同一类对象会自动编号，给一个标签是为了交叉引用。@fig-wordmark 展示的是北京大学的校名字标，本模板已内置（取自 CTAN 的 #link("https://ctan.org/pkg/pkuthss")[pkuthss] 包），论文封面通过 `config()` 的 `logo` / `wordmark` 参数导入。附图亦可用原生 Typst 图形绘制，如 @appendix-fig 所示：

#figure(
  {
    polygon(
      fill: blue.lighten(80%),
      stroke: blue,
      (20%, 0pt),
      (60%, 0pt),
      (80%, 2cm),
      (0%,  2cm),
    )
  },
  caption: "原生 Typst 绘制的多边形",
) <appendix-fig>

专门的绘图包（如 gribouille）使用方式与原生 `figure` 一致，仍需在 `figure` 中包装才能编号和引用。

=== 表格

三线表可直接用 `as-booktab` 包装原生 `table` 得到，@table-example 便是一张常见的三线表：

#figure(
  as-booktab(table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[*地区*],
      table.cell(colspan: 2)[*经济指标*],
      table.cell(rowspan: 2)[*人口（万）*],
      table.hline(start: 1, end: 3, stroke: 0.5pt),
      [*GDP（亿）*],
      [*增速（%）*],
    ),
    [城市 A], [41610], [3.5], [2189],
    [城市 B], [47218], [4.1], [2487],
    [城市 C], [135673], [5.2], [12684],
  )),
  caption: [城市 A、B、C 的 GDP 和人口情况],
) <table-example>

表格样式说明见 @basics 的表格一节。

=== 公式

+ 行内公式
  爱因斯坦的质能方程：$E=m c^2$
+ 行间公式

  #eq-block(caption: [正态分布密度函数])[
    $ f(x) = frac(1, sigma sqrt(2 pi)) e^(- frac((x - mu)^2, 2 sigma^2)) $
  ] <eq-normal>

@eq-normal 是正态分布密度函数。公式自动编号与引用见 @basics 公式一节。

=== 代码块

附录中也可以插入代码块，@appendix-code 是一个 Rust 示例：

#code-block(
  ```rust
  fn main() {
      println!("Hello from Rust!");
  }
  ```,
  caption: "Rust Hello World",
) <appendix-code>

代码块同样支持编号、入代码列表与 `@` 引用，详见 @basics 代码块一节。
