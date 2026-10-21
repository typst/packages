#import "@preview/pku-thesis-pass:0.3.0": booktab, as-booktab, code-preview, code-block, eq-block, subfigure, theorem, definition, lemma, corollary, proposition, property, example, remark, proof, total-words

本章介绍 Typst 的基本语法和功能，帮助用户快速上手。

== 内容模式与代码模式

理解 Typst 的两种基本模式是掌握其语法的关键：

*内容模式* `[...]`：用于书写文档内容，类似于 Markdown。在内容模式中，文本会直接渲染，可以使用 `*粗体*`、`_斜体_` 等标记语法。

*代码模式* `{...}`：用于编写逻辑代码，如变量定义、条件判断、循环等。代码模式中的内容不会直接渲染，而是作为程序执行。

两种模式可以相互嵌套：
- 在内容模式中使用 `#` 前缀进入代码模式：`这是文本 #calc.pow(2, 10) 继续文本`
- 在代码模式中使用 `[...]` 进入内容模式：`#let x = [这是内容]`

#code-preview(
  ```typ
  // 内容模式
  这是普通文本

  // 在内容中嵌入代码
  计算结果：#(1 + 2 + 3)

  // 代码模式定义变量
  #let name = "张三"
  你好，#name！
  ```,
  [
    这是普通文本
    
    计算结果：#(1 + 2 + 3)

    #let name = "张三"
    你好，#name！
  ],
)

== 标题与章节

Typst 中的标题使用 `=` 表示，其后跟着标题的内容。`=` 的数量对应于标题的级别。

#code-preview(
  ```typ
  == 二级标题
  === 三级标题
  ==== 四级标题

  #heading(level: 2, numbering: none, outlined: false)[无编号二级标题]
  ```,
  [
    == 二级标题
    === 三级标题
    ==== 四级标题
    #heading(level: 2, numbering: none, outlined: false)[无编号二级标题]
  ],
)

本模板对标题样式进行了定制，包括：
+ 一级标题使用"第 X 章"格式编号，附录使用"附录 A/B"格式；
+ 各级标题使用不同字号；
+ 章节前后的间距参照 Word 模板中的设置。

=== 三级标题示例

==== 四级标题示例

本模板目录的默认最大深度为 3。如需更深的目录层级，可以通过 `outline-depth` 配置项调整。

== 文本样式

=== 粗体与斜体

与 Markdown 类似，在 Typst 中使用 `*...*` 表示粗体，使用 `_..._` 表示斜体：

#code-preview(
  ```typ
  *bold* and _italic_ are simple.
  ```,
  [*bold* and _italic_ are simple.],
)

字体加粗的代码模式通过 `#strong[...]` 实现。

#code-preview(
  ```typ
  这是*粗体*文字。
  这是_斜体_文字。

  这是#strong[粗体]文字，无额外空格。
  ```,
  [
    这是*粗体*文字。
    这是_斜体_文字。

    这是#strong[粗体]文字，无额外空格。
  ],
)

#strong[注意]：根据 CTAN #link("https://ctan.org/pkg/pkuthss")[pkuthss] 惯例，中文的斜体用楷体表示，本模板继续沿用。另外，pkuthss 惯例，粗体用黑体表示，本模板没有选择沿用，而是选择与 Word 相同的行为模式，保持字形不变，仅加粗字体，其中有些字体有粗体，比如思源字体，有些字体没有粗体，比如仿宋字体，本模板的策略是：有真粗体的用真粗体；没有粗体的，利用 #link("https://typst.app/universe/package/cuti")[cuti] 包通过描边的方式加粗，即伪粗体。

=== 脚注

Typst 原生支持脚注功能。本模板中，每一页的脚注编号从 ① 开始重新计数：

#code-preview(
  ```typ
  Typst 支持添加脚注#footnote[这是一个脚注。]。
  ```,
  [Typst 支持添加脚注#footnote[这是一个脚注。]。],
)

