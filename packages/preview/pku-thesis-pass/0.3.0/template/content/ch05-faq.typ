#import "@preview/pku-thesis-pass:0.3.0": code-block, code-preview, eq-block

== 为什么行距和 Word 对不上？

本模板的行距已针对 Word 模板进行了校准。Word 中的"行距"指的是基线到基线的距离，而 Typst 的 `leading` 指行与行之间的间距（不含字符高度）。

模板将正文行距固定为 `10.5pt`（视觉上近似对应 Word 的 20pt 行距）。如需精确匹配特定字体，可使用 `top-edge` 和 `bottom-edge` 参数。

但由于 Word 的实际行距还受字体影响，即使采用此方式，也难以做到与 Word 像素级对应。

== 为什么默认值与 thesis.typ 示例不一致？

`config.typ` 中的函数参数默认值，与 `thesis.typ` 中示例填写的值并不是一回事：

- #strong[config.typ（源码默认值）]：函数签名中定义的默认值，是唯一的一级回退源。用户省略该参数时，最终生效的就是这里的值。
- #strong[thesis.typ（示例值）]：模板自带的一篇示例论文，其中填写的值是演示性的，会覆盖源码默认值，仅代表"这样写可以"，不代表默认行为。

以 `supervisor-zh` 为例，`config.typ` 源码默认值为 `"李四"`，`thesis.typ` 示例值为 `"李四 教授"`。

因此 @config 的参数详解表格（#strong[系统默认值] 一栏）与各参数详解中的 #strong[默认值] 一栏，均如实对应 `config.typ` 的源码默认值。如果你省略了某个参数，实际生效的就是表格中所列的值。

== 省略参数和显式传 none 有何区别？

在 `thesis.typ` 中修改配置时，"省略某个参数"与"显式将其设为 `none`"是两种不同行为：

- #strong[省略该参数]：Typst 使用 `config.typ` 中定义的默认值，这是获取默认行为的推荐方式。
- #strong[显式传 `none`]：得到字面量 `none`，不会回落到默认值。对标题、姓名等字符串参数，会破坏封面等页面渲染，应避免。

```typ
// 方式一：省略该参数，生效值为默认值 "某个研究方向"
config(
  // 不写 direction 这一行即可
)

// 方式二：显式传 none，生效值为 none，可能导致封面渲染异常
config(
  direction: none,
)
```

需要关闭某可选功能时，应查看对应参数的默认值说明，传合理的关闭值（如 `blind: false`、`override-bib: false`、`word-count: false`），而非直接传 `none`。

== 封面标题如何换行？

`config()` 的 `title-zh` 和 `title-en` 参数支持在字符串中插入 `\n` 手动换行，方便控制非盲审封面（`blind: false`）的标题排版：

```typ
config(
  title-zh: "北京大学学位论文 \nTypst 模板使用指南",
  title-en: "A Guide to Using the Typst Template for \nPeking University Theses",
)
```

非盲审封面会按实际宽度自动换行，`\n` 则作为显式断行点优先于自动换行生效。较长标题建议合理使用 `\n` 控制封面视觉效果。

#strong[注意]：盲审封面（`blind: true`）会自动把 `\n` 替换为空格，避免手工换行导致排版错位。

== 表格被跨页分割怎么办？

本模板默认允许表格跨页（`show figure: set block(breakable: true)`）。长表跨页会自动重复表头，并在续表页右上角标注"续表"，无需手动控制；`booktab` 会自动完成这些。

如果某个表格不希望被分割，可在表格前手动插入 `#pagebreak()` 调整。详见 @basics 的表格一节。

== `booktab` 和 `as-booktab` 该用哪个？

- #strong[`booktab(...)`]：从零创建三线表。第一个位置参数自动作为表头（加粗），给 `caption` 时自动包装为 `figure(kind: table)`，支持 `@label` 引用。简单表格推荐使用。
- #strong[`as-booktab(table(...))`]：将已有原生 `table` 装饰为三线表样式，不自动包装 `figure`。适合需要手动控制图题、编号的场景，如使用了 `table.hline`、`table.cell(rowspan:)` 等复杂单元格。

简单来说：直接造表用 `booktab`，已有原生表想"套上"三线样式用 `as-booktab`。详细 API 见 @advanced 的「组件与辅助函数参考」。

== 代码块用裸反引号和用 `code-block` 的区别？

普通的反引号代码块会通过 codly 渲染语法高亮、行号与语言图标，但不会显示标题与编号，也不支持 `@label` 交叉引用或出现在代码列表（`#list-of-code()`）中：

#code-preview(
  `````typ
  ```python
  def hello():
      print("Hello, world!")
  ```
  `````,
  [
    ```python
    def hello():
        print("Hello, world!")
    ```
  ],
)

如需给代码块添加标题、编号并支持 `@label` 引用，应使用 `code-block` 包装：

