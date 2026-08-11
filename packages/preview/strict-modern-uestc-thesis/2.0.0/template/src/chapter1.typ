#import "lib.typ": *

= 模板使用说明 <ch:usage>

本模板是电子科技大学学位论文的 Typst 模板，本章节将详细介绍模板提供的各种功能及其用法。


== `main.typ` 配置参数说明 <usage-main-params>

本节列出 `main.typ` 中所有可配置的参数，按功能分组说明。

=== 匿名模式与论文排版模式

以下参数控制模板的匿名评审和论文排版模式：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 匿名模式：隐藏作者、导师等个人信息，用于匿名评审
    info-keys.匿名: false,
    /*
      论文排版模式
      论文模式.修订模式:        用于审稿修订，#revise[修改内容] 会标红显示
      论文模式.电子档定稿模式:  用于提交电子档定稿，revise 不标红，
                               独创性声明页替换为扫描页（需设置 info-keys.独创性声明扫描页 路径）
      论文模式.打印模式:        用于双面打印，奇数页起始，revise 不标红
    */
    info-keys.论文模式: 论文模式.打印模式,
    // 电子档定稿模式下需要设置独创性声明扫描页路径（A4 大小的 PDF/PNG 扫描件）
    info-keys.独创性声明扫描页: path("src/独创性声明.pdf"),
    ```
  ]
]

=== 字体设置

模板支持自定义宋体、黑体等字体：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 黑体字体（Windows 默认 SimHei，macOS/Linux 建议 "Source Han Sans SC"）
    info-keys.黑体字体: "SimHei",
    // 宋体字体（Windows 默认 SimSun，macOS/Linux 建议 "Source Han Serif SC"）
    info-keys.宋体字体: "SimSun",
    // 加粗粗度：仅在不使用 Sim* 系列字体时生效
    info-keys.加粗粗度: 250,
    ```
  ]
]

=== 封面信息

封面包含论文标题、作者、导师、学院等基本信息：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 基本参数（影响封面总体效果）
    info-keys.申请学位级别: "硕士",  // 可选：学士、硕士、博士
    info-keys.学位类型: "专业型",    // 可选：学术型、专业型

    // 封面信息（支持使用 \\n 换行）
    info-keys.论文中文标题: "论文标题",
    info-keys.作者学科专业: "学科专业",       // 学术型填写，专业型忽略
    info-keys.作者专业学位类别: "专业学位类别", // 专业型填写，学术型忽略
    info-keys.作者学号: "2022XXXXXXXX",
    info-keys.作者中文名: "作者姓名",
    info-keys.指导老师中文名: "导师姓名",
    info-keys.指导老师职称中文: "教授",
    info-keys.作者学院: "学院名称",
    ```
  ]
]

=== 中文扉页信息

中文扉页包含分类号、密级、答辩信息等详细内容：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    info-keys.分类号: "TP309.2",
    info-keys.密级: "公开",
    info-keys.UDC: "004.78",
    info-keys.指导老师单位: "电子科技大学 成都",
    info-keys.合作导师中文名: "合作导师姓名",
    info-keys.合作导师职称中文: "教授",
    info-keys.合作导师单位: "合作导师单位",
    info-keys.专业学位领域: "领域名称", // 专业型填写，学术型忽略
    info-keys.提交日期: "2025年3月17日",
    info-keys.答辩日期: "2025年4月15日",
    info-keys.学位授予单位: "电子科技大学",
    info-keys.学位授予日期: "2025年6月1日",
    info-keys.答辩委员会主席: "主席名称",
    info-keys.答辩委员会主席职称: "主席职称",
    // 以下两个参数为元组类型
    info-keys.评阅人: ("成员1", "成员2"),
    ```
  ]
]

=== 英文扉页信息

英文扉页对应中文扉页的英文版本：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    info-keys.论文英文标题: "English Thesis Title",
    info-keys.作者学科专业英文: "Discipline",      // 学术型填写
    // info-keys.作者专业学位类别英文: "Category",  // 专业型填写
    info-keys.作者英文名: "Author Name",
    info-keys.指导老师英文名: "Advisor Name",
    info-keys.指导老师职称英文: "Professor",
    info-keys.作者学院英文: "School Name",
    ```
  ]
]

=== 论文内容信息

以下参数配置论文正文内容，包括摘要、附录、参考文献等：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 使用 include 引入内容的参数
    info-keys.中文摘要: include "src/摘要-中文.typ",
    info-keys.英文摘要: include "src/摘要-英语.typ",
    info-keys.致谢: include "src/致谢.typ",
    // 附录为元组（可包含多个 include）
    info-keys.附录: (include "src/附录-1.typ", include "src/附录-2.typ"),

    // 使用字符串路径的参数
    info-keys.参考文献: path("src/bib/参考文献.bib"),

    // 关键字为元组
    info-keys.中文摘要关键字: ("关键字1", "关键字2"),
    info-keys.英文摘要关键字: ("Keyword1", "Keyword2"),

    // 成果列表（字典格式）和攻读学位期间取得成果
    // 详见"攻读学位期间取得成果"章节
    info-keys.成果列表: (...),
    info-keys.攻读学位期间取得成果: true,

    // 浮动表图：当页面包含一级标题时，浮动图表放在页面底部
    info-keys.浮动表图标题页置底: true,
    ```
  ]
]