#strong[注意]：如果脚注在某一页的最上面一段，脚注内容有可能跑到上一页去，这是 Typst 的一个 bug，临时解决办法是手动加入 `#pagebreak(weak: true)` 强制换行。

=== 列表

Typst 支持无序列表和有序列表：

#code-preview(
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
  [
    无序列表：
    - 第一项
    - 第二项
      - 嵌套项

    有序列表：
    + 第一步
    + 第二步
    + 第三步
  ],
)

== 图片

在 Typst 中插入图片使用 `image` 函数。如果需要给图片增加标题或在文章中引用，需要将其放置在 `figure` 中：

#code-preview(
  ```typ
  #figure(
    image("../assets/pkulogo.pdf", width: 30%),
    caption: "北京大学校徽",
  ) <logo>
  ```,
  [
    #figure(
      image("../assets/pkulogo.pdf", width: 30%),
      caption: "北京大学校徽",
    ) <logo>
  ],
)

@logo 展示了北京大学校徽。代码中的 `<logo>` 是标签，可以在文中通过 `@logo` 来引用。

当需要在一张图中展示多张子图时，使用 `subfigure` 组件将各子图放进一个 `grid`，并整体放入 `figure`。子图会自动按 `(a)(b)(c)` 编号，编号与主图编号无关，例如下面的校徽和字标排成与封面相同的效果：

#code-preview(
  ```typ
  #figure(
    grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      subfigure(
        align(center + horizon, image("../assets/pkulogo.pdf", height: 2.4em, fit: "contain")),
        caption: "北京大学校徽",
        lbl: "sub-logo",
      ),
      subfigure(
        align(center + horizon, image("../assets/pkuword.pdf", height: 1.6em, fit: "contain")),
        caption: "北京大学字标",
        lbl: "sub-wordmark",
      ),
    ),
    caption: "北京大学校徽与字标",
  ) <sub-logo-wordmark>
  ```,
  [
    #figure(
      grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        subfigure(
          align(center + horizon, image("../assets/pkulogo.pdf", height: 2.4em, fit: "contain")),
          caption: "北京大学校徽",
          lbl: "sub-logo",
        ),
        subfigure(
          align(center + horizon, image("../assets/pkuword.pdf", height: 1.6em, fit: "contain")),
          caption: "北京大学字标",
          lbl: "sub-wordmark",
        ),
      ),
      caption: "北京大学校徽与字标",
    ) <sub-logo-wordmark>
  ],
)

通过 `lbl` 参数可为子图添加标签，文中使用 `@sub-logo`、`@sub-wordmark` 这样的形式引用，会显示为"@sub-logo"和"@sub-wordmark"。@sub-logo-wordmark 两个子图的高度比例与封面一致（校徽较高、字标较矮）。主图编号沿用大纲序号，插图列表中也只列出主图，不会单独列出子图。

子图除了左右并排，也可以上下排列。只需让 `grid` 使用 `rows` 参数（而非 `columns`）即可，此处设置 `rows(auto, auto)` 让两行高度自适应，`gutter` 设置为 1em，显示效果如 @sub-logo-wordmark2 所示：

#figure(
  grid(
    rows: (auto, auto),
    gutter: 1em,
    subfigure(
      align(center + horizon, image("../assets/pkulogo.pdf", height: 3.2em, fit: "contain")),
      caption: "北京大学校徽",
      lbl: "sub-logo2",
    ),
    subfigure(
      align(center + horizon, image("../assets/pkuword.pdf", height: 2em, fit: "contain")),
      caption: "北京大学字标",
      lbl: "sub-wordmark2",
    ),
  ),
  caption: "上下排列的校徽与字标",
) <sub-logo-wordmark2>

子图会从 `(a)` 开始依次编号，与排列方向无关。引用方式与前述相同，使用 `@sub-logo2`、`@sub-wordmark2`，会显示为"@sub-logo2"和"@sub-wordmark2"。

== 表格

Typst 中定义表格使用 `table` 函数。如需标题和引用功能，同样需要将其放置在 `figure` 中。

