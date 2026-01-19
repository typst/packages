#import "@preview/sjtu-graduate-thesis-proposal:0.1.0": project, mychecked, myunchecked
// 获取当前日期并格式化为 2026-01-18 这种形式
#let today-date = datetime.today().display("[year]-[month]-[day]")

////////////////////////////////////////////////////////
// 填写说明：请在下面表格中填写你的信息，注意事项：
// 1. 学生类别 Degree Program 中应填写以下四个中的一个
//       a. 学术型博士生 Academic Doctoral Student
//       b. 专业型博士生 Professional Doctoral Student
//       c. 学术型硕士生 Academic Master Student
//       d. 专业型硕士生 Professional Master Student
// 2. 学习形式 Study Mode 中应填写以下三个中的一个
//       a. 全日制 Full-time
//       b. 非全日制 Part-time
//       c. 同等学力学生
// 3. 论文题目如果太长，可以使用 \n 手动换行 (见示例)，
//    也可以什么都不加，会进行自动换行
////////////////////////////////////////////////////////

#show: project.with(
  title: "我的很长很长很长很长很长很长很长很长很长的\n很厉害的论文题目",
  student-id: "012345678912",
  name: "我的姓名",
  degree-program: "学术型博士生 Academic Doctoral Student",
  study-mode: "全日制 Full-time",
  supervisor: "我的导师",
  school: "我的学院",
  major: "我的专业",
  date: today-date,
  venue: "会议室",
)

// 1. 课题基本信息表
// 局部设置：仿宋 + Times，以及 LaTeX 源码中的 1.68 倍行距 (leading)
#show table: set text(font: ("Times New Roman", "FangSong"), size: 12pt)
#show table: set par(leading: 0.95em, first-line-indent: 0pt) // 0.95em 接近 LaTeX 的 1.68 倍行距

#table(
  columns: (3.75cm, 11.5cm),
  stroke: 0.5pt,
  // inset 控制单元格内边距，5pt 使文字不贴边，更美观
  inset: 7pt, 
  align: horizon,
  
  [论文题目 \ Proposed Title], 
  [我的很长很长很长很长很长很长很长很长很长的 \ 很厉害的论文题目],
  
  [研究课题来源 \ Source of Research \ Project], 
  [
    请在合适选项前画 #mychecked #h(0.5em) Please select proper options by "#mychecked". \
    #v(-0.5em)
    // 嵌套 grid 以实现分栏对齐
    #grid(
      columns: (1.5em, 1fr), // 第一栏固定宽度放勾选框，第二栏放文字
      row-gutter: 1em,   // 控制复选框行间距
      align(center)[#mychecked], [国家自然科学基金课题 NSFC Research Grants],
      align(center)[#myunchecked], [国家社会科学基金 National Social Science Fund of China],
      align(center)[#mychecked], [国家重大科研专项 National Key Research Projects],
      align(center)[#myunchecked], [其它纵向科研课题 Other Governmental Research Grants],
      align(center)[#myunchecked], [企业横向课题 R&D Projects from Industry],
      align(center)[#myunchecked], [自拟课题 Self-proposed Project],
      align(center)[#myunchecked], [
        其它 Other #h(0.2em) 
        #box(
          width: 7cm, 
          stroke: (bottom: 0.5pt), 
          inset: (bottom: 3pt),
          baseline: 3pt
        )[在此处填写内容]
      ]
    )
  ]
)

#show table: set text(font: ("Times New Roman", "KaiTi"))

// 2. 正文部分
= 请综述课题国内外研究进展、现状、挑战与意义，可分节描述。博士生不少于10,000汉字，硕士生不少于5,000汉字。请在文中标注参考文献。 Please review the frontier, current status, challenges and significance of the research topic. The citations should be marked in the context and listed in order at the end of this section. No less than 8,000 words for doctoral students and 4,000 words for master students if written in English.

制作本开题报告 Typst 模板的初衷，是为校友们提供一个比 LaTeX 更轻量、比 Word 更专业的排版方案。

== 模板使用指南 (Template Guide)

本模板已针对上海交通大学开题报告的格式规范，深度定制了字体、间距、标题悬挂缩进及参考文献样式。

=== 数学公式 (Mathematics) <math_section>
Typst 采用了类似数学直觉的语法。行内公式直接使用 \$ 包裹，如 $a^2 + b^2 = c^2$。

对于复杂的行间公式，可以使用双美元符号：
$ cal(F)(omega) = integral_(-infinity)^(infinity) f(t) e^(-i omega t) d t $

你也可以编写矩阵或多行对齐公式：
$ A = mat(1, 2; 3, 4), quad sum_(i=1)^n i = (n(n+1)) / 2 $

=== 图像处理与交叉引用 (Images & References)
插入图片建议使用 `figure` 环境，这样可以自动生成“图 1”这样的标签并支持自动编号。

#figure(
  // 请确保 figures 文件夹下有对应的图片文件
  image("./figures/A.png", width: 50%),
  caption: [示例图片],
) <fig_A>

如 @fig_A 所示，图片会自动居中。在正文中使用 `@fig_A` 即可实现自动跳转引用。

=== 表格设计 (Tables)
本模板对表格进行了局部优化，使其更符合中文学术排版的“三线表”或“全框表”风格。

#figure(
  table(
    columns: (auto, 1fr, 1.5fr), // 自动宽度、1份比例、1.5份比例
    stroke: 0.5pt,              // 线条粗细
    inset: 8pt,                 // 单元格内边距
    align: center + horizon,    // 水平居中，垂直居中
    table.header([*阶段*], [*研究内容*], [*预期成果*]),
    [第一阶段], [国内外文献综述与需求分析], [提交开题报告定稿],
    [第二阶段], [核心算法设计与仿真验证], [发表高质量学术论文],
    [第三阶段], [实验数据收集与论文撰写], [完成学位论文初稿],
  ),
  caption: [课题研究详细进度安排表],
) <tab_schedule>

通过引用 @tab_schedule ，读者可以清晰地了解研究进度。

==== 三线表展示
三线表通常用于展示实验结果或对比数据，其结构简洁明了。

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    // 关键：首先将全局边框设为 none
    stroke: none, 
    inset: 8pt,
    align: center + horizon,
    
    // 1. 顶线：在 table.header 之前通过 line 模拟或使用 table.hline
    table.hline(stroke: 1.5pt), // 顶线较粗
    table.header([*方法*], [*准确率 (%)*], [*召回率 (%)*], [*F1 分数*]),
    table.hline(stroke: 0.5pt), // 栏目线较细
    
    [Baseline], [85.2], [82.1], [83.6],
    [Proposed], [92.4], [90.8], [91.6],
    [State-of-art], [93.1], [91.2], [92.1],
    
    table.hline(stroke: 1.5pt), // 底线较粗
  ),
  caption: [不同算法性能对比（三线表示例）],
) <tab_3line>