== 图片相关

=== 插入图片 <usage-picture>

使用 `picture-figure` 函数插入图片，它会自动按章节编号（如图1-1）。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #picture-figure(
      "这是一个测试图片的标题",
      image("pics/logo.svg"),
    ) <my-label>
    ```
  ]
]

效果如下：

#picture-figure(
  "这是一个测试图片的标题",
  image("pics/logo.svg"),
) <my-label>

*参数说明：*
- 第一个参数：图片标题（字符串或 content）
- 第二个参数：图片内容（使用 `image()` 函数）
- `placement`：可选，浮动位置，可选值为 `top`、`bottom` 或不传（不浮动）。如果图片放置的位置在大章节标题页，并设置了浮动位置，会自动调整为 `bottom`，以避免与章节标题重叠。

=== 子图 <usage-subfigure>

使用 `grid` + `picture-figure` 嵌套的方式实现子图。子图会自动编号为 (a)、(b) 等。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #picture-figure(
      [子图示例：使用 grid 排列多张子图],
      grid(
        columns: 2,
        column-gutter: 1em,
        row-gutter: 0.5em,
        picture-figure(
          [子图(a)的标题],
          image("pics/logo.svg", width: 90%),
        ),
        [#picture-figure(
          [子图(b)的标题],
          image("pics/logo.svg", width: 90%),
        ) <subfig-b>],
        picture-figure(
          [子图(c)的标题],
          image("pics/logo.svg", width: 90%),
        ),
        picture-figure(
          [子图(d)的标题],
          image("pics/logo.svg", width: 90%),
        ),
      ),
      placement: top,
    ) <subfig-example>
    // @subfig-b 显示为"图1-x (b)"，@subfig-example 显示为"图1-x"
    ```
  ]
]

效果如下：

#picture-figure(
  [子图示例：使用 grid 排列多张子图],
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 0.5em,
    picture-figure(
      [子图(a)的标题],
      image("pics/logo.svg", width: 90%),
    ),
    [#picture-figure(
      [子图(b)的标题],
      image("pics/logo.svg", width: 90%),
    ) <subfig-b>],

    picture-figure(
      [子图(c)的标题],
      image("pics/logo.svg", width: 90%),
    ),
    picture-figure(
      [子图(d)的标题],
      image("pics/logo.svg", width: 90%),
    ),
  ),
  placement: top,
) <subfig-example>

*参数说明：*
- `columns`：设置列数（即每行几张子图）
- `column-gutter`：子图之间的列间距
- `row-gutter`：子图之间的行间距
- `gutter`：同时设置行列间距（设置后 `column-gutter` 和 `row-gutter` 会被覆盖）
- 子图的 `picture-figure` 的标题为空 `[]` 时，只显示 (a)、(b) 等编号
- 子图的 `picture-figure` 的标题为 `none` 时，不显示编号
- 子图引用：需要用 `[#picture-figure(...) <label>]` 包裹，引用时显示为"图x-y (a)"，此例中为@subfig-b。

=== 调整子图的列数和间距 <usage-subfigure-layout>

通过修改 `grid` 的 `columns`、`column-gutter` 和 `row-gutter` 参数来调整子图的布局。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 三列子图，列间距 0.5em，行间距 0.3em
    #picture-figure(
      [三列子图示例],
      grid(
        columns: 3,
        column-gutter: 0.5em,
        row-gutter: 0.3em,
        picture-figure([], image("path1.png", width: 90%)),
        picture-figure([], image("path2.png", width: 90%)),
        picture-figure([], image("path3.png", width: 90%)),
      ),
      placement: top,
    )
    ```
  ]
]

=== 子图标题为空与 none 的区别 <usage-subfigure-caption>

子图标题有三种情况：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 情况1：有标题文字 —— 显示 (a) + 标题文字
    picture-figure([子图标题], image("path.png"))

    // 情况2：标题为空 content [] —— 只显示 (a)，无标题文字
    picture-figure([], image("path.png"))

    // 情况3：标题为 none —— 不显示 (a)，也不显示标题
    picture-figure(none, image("path.png"))
    ```
  ]
]