本模板提供了 `booktab` 函数用于生成更美观的三线表。`booktab` 基于原生 `table` 实现，支持大部分 `table` 参数（`stroke` 除外），第一行自动作为表头。

#strong[引用规则]：
  - 仅当 `outlined = true`（默认）时，`booktab` 才会包装为 `figure`，此时 `caption` 生效、表格可被 `@label` 引用。
  - 设 `outlined: false` 时为纯表格，`caption` 不生效，且不能使用 `@` 引用。

#strong[注意]：本模板默认允许表格跨页显示（`show figure: set block(breakable: true)`）。长表跨页时会自动重复表头，并在续表页右上角标注"续表"，无需手动控制。如果不希望某个表格被分割，可以在表格前手动插入 `#pagebreak()` 进行调整。详细 API 见 @advanced 的「组件与辅助函数参考」。

@booktab-example 展示了 `booktab` 的示例效果：

#code-preview(
  ```typ
  #booktab(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    caption: [三线表示例],
    [左对齐], [居中], [右对齐],
    [4], [5], [6],
    [7], [8], [9],
  ) <booktab-example>
  ```,
  [
    #booktab(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      caption: [三线表示例],
      [左对齐], [居中], [右对齐],
      [4], [5], [6],
      [7], [8], [9],
    ) <booktab-example>
  ],
)

如果你更喜欢先写原生 `table`，再统一套用三线表样式，可以使用 `as-booktab`。这种写法更适合与原生 `figure` 组合，也更容易被 Tinymist 等格式化工具整理。若需要标题、编号和 `@label` 引用，请像原生表格一样继续使用 `figure(..., kind: table)` 包装。对于包含 `table.vline(...)` 或其他非单元格结构元素的表格，建议显式使用 `table.header(...)`，不要依赖 `as-booktab` 的首行表头推断。

#code-preview(
  ```typ
  #figure(
    as-booktab(table(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      table.header([左对齐], [居中], [右对齐]),
      [4], [5], [6],
      [7], [8], [9],
    )),
    caption: [三线表示例（as-booktab）],
    kind: table,
  ) <as-booktab-example>
  ```,
  [
    #figure(
      as-booktab(table(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        table.header([左对齐], [居中], [右对齐]),
        [4], [5], [6],
        [7], [8], [9],
      )),
      caption: [三线表示例（as-booktab）],
      kind: table,
    ) <as-booktab-example>
  ],
)

== 公式

Typst 使用 `$...$` 包裹数学公式。行内公式前后需要有空格，行间公式会自动编号：

#code-preview(
  ```typ
  行内公式：$E = m c^2$

  行间公式：
  $ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $ <integral>
  ```,
  [
    行内公式：$E = m c^2$

    行间公式：
    $ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $ <integral>
  ],
)

@integral 展示了高斯积分公式。

=== 不编号公式

默认情况下行间公式都会自动编号。若某个公式不需要编号（如推导过程中的中间步骤），可用 `#math.equation($...$, numbering: none, block: true)` 显式关闭，该公式不会占编号，也不影响后续公式编号：

#code-preview(
  ```typ
  $ a(t) = g $ <accel>

  中间推导，不编号：
  #math.equation($ v(t) = integral g dif t = g t + v_0 $, numbering: none, block: true)

  #math.equation($ s(t) = integral (g t + v_0) dif t $, numbering: none, block: true)

  后续公式编号继续：
  $ s(t) = 1/2 g t^2 + v_0 t + s_0 $ <disp>
  ```,
  [
    $ a(t) = g $ <accel>

    中间推导，不编号：
    #math.equation($ v(t) = integral g dif t = g t + v_0 $, numbering: none, block: true)

    #math.equation($ s(t) = integral (g t + v_0) dif t $, numbering: none, block: true)

    后续公式编号继续：
    $ s(t) = 1/2 g t^2 + v_0 t + s_0 $ <disp>
  ],
)

如上所示，@accel 与 @disp 的编号连续，中间的公式没有编号。

=== 多行公式

