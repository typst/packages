#import "@preview/modern-jnu-thesis:0.1.0": jnu-thesis

#let title = "暨南大学本科毕业论文 Typst 模板"
#let title-en = "A Typst Template for Jinan University Undergraduate Theses"

#show: jnu-thesis.with(
  paper-type: "thesis",

  title: title,
  title-en: title-en,
  short-title: title,
  college: "",
  major: "",
  author: "",
  student-id: "",
  supervisor: "",
  date: "二〇二六年六月",

  abstract: [
    针对暨南大学本科毕业论文的排版需求，设计并实现了一套基于 Typst 的论文模板。模板将封面、诚信声明、中英文摘要、目录等前置部分与正文样式封装为可复用函数。
  ],
  abstract-en: [
    To meet the typesetting requirements of undergraduate theses at Jinan University, this paper designs and implements a thesis template based on Typst.The cover, integrity statement, Chinese and English abstracts, table of contents, and body styles are encapsulated as reusable functions.
  ],
  keywords: ("毕业论文", "Typst"),
  keywords-en: ("Thesis", "Typst"),

  // 调研报告专用
  // course: ("课程名第一行", "课程名第二行"),
  // class-name: "2024 级金融工程",
  // score: "",
  // team: (
  //   (name: "张三", student-id: "2024xxxxxx", work: "资料收集"),
  //   (name: "李四", student-id: "2024xxxxxx", work: "问卷设计与数据分析"),
  // ),

  // 参考文献与排版
  bib: bibliography("res/refs.bib", style: "gb-7714-2015-numeric", title: none),
  chapter-pagebreak: false,      // 编号章节是否另起一页
  leading: 0.83em,               // 行距，约 1.5 倍
  // logo: "res/jnulogo.png",    // 默认使用 res/jnulogo.png

  // 字号设置
  sizes: (
    body: 11pt,          // 正文（四号）
    heading: 15pt,       // 各级标题（小三）
    caption: 10.5pt,     // 图、表标题（五号）
    note: 9pt,           // 脚注（小五）
    code: 10.5pt,        // 代码块
    cover-title: 36pt,   // 封面标题
    cover-info: auto,    // 封面信息栏（跟随 body）
    statement-title: 22pt, // 诚信声明标题
    statement-body: auto,  // 诚信声明正文
    abstract-title: 18pt,  // 摘要页标题
    abstract-body: auto,   // 摘要正文
    reference: auto,       // 参考文献条目
    toc-title: 24pt,       // 目录标题
    toc-entry: auto,       // 目录条目
    header: 10.5pt,        // 页眉
    footer: 10.5pt,        // 页码
  ),
)

= 绪论

== 插图
插图示例：@fig-logo 给出了示例。

#figure(
  image("res/jnulogo.png", width: 3cm),
  caption: [jnu logo],
) <fig-logo>

== 表格

表格采用三线表，表题置于表格上方，按章编号。@tab-tools 比较了三种常见排版工具的特点。

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (center + horizon, left + horizon, left + horizon),
    table.hline(stroke: 1pt),
    [*工具*], [*优势*], [*局限*],
    table.hline(stroke: 0.5pt),
    [Word], [操作直观，普及率高], [长文档样式一致性较弱],
    [LaTeX], [排版质量高，生态成熟], [学习成本高，中文配置复杂],
    [Typst], [语法简洁，编译速度快], [生态仍在发展],
    table.hline(stroke: 1pt),
  ),
  caption: [三种排版工具的比较],
) <tab-tools>

== 公式

公式另起一行居中书写，编号按章排列。以@eq-demo 为例：

$ integral_0^1 x^2 dif x = 1/3 $ <eq-demo>


= 系统设计

== 样式实现

标题层级通过编号格式 `1.1.1.1` 控制，最多支持四级。

参考文献使用 GB/T 7714—2015 顺序编码制#footnote[具体要求见（GB/T 7714—2015）。]，正文引用由 `cite` 的样式规则转换为上标。例如，文学化编程的思想可参见#cite(<knuth1984>)，LaTeX 的排版实践可参见#cite(<lamport1994>)。

#heading(numbering: none)[结论]

#heading(numbering: none)[致谢]


#heading(numbering: none)[附录 A]

以下分别给出论文与调研报告两种模式的基本调用方式。

论文模式：

```typst
#show: jnu-thesis.with(
  paper-type: "thesis",
  title: "论文题目",
  title-en: "English Title",
  short-title: "页眉短标题",
  college: "学院",
  major: "专业",
  author: "姓名",
  student-id: "学号",
  supervisor: "指导教师",
  date: "二〇二六年六月",
  abstract: [中文摘要],
  abstract-en: [English abstract],
  keywords: ("关键词1", "关键词2"),
  keywords-en: ("Keyword1", "Keyword2"),
  bib: bibliography("res/refs.bib", style: "gb-7714-2015-numeric", title: none),
  // include-statement: true,      // 默认：论文显示、报告隐藏
  // include-abstract-en: true,
  // chapter-pagebreak: false,     // 编号章节连续排版
)
```

调研报告模式：

```typst
#show: jnu-thesis.with(
  paper-type: "report",
  title: ("调查题目第一行", "第二行"),
  short-title: "学生实践调查报告",
  course: ("课程名称第一行", "第二行"),
  class-name: "2024 级金融工程",
  supervisor: "指导老师",
  score: "",
  date: "2026 年 5 月",
  abstract: [中文摘要],
  keywords: ("关键词1", "关键词2"),
  team: (
    (name: "张三", student-id: "2024xxxxxx", work: "资料收集"),
    (name: "李四", student-id: "2024xxxxxx", work: "问卷设计与数据分析"),
  ),
  bib: none,
)
```

报告模式默认不显示诚信声明和英文摘要；

如需显示，请修改：
- `include-statement: true`
- `include-abstract-en: true`
- 并同时填写 `abstract-en`、`keywords-en` 和 `title-en`。

#heading(numbering: none)[附录 B]