=== 嵌套子图 <usage-nested-subfigure>

可以通过嵌套 `grid` 来实现更复杂的布局，例如两行两列，其中第一行占两列。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #picture-figure(
      [复杂子图布局],
      grid(
        columns: 2,
        gutter: 1em,
        // 第一行占两列的子图
        grid(
          columnspan: 2,
          picture-figure([横跨两列的子图], image("wide.png", width: 95%)),
        ),
        // 第二行两个子图
        picture-figure([子图(c)], image("left.png", width: 90%)),
        picture-figure([子图(d)], image("right.png", width: 90%)),
      ),
    )
    ```
  ]
]

=== 调整图片尺寸

使用 `image()` 的 `width` 参数来调整图片大小，接受百分比或绝对长度。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 百分比宽度（相对于容器）
    image("path.png", width: 80%)
    image("path.png", width: 50%)

    // 绝对宽度
    image("path.png", width: 10cm)
    ```
  ]
]

== 表格相关

=== 基本表格（三线表） <usage-table>

模板使用 `table-figure` 函数创建表格，推荐使用三线表格式。使用 `toprule()`、`midrule()`、`bottomrule()` 来绘制横线。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #table-figure(
      [三线表示例],
      table(
        columns: 3,
        align: center + horizon,
        stroke: none,  // 先取消所有边框
        toprule(),      // 顶部粗线
        table.header([列1], [列2], [列3]),
        midrule(),      // 中间细线
        [数据1], [数据2], [数据3],
        [数据4], [数据5], [数据6],
        bottomrule(),   // 底部粗线
      ),
      placement: top,
    ) <table-example>
    ```
  ]
]

效果如下：

#table-figure(
  [三线表示例],
  table(
    columns: 3,
    align: center + horizon,
    stroke: none,
    toprule(),
    table.header([列1], [列2], [列3]),
    midrule(), [数据1], [数据2],
    [数据3], [数据4], [数据5],
    [数据6], bottomrule(),
  ),
  placement: top,
) <table-example>

*参数说明：*
- `columns`：列数或列宽配置
- `align`：单元格对齐方式
- `stroke: none`：取消所有默认边框
- `toprule()`：顶部粗线（1.5pt）
- `midrule()`：中间细线（0.75pt）
- `bottomrule()`：底部粗线（1.5pt）
- `table.header()`：表头行

=== 合并单元格 <usage-table-merge>

使用 `table.cell(rowspan: n)` 或 `table.cell(colspan: n)` 来合并单元格。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #table-figure(
      [合并单元格示例],
      table(
        columns: 4,
        align: center + horizon,
        stroke: none,
        toprule(),
        table.cell(colspan: 4)[跨四列表头],
        midrule(),
        table.cell(rowspan: 2)[跨两行],
        [B1], [B2], [B3],
        [C1], [C2], [C3],
        bottomrule(),
      ),
    ) <merge-example>
    ```
  ]
]

效果如下：

#table-figure(
  [合并单元格示例],
  table(
    columns: 4,
    align: center + horizon,
    stroke: none,
    toprule(),
    table.cell(colspan: 4)[跨四列表头],
    midrule(),
    table.cell(rowspan: 2)[跨两行],
    [B1], [B2], [B3],
    [C1], [C2], [C3],
    bottomrule(),
  ),
) <merge-example>

=== 表格中的横线和竖线 <usage-table-lines>

默认使用三线表（`stroke: none`），但也可以添加竖线或额外的横线。

#table-figure(
  [添加竖线示例],
  table(
    columns: 4,
    stroke: none,
    toprule(),
    // 在第1、3列后添加灰色竖线
    table.vline(x: 1, stroke: 0.75pt + gray),
    table.vline(x: 3, stroke: 0.75pt + gray),
    table.header([A], [B], [C], [D]),
    midrule(),
    [1], [2], [3], [4],
    bottomrule(),
  ),
)