多行公式使用 `\` 换行，使用 `&` 对齐：

#code-preview(
  ```typ
  $ sum_(k=0)^n k & = 1 + 2 + ... + n \
                  & = (n(n+1)) / 2
  $ <sum>
  ```,
  [
    $ sum_(k=0)^n k & = 1 + 2 + ... + n \
                    & = (n(n+1)) / 2
    $ <sum>
  ],
)

=== 公式目录

当论文中公式较多时，可使用公式目录（公式列表）方便读者查找。使用 `$...$` 语法生成的公式无法为公式添加描述信息，放在目录里只有编号，一眼看过去，和具体哪个公式联系不起来，这就需要借助 `#figure` 包裹公式，并添加更多参数设置，这样显然比较麻烦，为此本模板专门开发了 `eq-block` 组件和 `list-of-equations` 函数来实现这一功能。

`eq-block` 将公式包装为带描述文字的可引用单元，使其出现在公式目录中：
#code-preview(
  ```typ
  #eq-block(caption: [欧拉公式])[
    $ e^(i pi) + 1 = 0 $
  ] <eq-euler>
  ```,
  [
    #eq-block(caption: [欧拉公式])[
      $ e^(i pi) + 1 = 0 $
    ] <eq-euler>
  ],
)

#code-preview(
  ```typ
  #eq-block(caption: [高斯积分])[
    $ integral_(-infinity)^infinity e^(-x^2) dif x = sqrt(pi) $
  ] <eq-gauss>
  ```,
  [
    #eq-block(caption: [高斯积分])[
      $ integral_(-infinity)^infinity e^(-x^2) dif x = sqrt(pi) $
    ] <eq-gauss>
  ],
)

如 @eq-euler 和 @eq-gauss 所示，这些公式会自动出现在公式目录中。

使用方法：

+ 通过 `cfg.list-of-equations` 访问公式列表
+ 在目录之后、正文之前调用 `#(cfg.list-of-equations)()`
+ 用 `#eq-block(caption: [描述])[公式]` 替代普通行间公式

#strong[注意]：使用公式目录时，所有需要编号的公式应统一用 `eq-block`，避免与普通 `$ ... $` 的计数器冲突。不需要编号的公式可用 `#math.equation($...$, numbering: none, block: true)`。`eq-block` 的详细 API 见 @advanced 的「组件与辅助函数参考」。

=== 常用数学符号

#code-preview(
  ```typ
  $ frac(a^2, 2) $
  $ vec(1, 2, delim: "[") $
  $ mat(1, 2; 3, 4) $
  $ lim_(x -> 0) sin(x) / x = 1 $
  ```,
  [
    $ frac(a^2, 2) $
    $ vec(1, 2, delim: "[") $
    $ mat(1, 2; 3, 4) $
    $ lim_(x -> 0) sin(x) / x = 1 $
  ],
)

== 定理环境

定理、定义、引理等环境使用 `#theorem`、`#definition`、`#lemma`、`#corollary`、
`#proposition`、`#property`、`#example`、`#remark` 提供。各类型独立编号
（随章重置，附录中自动切换为 "A.1"），并支持 `@label` 交叉引用：

#code-preview(
  ```typ
  #theorem[
    设 $n$ 为大于 1 的整数，若 $n$ 没有大于 1 且小于 $n$ 的因数，则称 $n$ 为素数。
  ]

  #definition[
    设 $a, b$ 为整数，$b != 0$。若存在整数 $q$ 使得 $a = b q$，则称 $b$ 整除 $a$。
  ]

  #lemma[每一个素数有且仅有两个正因数。]
  ```,
  [
    #theorem[
      设 $n$ 为大于 1 的整数，若 $n$ 没有大于 1 且小于 $n$ 的因数，则称 $n$ 为素数。
    ]

    #definition[
      设 $a, b$ 为整数，$b != 0$。若存在整数 $q$ 使得 $a = b q$，则称 $b$ 整除 $a$。
    ]

    #lemma[每一个素数有且仅有两个正因数。]
  ],
)

