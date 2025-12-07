#import "../book.typ": *

#show: book-page.with(title: "页面细节")
#show: checklist.with(fill: white.darken(20%), stroke: blue.lighten(20%))

#let page-self = "/guide/detail.typ"
#let page-thesis-ref = "/reference/thesis.typ"
#let page-info = "/reference/info.typ"
#let page-pubs = "/reference/pubs.typ"
#let page-comments = "/reference/comments.typ"

= 页面 & 元数据设置

#myinfo[
  学位论文封面应为彩色印刷。

  - “中英文封面”
  - “学位论文评阅专家及答辩委员会人员信息”
  - “独创性声明、学位论文使用授权书”“导师（组）对学位论文的评语”- “答辩委员会决议书”部分采用单面印刷

  从“摘要”到“在学期间取得创新性成果情况”部分采用双面印刷，A4标准纸（210mm×297mm）打印。

  页边距设置为上下2厘米，左右2.5厘米，装订线位置左侧，装订线0厘米。页眉边距1.5厘米，页脚边距1.75厘米。
]

在这里，我们设置了文稿的元数据（作者，标题等），设置了全局的页宽，边距，只需要在最开始加入代码：

```typ
#show: doc
```

= 封面页

#myinfo[
  中文封面内容、格式与论文封面一致。

  英文封面论文题目采用微软雅黑三号字；学校代码、研究生学号和密级均采用Times New Roman五号字；

  作者、指导教师、一级学科（学位类别）、二级学科（学位领域）和研究方向均采用Times New Roman小四号字；

  论文完成时间采用Times New Roman四号字。
]

封面页通过 `doctype` 进行分发，我们只需要使用 `cover()` 函数即可：

```typ
#cover()
```

= 扉页

#myinfo[
  中文字体采用宋体，英文和数字采用Times New Roman字体，均为小四号字

  大纲级别正文文本，居中对齐，段前0行，段后0行，1.5倍行距
]

本科生的扉页只包含了 _独创性声明_，也就是 `decl-page()`

硕博的扉页包含两个部分：

- 学位论文评阅专家及答辩委员会人员信息
- 独创性声明、学位论文使用授权书


这里，_独创性声明_ 我们都使用函数 `decl-page()`，而 _学位论文评阅专家及答辩委员会人员信息_ 我们使用 `committee-page()`。

正如前文提到的，`committee-page()` 无法在本科生模板中使用，如果我们调用了 `#committee-page()` 函数，那么会导致 `panic` 无法编译渲染。

因此，在本科生论文中，我们只需要调用：

```typ
#decl-page()
```

在硕博论文中，我们调用：

```typ
#committee-page()

#decl-page()
```

= 前言

#myinfo[
  “摘要”至“符号和缩略语说明”部分用大写罗马数字编排页码
]

现在，从摘要开始，我们通过 `preface` 需要对文章的前言部分进行格式化，主要是页码计数

这部分较为简单，只需要调用即可：

```typ
#show: preface
```

= 中英文摘要

#myinfo[
  + 中文摘要：
    + 标题二字中间空2个汉字或4个半角空格，三号黑体字，居中无缩进，大纲级别1级，段前48磅，段后24磅，1.5倍行距。
    + 正文中文采用宋体，英文和数字采用Times New Roman字体，均为小四号，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。
    + 关键词采用小四号宋体加粗，其后关键词采用宋体小四号，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。关键词之间用全角分号“；”隔开，最后一个关键词后不加标点符号。关键词前空1行，空白行的字号为小四号。
  + 外文摘要：
    + “Abstract”标题采用三号Times New Roman字体，加粗，居中无缩进，大纲级别1级，段前48磅，段后24磅，1.5倍行距。
    + 正文采用小四号Times New Roman字体，两端对齐，首行缩进2字符，段前0行，段后0行，1.5倍行距。外文中应使用半角标点符号，且标点符号后面有1个半角空格。
    + “Key words:”采用小四号Times New Roman字体加粗，两端对齐，悬挂缩进5.95字符，段前0行，段后0行，1.5倍行距。关键词之间用半角分号“;”分开，最后一个关键词后不加标点符号。关键词前空1行，空白行的字号为小四号。
]

同样，在这里我们也通过 `doctype` 进行了分发，所有的摘要只需要调用：

- `abstract`: 中文摘要
- `abstract-en`: 英文摘要

注意，这两个函数都会接受一个参数 _关键词_ `keywords`，这是一个字符数组，用于写上论文的关键词，例如：

```typ
#abstract(
  keywords: ("我", "就是", "测试用", "关键词"),
)[
  摘要
]

#abstract-en(
  keywords: (
    "key", "words",),
)[
  abstract
]
```

我们只需要在中括号内写上自己的摘要即可

= 目录

由于硕博论文要求有插图/表格/符号说明，因此这里的目录本质上有四个函数：

```typ
// 目录
#outline-page()

// 插图目录
#list-of-figures()

// 表格目录
#list-of-tables()

// 符号表
#notation[
  / DFT: 密度泛函理论 (Density functional theory)
  / DMRG: 密度矩阵重正化群密度矩阵重正化群密度矩阵重正化群 (Density-Matrix Reformation-Group)
]
```

需要注意的是，我们只需要在符号表上填写论文中提到的符号和缩略语即可，按照示例的格式进行编写即可。

= 正文

正文部分我们只需要通过 `mainmatter` 设置即可：

```typ
#show: mainmatter
```

在这之后书写论文主体内容即可

= 参考文献

参考文献我们不需要进行设置，只需要在传入参数时，指定我们的 `biblatex` 数据库文件名称即可

然后进行调用：

```typ
#bilingual-bibliography(full: true)
```

= 附录

由于附录与正文部分并不共享标题的格式，于是我们需要重新设置格式：

```typ
#show: appendix
```

在设置完附录格式后，我们即可按照书写正文的方式来书写附录的内容了

#mywarning[
  注意，附录最好保证只有一级标题
]

= 后记（致谢）

只需要直接调用函数，并在函数中书写上致谢的内容即可：

```typ
#acknowledgement[
  Testing acknowledgement
]
```

= 成果

我们需要传递 `pubs` 参数，其结构参考 #cross-link(page-pubs, reference: <pubs>)[pubs 参数文档]

调用即可：

```typ
#publication(
  pubs: (
    (
      name: "论文名称1",
      class: "学术论文",
      publisher: "NENU",
      public-time: "2025-09",
      author-order: "1",
    ),
    (
      name: "论文名称2",
      class: "学术论文",
      publisher: "NENU",
      public-time: "2025-10",
      author-order: "3",
    ),
  )
)
```

= 评价与决议书（博士限定）

我们需要传递一个 `comments` 参数，结构参考 #cross-link(page-comments, reference: <comments>)[comments 参数文档]

然后我们直接调用即可：

```typ
#decision(
  comments: (
    supervisor: "aaaaaa",
    committee: "bbbbbbb"
  ),
)
```