#table-figure(
  [添加竖线示例],
  table(
    columns: 3,
    stroke: none,
    toprule(),
    table.header([名称], [值1], [值2]),
    midrule(),
    [项目1], [10], [20],
    table.hline(start: 1, end: 3, stroke: 0.5pt),
    // 部分横线
    [项目2], [30], [40],
    bottomrule(),
  ),
)

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 添加竖线
    table(
      columns: 4,
      stroke: none,
      toprule(),
      // 在第1、3列后添加灰色竖线
      table.vline(x: 1, stroke: 0.75pt + gray),
      table.vline(x: 3, stroke: 0.75pt + gray),
      table.header([A], [B], [C], [D]),
      midrule(),
      [1], [2], [3], [4],
      bottomrule(),
    )

    // 添加自定义横线（仅在特定位置）
    table(
      columns: 3,
      stroke: none,
      toprule(),
      table.header([名称], [值1], [值2]),
      midrule(),
      [项目1], [10], [20],
      table.hline(start: 1, end: 3, stroke: 0.5pt),  // 部分横线
      [项目2], [30], [40],
      bottomrule(),
    )
    ```
  ]
]

=== 复杂表格示例

以下是一个包含多级表头和竖线的复杂表格示例。

#table-figure(
  [复杂表格示例],
  table(
    columns: 5,
    align: center + horizon,
    stroke: none,
    toprule(),
    table.cell(rowspan: 2)[方法],
    table.cell(colspan: 2)[数据集A],
    table.cell(colspan: 2)[数据集B],
    midrule(),
    [精度], [召回], [精度], [召回],
    midrule(),
    [方法1], [95.2], [90.1], [88.5], [85.3],
    [方法2], [*96.1*], [91.0], [*90.2*], [*87.1*],
    bottomrule(),
  ),
)

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #table-figure(
      [复杂表格示例],
      table(
        columns: 5,
        align: center + horizon,
        stroke: none,
        toprule(),
        table.cell(rowspan: 2)[方法],
        table.cell(colspan: 2)[数据集A],
        table.cell(colspan: 2)[数据集B],
        midrule(),
        [精度], [召回], [精度], [召回],
        midrule(),
        [方法1], [95.2], [90.1], [88.5], [85.3],
        [方法2], [*96.1*], [91.0], [*90.2*], [*87.1*],
        bottomrule(),
      ),
    )
    ```
  ]
]

== 算法相关

=== 算法（Algorithm） <usage-algorithm>

使用 `algorithm-figure` 函数创建算法伪代码。算法内部使用 `algorithmic` 模块提供的指令。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    #algorithm-figure(
      [快速排序算法],
      {
        import algorithmic: *
        Line[*Input:* 待排序数组 $A$，起始索引 $"lo"$，结束索引 $"hi"$]
        Line[*Output:* 排序后的数组 $A$]
        If[$"lo" < "hi"$][
          Line[$p arrow.l "Partition"(A, "lo", "hi")$]
          Line[$"QuickSort"(A, "lo", p - 1)$]
          Line[$"QuickSort"(A, p + 1, "hi")$]
        ]
        Return[$A$]
      },
      placement: top,
    ) <algo-example>
    ```
  ]
]

效果如下：

#algorithm-figure(
  [快速排序算法],
  {
    import algorithmic: *
    Line[*Input:* 待排序数组 $A$，起始索引 $"lo"$，结束索引 $"hi"$]
    Line[*Output:* 排序后的数组 $A$]
    If[$"lo" < "hi"$][
      Line[$p arrow.l "Partition"(A, "lo", "hi")$]
      Line[$"QuickSort"(A, "lo", p - 1)$]
      Line[$"QuickSort"(A, p + 1, "hi")$]
    ]
    Return[$A$]
  },
  placement: top,
) <algo-example>

*`algorithmic` 模块提供的指令：*
- `Line[内容]`：普通行
- `LineBreak`：空行
- `LineComment[注释内容][代码行]`：行内注释（注释在右侧）
- `If[条件][代码块]`：if 语句
- `IfElseChain[条件1][代码块1][条件2][代码块2]...[代码块n]`：if-else if-...-else 链
- `For[条件][代码块]`：for 循环
- `While[条件][代码块]`：while 循环
- `Return[内容]`：return 语句

*注意：* 在算法的公式中，普通变量名（如 `lo`、`hi`）需要用引号包裹写成 `$"lo"$`，否则 Typst 会将其解析为乘法（`l dot o`）等数学表达式。函数名同理，如 `$"QuickSort"(A)$`。

*`algorithm-figure` 的参数：*
- 第一个参数：算法标题（会自动加粗）
- 第二个参数：算法体（使用 `algorithmic` 指令）
- `placement`：浮动位置，`top`、`bottom` 或不传
- `supplement`：前缀文字，默认为"算法"
- `line-numbers`：是否显示行号，默认 `true`

=== 算法引用

在算法后添加 `<label>` 标签，然后使用 `@label` 引用。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 定义算法并添加标签
    #algorithm-figure(...) <my-algo>

    // 引用算法（显示为"算法1-1"）
    如 @my-algo 所示。
    ```
  ]
]

== Figure 的 placement 设置 <usage-placement>