可以使用 `title` 参数为定理命名，配合标签进行交叉引用：

#code-preview(
  ```typ
  #theorem(title: [唯一分解定理])[
    任意大于 1 的整数都可以唯一地分解为素数的乘积。
  ] <thm:ufd>

  由 @thm:ufd 可知，质因数分解是唯一的。
  ```,
  [
    #theorem(title: [唯一分解定理])[
      任意大于 1 的整数都可以唯一地分解为素数的乘积。
    ] <thm:ufd>

    由 @thm:ufd 可知，质因数分解是唯一的。
  ],
)

证明使用 `#proof` 环境，自动在末尾添加收尾符号：

#code-preview(
  ```typ
  #proof[
    假设素数只有有限个，设为 $p_1, p_2, dots, p_n$。
    令 $N = p_1 p_2 dots p_n + 1$。
    由于 $N$ 大于所有 $p_i$，它要么是素数，要么含有素因子。
    但 $N$ 除以任意 $p_i$ 都余 $1$，所以不能被任何 $p_i$ 整除。
    因此 $N$ 的素因子必定是一个新的素数，与“只有有限个素数”矛盾。
    故素数有无穷多个。
  ]
  ```,
  [
    #proof[
      假设素数只有有限个，设为 $p_1, p_2, dots, p_n$。
      令 $N = p_1 p_2 dots p_n + 1$。
      由于 $N$ 大于所有 $p_i$，它要么是素数，要么含有素因子。
      但 $N$ 除以任意 $p_i$ 都余 $1$，所以不能被任何 $p_i$ 整除。
      因此 $N$ 的素因子必定是一个新的素数，与“只有有限个素数”矛盾。
      故素数有无穷多个。
    ]
  ],
)

== 代码块

像 Markdown 一样，可以使用三个反引号插入代码块：

#code-preview(
  ````typ
  ```python
  def hello():
      print("Hello, world!")
  ```
  ````,
  [
    ```python
    def hello():
        print("Hello, world!")
    ```
  ],
)

本模板使用 codly 包提供代码块的语法高亮和样式增强。默认启用行号、语言图标、语言名称和交替背景色。可以通过 `codly-args` 配置项自定义样式。

如果需要给代码块加标题并在文章中引用，可以使用本模板提供的 `code-block` 命令：

#code-preview(
  ````typ
  #code-block(
    ```r
    sum(1:100)
    ```,
    caption: "计算 1 到 100 的所有整数之和",
  ) <sum100>
  ````,
  [
    #code-block(
    ```r
    sum(1:100)
    ```,
    caption: "计算 1 到 100 的所有整数之和",
  ) <sum100>
  ]
)

@sum100 展示了计算 1 到 100 的所有整数之和的 R 语言代码。

省略 `caption` 时 `code-block` 原样返回代码块，不编号、不入代码列表、不可被 `@` 引用：

#code-preview(
  ````typ
  #code-block(
    ```r
    sum(1:100)
    ```,
  ) <sum100-test>
  ````,
  [
    #code-block(
    ```r
    sum(1:100)
    ```,
  ) <sum100-test>
  ]
)

等价于下面的写法：

#code-preview(
  ````typ
  ```r
  sum(100)
  ```
  ````,
  [
    ```r
    sum(100)
    ```
  ],
)

当论文中代码较多时，可使用代码列表方便读者查找。模板提供了 `list-of-code` 函数来生成代码列表。使用方法：

+ 通过 `cfg.list-of-code` 访问代码列表
+ 在目录之后、正文之前调用 `#(cfg.list-of-code)()`
+ 用 `#code-block(raw, caption: [标题])` 包装需要入列表的代码块

用 `code-block` 包装并提供 `caption` 的代码块会自动出现在代码列表中，如 @sum100 所示，这些代码块会自动出现在代码列表中。而上方*使用了`#code-block` 包裹但是未提供 `caption` 的代码块*或者*未使用 `#code-block` 包裹的普通代码块*则不会出现在目录后面的代码列表里。