通过引用 @tab_3line 可以看到，三线表取消了所有竖线，使数据阅读更加流畅。

=== 参考文献管理 (Bibliography)
本模板集成了 `gb-7714-2015-numeric` 标准。你只需要在同级目录下准备一个 `ref.bib` 文件。

引用方式非常简单：

- 单个引用：该算法的收敛性已在文献 @ZJSD 中得到证明。
- 多个引用：目前主流观点支持该结论 @ZJSD 。

参考文献列表会自动根据你的引用顺序生成在文末，并应用左缩进 2 字符的样式。

=== 章节标签与快速跳转
你可以通过在标题后添加 `<label_name>` 来定义标签。

例如，本文档 数学公式 的章节定义为 `=== 数学公式 <math_section>`。我们现在可以轻松地通过 `@math_section` 跳回该部分 @math_section。

=== 常用排版技巧

- *加粗*：使用 `*加粗内容*` .
- _斜体_：使用 `_斜体内容_`。
- #text(fill: red)[彩色文字]：使用 `#text(fill: color)[内容]`。
- 脚注：直接在文中写 `#footnote[内容]` 即可生成#footnote[这是一个脚注]。

=== 列表

==== 无序列表 (Unordered Lists)
无序列表使用减号 `-` 开头。它可以自动处理多级嵌套：

- 第一级项目
  - 第二级嵌套项目
    - 第三级嵌套项目
- 并列的一级项目

==== 有序列表 (Ordered Lists)
有序列表使用加号 `+` 开头，Typst 会自动处理编号逻辑：

+ 第一项任务：收集很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多很多文献数据。
+ 第二项任务：建立数学模型。
  + 子任务 A：参数标定。
  + 子任务 B：灵敏度分析。
+ 第三项任务：撰写开题报告。

==== 列表样式自定义
如果你需要自定义列表的符号（例如将圆点改为方框或箭头），可以使用 `set` 规则：

// 局部设置：将无序列表符号改为中划线，有序列表改为字母
#block[
  // 这里的设置只在这个块内生效
  #set list(marker: ([—], [•]))
  #set enum(numbering: "a)")
  
  - 这里的符号是长划线 `—`
    - 这里的符号是圆点 `•`
  + 这里的编号是 a)
]

块外面自动恢复默认

- 这里的符号回到了圆点
+ 这里的编号回到了数字

== 国内外现状 <status>
正如在 @status 中所述，目前该领域的研究正处于快速发展期。


=== 现有挑战
目前的挑战主要在于算法的复杂度。

// 3. 参考文献
#v(2em)
#text(weight: "bold")[参考文献 References:]
#pad(left: 2em)[
  #set par(first-line-indent: 0pt) // 重置参考文献内部的首行缩进，防止冲突
  #bibliography(
    "./ref.bib", 
    title: none, 
    style: "gb-7714-2015-numeric"
  )
]

= 课题研究目标、主要研究内容和拟解决的关键问题。 Research objectives, main contents and key issues to be solved.
我的课题研究目标非常明确...

= 拟采取的研究方法、研究方案及其可行性分析。Research methods and research scheme to be adopted and feasibility analysis.
我要采取特别厉害的研究方法。

= 课题的创新点 Novelties of the proposed topic.
我的课题非常的创新，每一个点都非常*创新*。

= 计划进度、预期成果 Research schedule, and expected outcomes
我计划一年内发表顶级会议论文。

= 与本课题有关的工作积累、已有的研究工作成绩。Prior experience and accomplished achievements related to the proposed topic.

目前已经积累了很多很多工作了，也取得了非常非常好的工作成绩。



// --- 结尾承诺栏（取消首行缩进） ---
#v(2em)

// 1. 局部重置所有缩进设置
#set par(first-line-indent: 0pt)
// 2. 局部屏蔽我们在 template 里写的强制间距补丁
#show par: it => it 

// 承诺内容
#text(font: ("Times New Roman", "FangSong"), weight: "bold")[
  本人承诺：开题报告中的内容真实无误，若有不实，愿承担相应的责任和后果。I hereby declare and confirm that the details provided in this Form are valid and accurate.
]

#v(2em)

// 签字与日期栏
#grid(
  columns: (10cm, 1fr),
  align: horizon,
  // 确保整行使用 仿宋 + Times 加粗
  [
    #set text(font: ("Times New Roman", "FangSong"), weight: "bold")
    学生签字/Signature: 
    #h(0.2em) 
    #box(baseline: 20%, image("./figures/your_signature.png", height: 1.2em))
  ],
  [
    #set text(font: ("Times New Roman", "FangSong"), weight: "bold")
    日期/Date: #today-date
  ]
)