所有 `picture-figure`、`table-figure`、`algorithm-figure` 都支持 `placement` 参数，用于控制浮动位置。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 浮动到页面顶部
    #picture-figure("标题", image("path.png"), placement: top)

    // 浮动到页面底部
    #table-figure("标题", table(...), placement: bottom)

    // 不浮动（在当前位置显示）
    #algorithm-figure("标题", {...})
    ```
  ]
]

*说明：*
- `placement: top`：图表浮动到页面顶部
- `placement: bottom`：图表浮动到页面底部
- 不传 `placement`：图表在当前位置显示
- 当页面包含一级标题且开启了 `浮动表图标题页置底` 时，浮动图表会自动放到页面底部

== 定理、证明、引理等 <usage-theorem>

=== 定理（Theorem）

使用 `theorem` 函数定义定理，可以通过 `label` 参数指定标签用于后续引用。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 不带 label 的定理
    #theorem[
      这里写定理的内容。
    ]

    // 带 label 的定理（可用于证明引用和交叉引用）
    #theorem(label: <thm1>)[
      若 $f$ 满足 Lipschitz 条件，则...
    ]
    ```
  ]
]

效果如下：

#theorem(label: <thm1>)[
  对任意满足条件的函数 $f$，存在常数 $C > 0$ 使得下式成立：$f(x + y) <= C (x + y)$。
]

=== 引理（Lemma）

使用 `lemma` 函数定义引理，用法与 `theorem` 类似。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 带 label 的引理
    #lemma(label: <lemma1>)[
      对于联合分布 $gamma$，有如下不等式成立...
    ]
    ```
  ]
]

效果如下：

#lemma(label: <lemma1>)[
  对于任意 $x in bb(R)^n$，有 $norm(x)_2 <= sqrt(n) norm(x)_infinity$。
]

=== 证明（Proof）

使用 `proof` 函数定义证明。证明会自动在末尾添加 $qed$ 符号（方框）。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 不引用特定定理的证明（无标题）
    #proof[
      这里写证明过程...
    ]

    // 引用某一定理/引理的证明
    // title 使用 @ 引用，会显示为"定理1.1的证明"或"引理1.1的证明"
    #proof(title: [@thm1])[
      证明内容...
    ]
    ```
  ]
]

效果如下：

#proof(title: [@lemma1])[
  根据范数的定义，$norm(x)_infinity = max(|x_i|)$，而 $norm(x)_2 = sqrt(sum x_i^2) <= sqrt(n max(x_i^2)) = sqrt(n) norm(x)_infinity$。证毕。
]

=== 定理、引理、证明的引用

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 定义带 label 的定理
    #theorem(label: <my-thm>)[内容...]

    // 引用定理（显示为"定理1.1"）
    如 @my-thm 所述...

    // proof 使用 title 引用定理，显示为"定理1.x的证明"
    #proof(title: [@my-thm])[证明内容...]
    ```
  ]
]

如 @thm1 所述。引用 @lemma1 也可以正常工作。

== 公式相关

=== 行间公式 <usage-equation>

行间公式使用 ` $ $ ` 包裹（前后美元符号与文本里面有空格，或者换行），会自动编号。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 带编号的行间公式（添加 <label> 用于引用）
    $ E = m c^2 $ <einstein>

    ```
  ]
]

效果如下：

$ E = m c^2 $ <einstein>

$ cal(L) = sum_(i=1)^n (y_i - f(x_i))^2 $ <loss-function>

公式编号格式为 `(章节号-序号)`，如公式在本章中编号为 (1-x)。

=== 行内公式

行内公式使用单个 `$ $` 包裹（美元符号与内容之间没有空格），不会编号。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    变量 $x$ 的值为 $x = 42$，其中 $x in bb(R)$。
    ```
  ]
]

效果如下：

变量 $x$ 的值为 $x = 42$，其中 $x in bb(R)$。

=== 公式引用 <usage-eq-ref>

为公式添加 `<label>` 标签后，可以使用 `@label` 引用。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    $ E = m c^2 $ <einstein>

    如公式 @einstein 所示...
    // 显示为"公式(1-x)"
    ```
  ]
]

如 @einstein 和 @loss-function 所示。

=== 常用数学符号