与公式列表类似，使用代码列表时，需要编号的代码块应统一用 `code-block` 包装。`code-block` 的详细 API 见 @advanced 的「组件与辅助函数参考」。

== 图表等目录顺序

#let user-guide = "https://grs.pku.edu.cn/docs/2019-05/20190524160158375113.pdf"

根据《北京大学研究生学位论文写作指南》（2004版）#footnote(user-guide)，论文的图表一般不用专门制作目录，如确有必要，可另起一页放到本目录之后。因此，如果不需要在目录后显示插图、表格、公式、代码列表，可以删除或注释掉如下代码：

```typ
// ========== 插图列表 ==========
#(cfg.list-of-figures)()

// ========== 表格列表 ==========
#(cfg.list-of-tables)()

// ========== 公式列表 ==========
#(cfg.list-of-equations)()

// ========== 代码列表 ==========
#(cfg.list-of-code)()
```

如果论文目录后需要图表目录，但是它们出现的顺序需要调整，比如需要将表格列表放在插图列表之前，只需要调整上述代码的顺序即可：

```typ
// ========== 表格列表 ==========
#(cfg.list-of-tables)()

// ========== 插图列表 ==========
#(cfg.list-of-figures)()
```

其它公式列表、代码列表等页面顺序调整方法相同。

== 论文特殊页面

除正文外，论文还常包含书脊页、主要符号对照表、攻读学位期间发表的论文、字数统计等特殊页面，模板分别提供 `spine`、`notation`、`achievement`、`total-words` 等函数。它们的使用方式一致：先通过 `cfg.xxx` 访问对应函数，再在指定位置调用。

=== 论文书脊页

书脊页用于打印装订时在书脊上显示论文标题与作者，北大规范未强制要求，但博士论文装订常见。书脊页会竖排显示 `title-zh`（页面右侧上方）与 `author-zh`（页面右侧下方）；盲审模式（`blind: true`）下自动隐藏作者，只保留标题。如打印论文时需启用，在`thesis.typ` 中取消注释 `#(cfg.spine)()`即可。另，建议打印时同时设置章节总是从奇数页开始，方法是设置 `always-start-odd: true`。

=== 主要符号对照表

根据北大写作指南规定，如果论文中使用了大量的符号、标志、缩略词、专门计量单位、自定义名词和术语等，应编写“主要符号对照表”。如果上述符号和缩略词数量不多，可以不设专门的“主要符号对照表”，在论文中出现时随即加以说明即可。“主要符号对照表”放目录之后、正文之前。

模板提供了 `notation` 页面函数来实现这一功能。内容使用 Typst 原生的术语语法 `/ 符号: 说明`，默认双栏排布（每行两对"符号+说明"并排）；空行用于分组（如符号、希腊字母、缩略词等）。如果论文中需要“主要符号对照表”，可以在 `thesis.typ` 中取消注释 `#(cfg.notation)[...]`所在行即可。例如：

```typ
// ========== 主要符号对照表 ==========
#(cfg.notation)[
  / $pi$: 圆周率
  / $infinity$: 无穷大
  / $sum$: 求和符号
  / $integral$: 积分符号
  / $partial$: 偏导数符号
  / $bold(A)$: 矩阵

  / $g$: 重力加速度
  / $lambda$: 波长
  / $c$: 光速
]
```

但是我更推荐你把 `[]` 中的内容放到 `content/notation.typ` 文件中，这样可以让
`thesis.typ` 更加简洁，并且方便符号表的维护。

```typ
// ========== 主要符号对照表 ==========
#(cfg.notation)[#include "content/notation.typ"]
```

使用方法：

+ 通过 `cfg.notation` 访问符号表
+ 在列表之后、正文之前调用 `#(cfg.notation)[...]`
+ 用 `/ 符号: 说明` 语法书写条目，空行分组

如果你希望修改“主要符号对照表”的标题名称，比如你希望它显示为“符号对照表”，那么你只需要在`config()` 中设置`supplements: (符号表: "符号对照表")` 来修改标题名称。