#code-preview(
  `````typ
  #code-block(
    ```python
    def hello():
        print("Hello, world!")
    ```,
    caption: "Hello World 程序",
  ) <hello>
  `````,
  [
    #code-block(
      ```python
      def hello():
          print("Hello, world!")
      ```,
      caption: "Hello World 程序",
    ) <hello>
  ],
)

带 `caption` 的 `code-block` 会自动进入代码列表；省略 `caption` 时等价于裸代码块，不编号、不入列表、不可引用。详细用法见 @basics 的代码块一节。

== 公式用裸行间公式和用 `eq-block` 的区别？

行间公式（`$ ... $`）会自动按章编号并支持 `@label` 引用，但不会显示描述文字，也不出现在公式列表（`#list-of-equations()`）中：

#code-preview(
  `````typ
  $ E = m c^2 $ <emc>

  如 @emc 所示，质能关系揭示了质量与能量的等价性。
  `````,
  [
    $ E = m c^2 $ <emc>

    如 @emc 所示，质能关系揭示了质量与能量的等价性。
  ],
)

如需给公式添加描述文字（如"质能方程"）并使其出现在公式目录中，应使用 `eq-block` 包装：

#code-preview(
  `````typ
  #eq-block(caption: [质能方程])[
    $ E = m c^2 $
  ] <emc-block>

  如 @emc-block 所示，质能关系揭示了质量与能量的等价性。
  `````,
  [
    #eq-block(caption: [质能方程])[
      $ E = m c^2 $
    ] <emc-block>

    如 @emc-block 所示，质能关系揭示了质量与能量的等价性。
  ],
)

#strong[注意]：使用公式列表时，所有需要编号的公式应统一用 `eq-block`，避免与普通 `$ ... $` 的计数器冲突。不需要编号的公式可用 `#math.equation($...$, numbering: none, block: true)`。详细 API 见 @advanced 的「组件与辅助函数参考」。

== 可以不用 `eq-block`，直接用原生公式吗？

视情况而定。核心在于 #strong[公式列表]：Typst 的 `outline` 只能索引 `figure`，无法索引 `math.equation`。因此需要入表的公式必须走 `#figure(kind: "equation")`，不需要的可以用 `$...$`。

#strong[方案一：纯 `math.equation`]——用 `$...$ <label>` 编号和引用都正常，模板已支持：

#code-block(
  `````typ
  $ E = m c^2 $ <emc>

  如 @emc 所示。
  `````
)

但该类公式 #strong[不会进入公式列表]，因为 `outline(target: figure.where(kind: "equation"))` 找不到它们。适合没有 caption 需求的公式。

#strong[方案二：全用 `#figure(kind: "equation")`]——所有公式都入列表、都支持 caption，前提是全局关掉原生计数器：

#code-block(
  `````typ
  #set math.equation(numbering: none)

  #figure(
    $ E = m c^2 $,
    caption: [质能方程],
    kind: "equation",
    numbering: (..nums) => context {
      chinesenumbering(chaptercounter.at(here()).first(), ..nums,
                       location: here(), brackets: true)
    },
  ) <eq:emc>
  `````
)

`supplement: [式]` 不必手写——config 的 `supplements` 参数已全局提供。代价是每个公式都要复制 `kind`、`numbering` 这一段。

#strong[方案三：混用（`eq-block`）]——需要 caption / 入表的用 `eq-block`，不需要的用裸 `$...$`：

#code-block(
  `````typ
  // 入表、带 caption
  #eq-block(caption: [质能方程])[
    $ E = m c^2 $
  ] <emc-block>

  // 不入表、纯编号
  $ a^2 + b^2 = c^2 $ <pythagoras>
  `````
)

`eq-block` 本质是方案二的语法糖：有 `caption` 时升级为 `#figure(kind: "equation")`（内部 `set math.equation(numbering: none)`），省略时退化为裸 `$...$`。

#strong[总结]：三种方案都能正确编号与引用，差别只是公式是否入表、以及每处写多少代码。选你偏好的即可。

== 参考文献中英文混排、多音字排序不对？

参考文献列表默认先中文、后外文；中文条目按作者姓氏拼音排序。若个别姓氏的多音字排序不符合预期，可通过 `bib-pinyin-override` 指定读音；中英文顺序可用 `bib-cn-first` 调整。

详见 @basics 参考文献一节的"语言检测"与 `bib-pinyin-override`。

== 盲审时某些页面仍显示作者/信息？

开启 `blind: true` 后，模板会自动隐藏作者、导师、学号、致谢、"攻读学位期间发表的论文"页及原创性声明，封面替换为盲审版，PDF 元数据也隐藏作者。

若发现仍泄漏信息，请先确认 `blind` 生效（`--input blind=true` 可临时覆盖），再检查封面与正文中是否手写了作者等文字。详见 @advanced 的「盲审模式」。

== 为什么会出现空白页 / 章节不从奇数页开始？

当 `always-start-odd: true`（默认）时，每个新章节都会从奇数页开始，正文与章末之间可能出现空白页，这是为双面打印准备的。若希望线上阅读或精简输出，可设 `always-start-odd: false`，或用 `--input always-start-odd=false` 临时关闭。