本章列出一些常用的数学符号，更详细的可以参考 Typst 的数学模式文档。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 分数
    $ a/b $ 或 $ frac(a, b) $

    // 上下标
    $ x^2 $, $ x_i $

    // 求和与积分
    $ sum_(i=1)^n x_i $, $ integral_0^infinity f(x) dif x $

    // 矩阵和向量（加粗）
    $ bold(x) $, $ bold(A) $

    // 希腊字母
    $ alpha $, $ beta $, $ gamma $, $ epsilon $, $ theta $

    // 特殊字体
    $ cal(L) $ (花体), $ bb(R) $ (实数集), $ bb(E) $ (期望)

    // 分段函数
    $ f(x) = cases(
      1 & "if" x > 0,
      0 & "otherwise",
    ) $

    // 多行公式对齐（使用 & 对齐）
    $ a &= b + c \
      &= d + e $
    ```
  ]
]

== 引用相关

=== 图片/表格/算法的引用 <usage-ref-figure>

在被引用的对象后添加 `<label>` 标签，然后在正文中使用 `@label` 进行引用。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 定义带标签的图片
    #picture-figure("图片标题", image("path.png")) <fig-label>

    // 定义带标签的表格
    #table-figure("表格标题", table(...)) <tbl-label>

    // 定义带标签的算法
    #algorithm-figure("算法标题", {...}) <algo-label>

    // 引用（显示为"图1-1"、"表1-1"、"算法1-1"）
    如 @fig-label 所示。
    如 @tbl-label 所示。
    ```
  ]
]

如 @my-label、@subfig-example、@table-example、@merge-example 和 @algo-example 所示。

=== 文献引用 <usage-ref-bib>

文献引用使用 `@bib-key` 的格式，其中 `bib-key` 是 bib 文件中条目的标识符。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 单个引用
    如 @kopka2004guide 所述。

    // 多个引用（连续引用多篇文献）
    扩散模型@ddpm @score-based 的提出标志着...

    // 注意：多个 @ 引用之间用空格分隔
    ```
  ]
]

效果如下：

如 @kopka2004guide 所述，这是一本关于 LaTeX 的参考书籍。

=== `#c()` 函数（不上标的引用） <usage-c-function>

模板提供了一个特殊的 `#c()` 函数，用于引用文献时不显示上标。这在某些场景下很有用，例如"文献\#c(\<key1\>, \<key2\>)指出"。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 普通引用（带上标）
    相关研究@kopka2004guide @uestc2022guide 指出...

    // 使用 #c() 引用（不上标）
    相关研究#c(<kopka2004guide>, <uestc2022guide>)指出...

    // #c() 接受多个标签参数，用逗号分隔
    ```
  ]
]

效果如下：

普通引用（带上标）：相关研究@kopka2004guide @uestc2022guide 指出。

使用 `#c()` 引用（不上标）：相关研究#c(<kopka2004guide>, <uestc2022guide>)也提到了这一点。

=== 标题引用

引用章节标题时会自动显示"第x章"或"第x.x节"。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 一级标题引用（显示为"第x章"）
    如 @usage-table 所述...

    // 多级标题引用（显示为"第x.x.x节"）
    如 @usage-subfigure 所述...
    ```
  ]
]

如 @usage-picture 和 @usage-subfigure 所述。

=== 如何添加 Label

在任何元素后面都可以添加 `<label-name>` 标签，用于后续引用。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 图片标签
    #picture-figure(...) <fig-xxx>

    // 表格标签
    #table-figure(...) <tbl-xxx>

    // 公式标签
    $ E = m c^2 $ <eq-energy>

    // 章节标签（在标题行末尾添加）
    == 章节标题 <sec-label>

    // 定理/引理标签（label 通过参数传入，不需要后面加 <...>）
    #theorem(label: <thm-label>)[内容]

    // 注意：theorem/lemma/proof 的 label 通过参数传入
    // 不像图片、表格等使用后缀 <...> 语法
    // 推荐使用英文、数字和短横线，如 my-figure、eq-1
    ```
  ]
]

== 列表相关

=== 无序列表（Itemize）

使用 `-` 创建无序列表。可以使用 `*...*` 加粗或 `_..._` 斜体。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    - 普通列表项
    - *加粗的列表项*
    - _斜体的列表项_
    - *加粗且_斜体_的列表项*
    ```
  ]
]

效果如下：

- 普通列表项
- *加粗的列表项*
- _斜体的列表项_
- *加粗且_斜体_的列表项*

=== 有序列表（Enumerate）

使用 `+` 创建有序列表。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    + 第一项
    + 第二项
    + 第三项

    // 也可以手动指定编号
    (1) 第一项
    (2) 第二项
    ```
  ]
]

效果如下：

+ 第一项
+ 第二项
+ 第三项