=== 攻读学位期间发表的论文

北大工学院等院系要求博士论文在附录之后、致谢之前列出攻读学位期间发表的论文。条目格式与参考文献列表基本一致，但需将作者本人姓名加粗，并标注论文是否为 SCI/EI 收录期刊、SCI 收录号及期刊影响因子。模板提供了 `achievement` 页面函数：

#code-preview(
  ```typ
  #achievement[
    + *张三*, 李四, 王五. 论文题目[J]. 期刊名, 2025, 60(3): 123-130. （SCI 收录期刊；SCI 收录号 601JP；IF=9.432）
    + *Zhang, S.*, Li, S., Wang, W. Paper title[J]. Journal Name, 2024, 55(2): 45-52. （SCI 收录期刊；SCI 收录号 5W1A；IF=8.123）
  ]
  ```,
  [
    #set enum(indent: 0pt, numbering: "[1]", body-indent: 1.2em, spacing: 1.14em)
    + *张三*, 李四, 王五. 论文题目[J]. 期刊名, 2025, 60(3): 123-130. （SCI 收录期刊；SCI 收录号 601JP；IF=9.432）
    + *Zhang, S.*, Li, S., Wang, W. Paper title[J]. Journal Name, 2024, 55(2): 45-52. （SCI 收录期刊；SCI 收录号 5W1A；IF=8.123）
  ],
)

使用方法：

+ 通过 `cfg.achievement` 访问成果页
+ 在附录之后、致谢之前调用 `#(cfg.achievement)[...]`
+ 用 `+` 书写条目（自动编号 `[1]`、`[2]`…），作者本人姓名用 `*...*` 加粗，并按参考文献格式附上检索类型（SCI/EI）、SCI 收录号与影响因子

`achievement` 页面标题默认显示"攻读学位期间发表的论文"，可通过 `supplements: (成果表: "...")` 自定义；该页默认出现在目录中（与致谢、声明一致），如需隐藏，在 `config()` 中设置 `achievement-outlined: false` 即可。

=== 字数统计

如需统计正文与附录的字数，在 `config()` 中设置 `word-count: true`，并在正文任意位置调用 `#cfg.total-words`（CJK 字数）或 `#cfg.total-characters`（字符数）来显示：

#code-preview(
  ```typ
  #let cfg = config(
    word-count: true, // 统计正文与附录的字数
  )

  全文总字数约为 #cfg.total-words 字。
  ```,
  [全文总字数约为 #total-words 字。],
)

统计由集成的 #link("https://typst.app/universe/package/wordometer")[wordometer] 包完成，标题不计入统计。

== 参考文献

本模板集成了 gb7714-bilingual 包，提供符合 GB/T 7714 标准的参考文献格式。该包会自动根据文献语言切换中英文术语（如英文文献使用 "et al."，中文文献使用 "等"）。

=== 基本用法

Typst 支持 BibLaTeX 格式的 `.bib` 文件。在文档中引用文献使用 `@` 符号：

#code-preview(
  ```typ
  可以像这样引用参考文献 @wang2010guide @kopka2004guide。
  ```,
  [可以像这样引用参考文献 @wang2010guide @kopka2004guide。],
)

使用本模板时，只需在 `config()` 函数中配置 `bib-file` 等参数即可：

#code-block(
  ```typ
  #let cfg = config(
    bib-file: path("ref.bib"),
    bib-style: "numeric",
    bib-version: "2015",
  )
  #show: cfg.setup
  ...
  #show: cfg.bibliography
  ```,
  caption: "参考文献配置示例",
)

根据#link("https://grs.pku.edu.cn/docs/2024-02/20240229092001843564.doc")[北京大学博士研究生学位论文格式模板(2024)]，文献索引方式可选择"顺序编码制"（`bib-style: "numeric"`）或"著者—出版年制"（`bib-style: "author-date"`）。