=== 嵌套列表

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    - 一级列表项
      - 二级列表项
      - 另一个二级列表项
    - 另一个一级列表项
      + 二级有序列表
      + 第二项
    ```
  ]
]

效果如下：

- 一级列表项
  - 二级列表项
  - 另一个二级列表项
- 另一个一级列表项
  + 二级有序列表
  + 第二项

== 攻读学位期间取得成果 <usage-achievements>

成果列表有两种配置方式：

=== 方式一：使用成果列表功能（推荐）

此方式会自动从 bib 文件中提取文献信息并格式化输出。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 在 main.typ 中配置成果列表
    info-keys.成果列表: (
      成果列表-keys.成果文件: path("src/bib/参考文献1.bib"),  // bib 文件路径
      成果列表-keys.作者姓名: "Kopka H",  // 填写你的名字，模板会自动在成果列表中加粗
      成果列表-keys.条目: (
        // 每个元素为 (<bib引用key>, "作者排序", "分类说明")
        (<paper1>, "第一作者", "CCF-A类会议"),
        (<paper2>, "共同一作", "CCF-B期刊"),
        (<paper3>, "第二作者", "中科院JCR1区"),
      ),
      // 非论文成果（如专利、软件著作权等）
      成果列表-keys.其他成果: include "src/攻读学位期间取得成果.typ",
      // 匿名评审时使用的非论文成果版本
      成果列表-keys.其他成果-匿名: include "src/攻读学位期间取得成果-匿名.typ",
    ),
    info-keys.攻读学位期间取得成果: true,
    ```
  ]
]

*参数说明：*
- `成果文件`：包含所有论文条目的 bib 文件路径
- `作者姓名`：在 bib 文件中的姓名格式，用于高亮（加粗）作者
- `条目`：元组，每个元素为 `(<bib-key>, "排序", "分类")` 格式
  - `<bib-key>`：bib 文件中的 cite key
  - `"排序"`：如 "第一作者"、"共同一作"、"第二作者"
  - `"分类"`：如 "CCF-A类会议"、"SCI期刊" 等说明
- `其他成果`：用于列出专利、软件著作权等非论文成果
- `其他成果-匿名`：匿名评审时使用的非论文成果版本。当开启匿名模式（`info-keys.匿名: true`）时，模板会自动使用此字段替代 `其他成果`

=== 方式二：直接 include 文件

如果不使用成果列表功能，可以直接 include 一个包含成果内容的文件。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 在 main.typ 中
    info-keys.攻读学位期间取得成果: include "src/攻读学位期间取得成果.typ"

    // 在 src/攻读学位期间取得成果.typ 中直接写成果内容
    // 注意：不需要写 = 标题，模板会自动添加
    ```
  ]
]

== 其他用法

=== path <usage-path>

Typst 中表示文件路径有两种方式：*字符串路径*和 `path()` 函数返回的 `path` 类型。它们的区别在于*相对路径的解析基准不同*，这在向模板（包）内部传递路径时尤为关键。

#noindent *字符串路径*

直接用字符串表示路径，是最常见的写法：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    image("pics/logo.svg")        // 相对路径
    image("/src/pic/图片.png")    // 绝对路径（以 / 开头）
    include "src/摘要-中文.typ"
    ```
  ]
]

*关键点：* 字符串路径在*实际调用该字符串的位置*被解析。当字符串路径被传入模板/包内部、由包内的函数（如 `image()`、`read()`）使用时，相对路径会以*包内部文件所在目录*为基准解析，而不是你的 `main.typ` 所在目录。这通常会导致 `file not found` 错误。

#noindent *`path()` 函数*

`path()` 函数将字符串在*当前文件*中提前解析并锁定为 `path` 类型对象。此后该对象无论被传递到哪里（包括包内部），始终指向*调用 `path()` 的那个文件*所解析出的路径。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 相对路径：相对于当前文件所在目录解析
    info-keys.参考文献: path("src/bib/参考文献.bib")

    // 绝对路径：以 / 开头，相对于项目根目录解析
    info-keys.参考文献: path("/src/bib/参考文献.bib")
    ```
  ]
]

#noindent *为什么 `参考文献` 和 `独创性声明扫描页` 必须用 `path()`？*

这两个字段的文件都由模板*包内部*的函数读取：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // ❌ 错误：直接传字符串，路径会在包内部解析，导致找不到文件
    info-keys.参考文献: "src/bib/参考文献.bib",
    info-keys.独创性声明扫描页: "src/独创性声明.pdf",

    // ✅ 正确：用 path() 包裹，路径在 main.typ 中提前锁定
    info-keys.参考文献: path("src/bib/参考文献.bib"),
    info-keys.独创性声明扫描页: path("src/独创性声明.pdf"),
    ```
  ]
]

*说明：*
- 字符串路径：相对于*内部函数调用时所在的文件*解析（包内部目录）
- `path()`：相对于*调用 `path()` 的文件*解析（你的 `main.typ`）
- 因此，凡是会被包内部读取的路径参数，都必须用 `path()` 包裹
- 绝对路径（以 `/` 开头）两者等价，均相对于项目根目录解析