著者—出版年制下，参考文献列表默认先中文、后外文；中文条目按作者姓氏的汉语拼音排序（由集成的 gb7714-bilingual 与 auto-pinyin 实现）。若个别姓氏的多音字排序不符合预期，可通过 `bib-pinyin-override` 指定读音。

=== 语言检测

gb7714-bilingual 会自动检测文献语言。如果自动检测不准确，可以在 `.bib` 文件中显式指定 `language` 字段：

#code-block(
  ```bib
  @book{kopka2004guide,
    title     = {Guide to LATEX},
    author    = {Kopka, Helmut and Daly, Patrick W},
    year      = {2004},
    publisher = {Addison-Wesley},
    language  = {english}
  }
  ```,
  caption: "在 .bib 文件中指定语言",
)

=== 高级用法

如果需要使用其他引用样式（如 APA、IEEE 等），可以设置 `override-bib: true`，此时模板会跳过 gb7714-bilingual，改用 Typst 原生 `bibliography` 函数：

```typ
#let cfg = config(
  bib-file: path("ref.bib"),
  override-bib: true,
  ...
)
#show: cfg.setup
#show: cfg.body-wrap

// ... 正文内容 ...

// 在需要的位置自行调用 bibliography
#bibliography("ref.bib", style: "ieee")
```

`override-bib: true` 时模板仍会应用已预设参考文献的排版样式（五号字、悬挂缩进 1.66 字符、行距 16pt、段前 3pt），以匹配 Word 模板规范。如需进一步自定义排版，可以添加自己的 `show bibliography` 规则来覆盖：

```typ
#show bibliography: it => {
  set text(size: 10pt)
  set par(hanging-indent: 2em)
  it
}
#bibliography("ref.bib", style: "apa")
```

== 交叉引用

Typst 使用标签 `<label>`（或`label(...)`）和引用 `@label`（或`link(dst, src)`）实现交叉引用。当原始标签引用的对象是章节、图表等时，`@label` 会自动转换为链接文本。对于一般的引用，则需要通过 `link` 函数手动创建链接文本。

*图表与表格*：图片需放在 `figure` 中；`booktab` 表格需要使用 `outlined: true`（默认），才能用 `<label>` 配合 `@label` 引用。`outlined: false` 的纯表格不能作为引用目标。

=== 创建标签

在任意元素后附加 `<标签名>` 即可创建标签：

```typ
= 第一章 绪论 <ch-intro>

#figure(
  image("chart.svg"),
  caption: "实验数据",
) <fig-data>

$ a^2 + b^2 = c^2 $ <eq-pythagoras>
```

标签名可以是任意不包含空格的字符串。

=== 引用标签

使用 `@标签名` 引用已定义的标签：

#code-preview(
  ```typ
  如 @appendix-fig 所示...
  根据 @eq-normal...
  详见 @booktab-example...
  ```,
  [
    如 @appendix-fig 所示...
    根据 @eq-normal...
    详见 @booktab-example...
  ],
)

=== 引用显示效果

本模板自定义了各类型对象的引用前缀：

#booktab(
  width: 100%,
  columns: (8em, 1fr),
  align: (center, center),
  caption: "引用显示效果",
  [*类型*],
  [*引用示例*],
  [插图],
  ["如图 1.1 所示"],
  [表格],
  ["如表 1.1 所示"],
  [代码],
  ["如代码 1.1 所示"],
  [公式],
  ["如式 (1.1) 所示"],
  [章节],
  ["如第一章所述"],
  [附录],
  ["如附录 A 所述"],
)

引用前缀可通过 `supplements` 参数自定义：

```typ
#let cfg = config(
  supplements: (图: "Figure", 表: "Table"),
)
```

=== 手动引用

如果默认的 `@` 引用效果不满足需求，可以使用 `#link` 和 `#ref` 函数手动构造引用文本：

```typ
#link(<fig-wordmark>)[北京大学字标]
```

这会在"北京大学字标"上创建指向 @fig-wordmark 的超链接，因为我在附录里插入了一张北京大学字标的图片，并给它加了标签 `<fig-wordmark>`。