=== 脚注

使用 `#footnote(...)` 添加脚注。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    这是一段文字#footnote[这是一个脚注]。
    这是一段带链接的脚注#footnote(link("https://typst.app")[Typst官网])。
    ```
  ]
]

效果如下：

这是一段文字#footnote[这是一个脚注]。这是一段带链接的脚注#footnote(link("https://typst.app")[Typst官网])。

=== 链接

使用 `link()` 函数或 `#link()` 添加超链接。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 方式一
    #link("https://typst.app")[Typst官网]

    // 方式二
    #link("https://typst.app")  // 显示URL本身

    // 方式三（快捷写法）
    参见 https://typst.app
    ```
  ]
]

=== 代码块

使用三个反引号创建代码块。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 行内代码
    使用 `typst compile main.typ` 编译。

    // 代码块
    ```python
    def hello():
    print("Hello, World!")
    ```
    ```
  ]
]

=== 取消首行缩进

在公式后的文字等场景，需要取消首行缩进时使用 `#noindent`。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    $ E = m c^2 $
    #noindent 其中 $E$ 为能量，$m$ 为质量，$c$ 为光速。
    ```
  ]
]

=== 修改标记（revise） <usage-revise>

使用 `#revise[文字]` 标记论文中修改的内容。在修订模式下，标记的文字会显示为红色，方便审阅；在打印模式或电子档定稿模式下，红色标记会自动取消，恢复正常显示。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 标记修改内容（修订模式显示红色，打印/定稿模式正常显示）
    #revise[这里是修改后的内容]

    // 也可以标记较长的段落
    #revise[
      这是一段较长的修改内容，
      可以包含多行文字。
    ]
    ```
  ]
]

效果如下（当前为打印模式，修改内容正常显示；切换为修订模式时此处会变红）：

#revise[这是使用 revise 标记的修改内容。]

*工作原理：*
- 修订模式（`info-keys.论文模式: 论文模式.修订模式`）：标记内容显示为红色
- 打印模式（`info-keys.论文模式: 论文模式.打印模式`）：标记内容正常显示，不添加任何颜色
- 电子档定稿模式（`info-keys.论文模式: 论文模式.电子档定稿模式`）：标记内容正常显示，不添加任何颜色

=== 路径说明

本章介绍在 `main.typ` 中配置路径时的注意事项。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 编译时需要指定根目录（在 makefile 中使用 --root .）
    // 路径以 / 开头表示相对于根目录（main.typ 所在目录）
    image("/src/pic/第一章/图片.png")
    ```
  ]
]

=== include 与直接传值的区别

在 `main.typ` 中配置论文信息时，部分字段可以直接传字符串，部分需要使用 `include`。

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```typ
    // 直接传字符串（适用于路径、简短文本等）
    info-keys.参考文献: path("src/bib/参考文献1.bib"),  // bib 文件路径
    info-keys.论文中文标题: "论文标题",  // 字符串

    // 使用 include（适用于较长内容、需要排版的文本）
    info-keys.中文摘要: include "src/摘要-中文.typ",
    info-keys.致谢: include "src/致谢.typ",

    // 附录是元组（可以包含多个 include）
    info-keys.附录: (include "src/附录-1.typ", include "src/附录-2.typ"),

    // 成果列表是字典
    info-keys.成果列表: (
      成果列表-keys.成果文件: path("src/bib/参考文献1.bib"),
      成果列表-keys.作者姓名: "Kopka H",  // 填写你的名字，模板会自动在成果列表中加粗
      成果列表-keys.条目: ((<key>, "排序", "分类"),),
      成果列表-keys.其他成果: include "src/攻读学位期间取得成果.typ",
      成果列表-keys.其他成果-匿名: include "src/攻读学位期间取得成果-匿名.typ",
    ),
    ```
  ]
]

== 已知问题

=== 标题间只有 `#block` 时空行被删除

标题之间只有文字、图表等元素时，会被识别到有内容，排版正常。但如果标题之间只有一个 `#block`（代码展示块），Typst 会认为标题之间没有内容，导致标题之间的空行被删除，从而影响排版效果。

*解决方法：* 在 `#block` 前后添加任意文字内容即可避免此问题。本模板中的章节已尽量在 `#block` 前添加说明文字。

=== 特殊字符导致跳转失效

使用特殊字符（如中文引号“”、黑体标注等）会导致预览跳转到文字功能失效，不影响生成的文字，无需特别关注。对于“”，可以使用英文引号`""`或者`''`替代，会自动替换为中文引号，而不会跳转失效。


